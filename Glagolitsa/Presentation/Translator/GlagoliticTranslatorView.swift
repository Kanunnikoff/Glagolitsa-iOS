//
//  GlagoliticTranslatorView.swift
//  GlagoliticTranslatorView
//
//  Created by Kanunnikov Dmitriy Sergeevich on 22.03.2025.
//

import SwiftUI
import Combine

enum GlagoliticTranslatorBottomSheetType: Identifiable, Equatable, Hashable {
    case settings
    case about

    var id: Self { self }
}

struct GlagoliticTranslatorView: View {

    private let subject: PassthroughSubject = PassthroughSubject<Int, Never>()

    @Environment(\.modelContext) private var modelContext
    @Environment(\.prefersTabNavigation) private var prefersTabNavigation
    @Environment(\.consumableIDs) private var consumableIDs

    @AppStorage("isKeepTranslationHistory")
    private var isKeepTranslationHistory: Bool = true

    @AppStorage("isOnboardingCompleted")
    private var isOnboardingCompleted: Bool = false

    @AppStorage("isTranslationImageEnabled")
    private var isTranslationImageEnabled: Bool = true

    @Bindable var viewModel: GlagoliticTranslatorViewModel
    @Binding var isFromGlagoliticToCyrillic: Bool

#if os(iOS)
    @State private var orientation: UIDeviceOrientation = UIDevice.current.orientation
#endif

    @State private var cancellables = Set<AnyCancellable>()
    @State private var isCopied: Bool = false

    @State private var showingTipsPurchasedIndicator: Bool = false
    @State private var showingTipsPurchaseErrorAlert: Bool = false

    @State private var showingOnboarding: Bool = false

    @State private var isTipsIconAnimating: Bool = true

    @State var cyrillicTextSelection: TextSelection? = nil
    @State var glagoliticTextSelection: TextSelection? = nil

    @State private var sheetType: GlagoliticTranslatorBottomSheetType? = nil

    var body: some View {
        ZStack {
#if os(iOS)
            if orientation.isLandscape {
                landscapeView
                    .onRotate { newOrientation in
                        if newOrientation.isPortrait {
                            orientation = newOrientation
                        }
                    }
            } else {
                portraitView
                    .onRotate { newOrientation in
                        if newOrientation.isLandscape {
                            orientation = newOrientation
                        }
                    }
            }
#elseif os(macOS)
            landscapeView
#endif
        }
        .navigationTitle("Glagolitsa")
        .navigationSubtitle("Thanks for the tip!")
#if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .toolbar {
            ToolbarItemGroup(placement: .navigation) {
                if prefersTabNavigation {
                    MainMenuView(sheetType: $sheetType)
                }

                Button {
                    purchaseTips()
                } label: {
                    Image(systemName: "cup.and.heat.waves.fill") // 􂊭
                }
            }

            ToolbarItem(placement: .primaryAction) {
                Button {
                    viewModel.clear()
                } label: {
                    Label("Clear", systemImage: "eraser") // 􁝀
                }
                .disabled(
                    viewModel.isConverting ||
                    (isFromGlagoliticToCyrillic ? viewModel.cyrillicText.isEmpty : viewModel.glagoliticText.isEmpty)
                )
            }
        }
        .navigationDestination(for: String.self) { translation in
            TranslationImageView(translation: translation)
        }
        .onAppear {
#if os(iOS)
            orientation = UIDevice.current.orientation
#endif

            subject.debounce(
                for: .seconds(0.5),
                scheduler: RunLoop.main
            )
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .sink { _ in
                convert()
            }
            .store(in: &cancellables)

#if !os(macOS)
            if !isOnboardingCompleted {
//                showingOnboarding.toggle() // Пока не буду показывать onboarding
                return
            }
#endif
        }
        .onDisappear {
            cancellables.forEach { $0.cancel() }
            cancellables.removeAll()
        }
#if !os(macOS)
        .fullScreenCover(isPresented: $showingOnboarding) {
            NavigationStack {
                OnboardingView(showingOnboarding: $showingOnboarding)
            }
        }
#endif
#if os(macOS)
        .sheet(item: $sheetType) { sheetType in
            sheetContent(for: sheetType)
        }
#else
        .fullScreenCover(item: $sheetType) { sheetType in
            sheetContent(for: sheetType)
        }
#endif
        .tips(
            showingTipsPurchasedIndicator: $showingTipsPurchasedIndicator,
            showingTipsPurchaseErrorAlert: $showingTipsPurchaseErrorAlert
        )
    }

    @ViewBuilder
    private func sheetContent(for sheetType: GlagoliticTranslatorBottomSheetType) -> some View {
        switch sheetType {
            case .settings:
                NavigationStack {
                    SettingsView()
                }

            case .about:
                NavigationStack {
                    AboutView()
                }
        }
    }

    var landscapeView: some View {
        LandscapeGlagoliticTranslatorView(
            isFromGlagoliticToCyrillic: $isFromGlagoliticToCyrillic,
            cyrillicTextSelection: $cyrillicTextSelection,
            glagoliticTextSelection: $glagoliticTextSelection,
            viewModel: viewModel,
            isKeepTranslationHistory: isKeepTranslationHistory,
            isTranslationImageEnabled: isTranslationImageEnabled,
            isCopied: isCopied,
            subject: subject,
            onSaveTranslation: {
                saveTranslation()
            },
            onCopy: {
                copy()
            },
            onHandleVariantWordChoose: { variantWord, variantWordChoose in
                handleVariantWordChoose(variantWord, variantWordChoose)
            },
            onSelectVariantWord: { variantWord in
                selectVariantWord(variantWord)
            }
        )
    }

    var portraitView: some View {
        PortraitGlagoliticTranslatorView(
            isFromGlagoliticToCyrillic: $isFromGlagoliticToCyrillic,
            cyrillicTextSelection: $cyrillicTextSelection,
            glagoliticTextSelection: $glagoliticTextSelection,
            viewModel: viewModel,
            isKeepTranslationHistory: isKeepTranslationHistory,
            isTranslationImageEnabled: isTranslationImageEnabled,
            isCopied: isCopied,
            subject: subject,
            onSaveTranslation: {
                saveTranslation()
            },
            onCopy: {
                copy()
            },
            onHandleVariantWordChoose: { variantWord, variantWordChoose in
                handleVariantWordChoose(variantWord, variantWordChoose)
            },
            onSelectVariantWord: { variantWord in
                selectVariantWord(variantWord)
            }
        )
    }

    private func convert() {
        Task {
            if isFromGlagoliticToCyrillic {
                await viewModel.convertFromGlagoliticToCyrillic()
            } else {
                await viewModel.convertFromCyrillicToGlagolitic()
            }
        }
    }

    private func copy() {
        if isFromGlagoliticToCyrillic {
            if !viewModel.cyrillicText.isEmpty {
                Util.copyToClipboard(text: viewModel.cyrillicText)
                playCopiedAnimation()
            }
        } else {
            if !viewModel.glagoliticText.isEmpty {
                Util.copyToClipboard(text: viewModel.glagoliticText)
                playCopiedAnimation()
            }
        }
    }

    private func playCopiedAnimation() {
        withAnimation {
            isCopied.toggle()

            Task {
                try? await Task.sleep(for: .milliseconds(1_500))

                await MainActor.run {
                    isCopied.toggle()
                }
            }
        }
    }

    private func saveTranslation() {
        modelContext.insert(
            Translation(
                originalText: isFromGlagoliticToCyrillic ? viewModel.glagoliticText : viewModel.cyrillicText,
                translatedText: isFromGlagoliticToCyrillic ? viewModel.cyrillicText : viewModel.glagoliticText,
                translationDirection: isFromGlagoliticToCyrillic ? .cyrillic : .glagolitic
            )
        )

        do {
            try modelContext.save()
            viewModel.isTranslationSaved = true
        } catch {
            print(error) // TODO: Показать ошибку
        }
    }

    private func purchaseTips() {
        Task {
            await PurchaseManager.shared.purchaseConsumable(
                productId: consumableIDs.tips,
                onSuccess: { transactionId in
                    withAnimation(.spring(duration: 0.5, bounce: 0.5)) {
                        showingTipsPurchasedIndicator = true
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
                        withAnimation(.spring(duration: 0.5, bounce: 0.3)) {
                            showingTipsPurchasedIndicator = false
                        }
                    }
                },
                onFailure: { transactionId, error in
                    showingTipsPurchaseErrorAlert.toggle()
                }
            )
        }
    }

    private func selectVariantWord(_ variantWord: VariantWord?) {
        guard let variantWord = variantWord else {
            return
        }

        if isFromGlagoliticToCyrillic {
            let text = viewModel.cyrillicText

            let startPosition = text.index(text.startIndex, offsetBy: variantWord.position)
            let endPosition = text.index(startPosition, offsetBy: variantWord.word.count)

            cyrillicTextSelection = .init(range: startPosition..<endPosition)
        } else {
            let text = viewModel.glagoliticText

            let startPosition = text.index(text.startIndex, offsetBy: variantWord.position)
            let endPosition = text.index(startPosition, offsetBy: variantWord.word.count)

            glagoliticTextSelection = .init(range: startPosition..<endPosition)
        }
    }

    private func handleVariantWordChoose(_ variantWord: VariantWord, _ choose: VariantWordChoose) {
        selectVariantWord(variantWord)

        switch choose {
            case .variant1:
                replaceSelectionBy(text: variantWord.getVariant1())

            case .variant2:
                replaceSelectionBy(text: variantWord.getVariant2())

            case .skip:
                print("no action")
        }

        if !viewModel.variantWords.isEmpty {
            viewModel.variantWords.removeFirst()
        }

        selectVariantWord(viewModel.variantWords.first)

        if viewModel.variantWords.isEmpty {
            viewModel.isVariantWordsBlockVisible = false
        }
    }

    private func replaceSelectionBy(text: String) {
        if isFromGlagoliticToCyrillic {
            guard let selection = cyrillicTextSelection else {
                return
            }

            if case .selection(let range) = selection.indices {
                viewModel.cyrillicText.replaceSubrange(range, with: text)
            }
        } else {
            guard let selection = glagoliticTextSelection else {
                return
            }

            if case .selection(let range) = selection.indices {
                viewModel.glagoliticText.replaceSubrange(range, with: text)
            }
        }
    }
}

#Preview {
    GlagoliticTranslatorView(
        viewModel: GlagoliticTranslatorViewModel(),
        isFromGlagoliticToCyrillic: .constant(false)
    )
}
