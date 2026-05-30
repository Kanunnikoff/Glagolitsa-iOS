//
//  TranslationImageView.swift
//  Yat
//
//  Created by Kanunnikov Dmitriy  on 20.04.2025.
//

import SwiftUI
import PhotosUI
#if os(macOS)
import AppKit
import Photos
import UniformTypeIdentifiers
#else
import UIKit
#endif

private struct TranslationCanvasSizeKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

private enum TranslationAlignment: String, CaseIterable {
    case leading
    case center
    case trailing

    func toFrameAlignment() -> Alignment {
        switch self {
            case .leading:
                return .leading
            case .center:
                return .center
            case .trailing:
                return .trailing
        }
    }

    func toMultilineTextAlignment() -> TextAlignment {
        switch self {
            case .leading:
                return .leading
            case .center:
                return .center
            case .trailing:
                return .trailing
        }
    }
}

private enum TranslationImageExport {
    static let fallbackCanvasWidth: CGFloat = 320
}

#if os(macOS)
private struct TranslationImageShareItem: Transferable {
    let data: Data

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .png) { item in
            item.data
        }
    }
}

private enum TranslationImagePhotos {
    static let saveButtonTitle = "Save to Photos"
    static let savingButtonTitle = "Saving..."
    static let savedAlertTitle = "Saved"
    static let savedAlertMessage = "Image saved to Photos."
    static let accessDeniedAlertTitle = "Photos Access Needed"
    static let accessDeniedAlertMessage = "Allow Glagolitsa to add images to Photos in System Settings."
    static let saveFailedAlertTitle = "Save Failed"
    static let saveFailedFallbackMessage = "Could not save image to Photos."
}

private enum TranslationImagePhotosSaveError: LocalizedError {
    case failedWithoutReason

    var errorDescription: String? {
        TranslationImagePhotos.saveFailedFallbackMessage
    }
}
#endif

struct TranslationImageView: View {

    let translation: String

    @Environment(\.displayScale) private var displayScale

    @State private var selectedFont: String = Config.shafarikFontName
    @State private var selectedSize: Int = 14
    @State private var selectedAlignment: TranslationAlignment = .center
    @State private var selectedTextColor: Color = .black
    @State private var selectedBackgroundColor: Color = .white

    @State private var showingPhotosPicker = false
    @State private var selectedImageItems: [PhotosPickerItem] = []
    @State private var selectedBackgroundImage: Image? = nil
    @State private var selectedBackgroundImageBlurRadius: Double = 0.0

    @State private var selectedHorizontalPadding: Double = 1.0
    @State private var selectedVerticalPadding: Double = 1.0

    @State private var previewCanvasSize: CGSize = .zero
    @State private var isPreparedForExport = false
    @State private var renderedImage = Image(systemName: "photo") // 􀏅
#if os(macOS)
    @State private var renderedImageShareItem: TranslationImageShareItem? = nil
    @State private var isSavingImageToPhotos = false
    @State private var showingPhotosSaveAlert = false
    @State private var photosSaveAlertTitle = ""
    @State private var photosSaveAlertMessage = ""
#endif

    var body: some View {
        List {
            textBody

            Section {
                Picker("Font", selection: $selectedFont) {
                    ForEach(Config.customFonts.keys.sorted(), id: \.self) { key in
                        if let fontName = Config.customFonts[key] {
                            Text(LocalizedStringKey(fontName))
                                .tag(fontName)
                        } else {
                            Text("Unknown Font")
                                .tag(key)
                        }
                    }
                }

                Picker("Size", selection: $selectedSize) {
                    ForEach(Config.fontSizes, id: \.self) { size in
                        Text("\(size)")
                            .tag(size)
                    }
                }

                Picker("Alignment", selection: $selectedAlignment) {
                    ForEach(TranslationAlignment.allCases, id: \.self) { alignment in
                        Text(LocalizedStringKey(String(describing: alignment)))
                            .tag(alignment)
                    }
                }

                ColorPicker("Text Color", selection: $selectedTextColor, supportsOpacity: true)

                ColorPicker("Background Color", selection: $selectedBackgroundColor, supportsOpacity: true)

                HStack {
                    Text("Background Image")

                    Spacer()

                    if let image = selectedBackgroundImage {
                        image
                            .resizable()
                            .frame(width: 25, height: 25)
                            .scaledToFill()
                            .onTapGesture {
                                showingPhotosPicker.toggle()
                            }
                    } else {
                        Image(systemName: "photo") // 􀏅
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 25)
                            .onTapGesture {
                                showingPhotosPicker.toggle()
                            }
                    }
                }

                if selectedBackgroundImage != nil {
                    LabeledContent {
                        Slider(value: $selectedBackgroundImageBlurRadius, in: 0...10) {
                            Text("")
                        } minimumValueLabel: {
                            Text("")
                        } maximumValueLabel: {
                            Text("10")
                        }
                    } label: {
                        Text("Background Blur")
                    }
                }

                LabeledContent {
                    Slider(
                        value: $selectedHorizontalPadding,
                        in: 0...100,
                        step: 3
                    ) {
                        Text("")
                    } minimumValueLabel: {
                        Text("")
                    } maximumValueLabel: {
                        Text("100")
                    }
                } label: {
                    Text("Horizontal Padding")
                }

                LabeledContent {
                    Slider(
                        value: $selectedVerticalPadding,
                        in: 0...100,
                        step: 3
                    ) {
                        Text("Vertical Padding")
                    } minimumValueLabel: {
                        Text("")
                    } maximumValueLabel: {
                        Text("100")
                    }
                } label: {
                    Text("Vertical Padding")
                }
            }

            if isPreparedForExport {
#if os(macOS)
                if let renderedImageShareItem {
                    ShareLink(item: renderedImageShareItem, preview: SharePreview(Text("Shared Image"), image: renderedImage)) {
                        Label("Share", systemImage: "square.and.arrow.up") // 􀈂
                            .frame(maxWidth: .infinity, alignment: .center)
                    }

                    Button {
                        savePreparedImageToPhotos()
                    } label: {
                        Label(
                            isSavingImageToPhotos ? TranslationImagePhotos.savingButtonTitle : TranslationImagePhotos.saveButtonTitle,
                            systemImage: "photo.badge.plus" // 􀏅 􀜊
                        )
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .disabled(isSavingImageToPhotos)
                }
#else
                ShareLink(item: renderedImage, preview: SharePreview(Text("Shared Image"), image: renderedImage)) {
                    Label("Share", systemImage: "square.and.arrow.up") // 􀈂
                        .frame(maxWidth: .infinity, alignment: .center)
                }
#endif
            }

            if !isPreparedForExport {
                Button {
                    render()
                } label: {
                    Label("Prepare", systemImage: "paintbrush.pointed") // 􀣶
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .navigationTitle("Translation Image")
#if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
#else
        .alert(photosSaveAlertTitle, isPresented: $showingPhotosSaveAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(photosSaveAlertMessage)
        }
#endif
#if !os(watchOS)
        .photosPicker(
            isPresented: $showingPhotosPicker,
            selection: $selectedImageItems,
            maxSelectionCount: 1,
            matching: .images
        )
        .onChange(of: selectedBackgroundColor) { _, _ in
            selectedBackgroundImage = nil
            invalidatePreparedImage()
        }
        .onChange(of: selectedFont) { _, _ in
            invalidatePreparedImage()
        }
        .onChange(of: selectedSize) { _, _ in
            invalidatePreparedImage()
        }
        .onChange(of: selectedAlignment) { _, _ in
            invalidatePreparedImage()
        }
        .onChange(of: selectedTextColor) { _, _ in
            invalidatePreparedImage()
        }
        .onChange(of: selectedBackgroundImageBlurRadius) { _, _ in
            invalidatePreparedImage()
        }
        .onChange(of: selectedHorizontalPadding) { _, _ in
            invalidatePreparedImage()
        }
        .onChange(of: selectedVerticalPadding) { _, _ in
            invalidatePreparedImage()
        }
        .task(id: selectedImageItems) {
            await applyBackgroundImage(items: selectedImageItems)
            selectedImageItems = []
        }
#endif
    }

    @ViewBuilder
    var textBody: some View {
        translationCanvas(width: nil)
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(key: TranslationCanvasSizeKey.self, value: geometry.size)
                }
            )
            .onPreferenceChange(TranslationCanvasSizeKey.self) { newSize in
                previewCanvasSize = newSize
            }
    }

    private func applyBackgroundImage(items: [PhotosPickerItem]) async {
        for item in items {
            guard let data = try? await item.loadTransferable(type: Data.self) else {
                continue
            }

#if os(macOS)
            guard let nsImage = NSImage(data: data) else {
                continue
            }

            await MainActor.run {
                selectedBackgroundImage = Image(nsImage: nsImage)
                invalidatePreparedImage()
            }
#else
            guard let uiImage = UIImage(data: data) else {
                continue
            }

            await MainActor.run {
                selectedBackgroundImage = Image(uiImage: uiImage)
                invalidatePreparedImage()
            }
#endif
        }
    }

    @MainActor private func render() {
        let canvasWidth = previewCanvasSize.width > 0 ? previewCanvasSize.width : TranslationImageExport.fallbackCanvasWidth
        let exportCanvas = translationCanvas(width: canvasWidth)
        let renderer = ImageRenderer(content: exportCanvas)

        // make sure and use the correct display scale for this device
        renderer.scale = displayScale

#if os(macOS)
        if let cgImage = renderer.cgImage,
           let shareItem = makeSharedImageShareItem(from: cgImage) {
            let imageSize = CGSize(
                width: CGFloat(cgImage.width) / displayScale,
                height: CGFloat(cgImage.height) / displayScale
            )
            let nsImage = NSImage(cgImage: cgImage, size: imageSize)

            renderedImage = Image(nsImage: nsImage)
            renderedImageShareItem = shareItem
            isPreparedForExport = true
        }
#else
        if let uiImage = renderer.uiImage {
            renderedImage = Image(uiImage: uiImage)
            isPreparedForExport = true
        }
#endif
    }

    private func invalidatePreparedImage() {
        isPreparedForExport = false
#if os(macOS)
        renderedImageShareItem = nil
#endif
    }

#if os(macOS)
    @MainActor private func savePreparedImageToPhotos() {
        guard let imageData = renderedImageShareItem?.data, !isSavingImageToPhotos else {
            return
        }

        isSavingImageToPhotos = true

        Task {
            let authorizationStatus = await requestPhotosAddAuthorization()

            guard canAddImagesToPhotos(authorizationStatus) else {
                showPhotosSaveAlert(
                    title: TranslationImagePhotos.accessDeniedAlertTitle,
                    message: TranslationImagePhotos.accessDeniedAlertMessage
                )
                isSavingImageToPhotos = false
                return
            }

            do {
                try await saveImageDataToPhotos(imageData)
                showPhotosSaveAlert(
                    title: TranslationImagePhotos.savedAlertTitle,
                    message: TranslationImagePhotos.savedAlertMessage
                )
            } catch {
                showPhotosSaveAlert(
                    title: TranslationImagePhotos.saveFailedAlertTitle,
                    message: error.localizedDescription
                )
            }

            isSavingImageToPhotos = false
        }
    }

    private func requestPhotosAddAuthorization() async -> PHAuthorizationStatus {
        await withCheckedContinuation { continuation in
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { authorizationStatus in
                continuation.resume(returning: authorizationStatus)
            }
        }
    }

    private func canAddImagesToPhotos(_ authorizationStatus: PHAuthorizationStatus) -> Bool {
        switch authorizationStatus {
            case .authorized, .limited:
                return true

            case .notDetermined, .restricted, .denied:
                return false

            @unknown default:
                return false
        }
    }

    private func saveImageDataToPhotos(_ imageData: Data) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            PHPhotoLibrary.shared().performChanges {
                let creationRequest = PHAssetCreationRequest.forAsset()
                let creationOptions = PHAssetResourceCreationOptions()
                creationOptions.uniformTypeIdentifier = UTType.png.identifier

                creationRequest.addResource(
                    with: .photo,
                    data: imageData,
                    options: creationOptions
                )
            } completionHandler: { didSave, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if didSave {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: TranslationImagePhotosSaveError.failedWithoutReason)
                }
            }
        }
    }

    @MainActor private func showPhotosSaveAlert(title: String, message: String) {
        photosSaveAlertTitle = title
        photosSaveAlertMessage = message
        showingPhotosSaveAlert = true
    }

    private func makeSharedImageShareItem(from cgImage: CGImage) -> TranslationImageShareItem? {
        guard let opaqueCGImage = makeOpaqueCGImage(from: cgImage),
              let data = NSBitmapImageRep(cgImage: opaqueCGImage).representation(
                using: .png,
                properties: [:]
              ) else {
            return nil
        }

        return TranslationImageShareItem(data: data)
    }

    private func makeOpaqueCGImage(from cgImage: CGImage) -> CGImage? {
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) ?? CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.noneSkipLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        let imageRect = CGRect(
            x: 0,
            y: 0,
            width: CGFloat(cgImage.width),
            height: CGFloat(cgImage.height)
        )

        guard let context = CGContext(
            data: nil,
            width: cgImage.width,
            height: cgImage.height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            return nil
        }

        // «Фото» на macOS ругается на непрозрачные картинки с премноженным альфа-каналом.
        // Поэтому перед передачей в системное окно «Поделиться» делаем плотный RGB-слой.
        context.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
        context.fill(imageRect)
        context.interpolationQuality = .high
        context.draw(cgImage, in: imageRect)

        return context.makeImage()
    }
#endif

    @ViewBuilder
    private func translationCanvas(width: CGFloat?) -> some View {
        VStack {
            Text(translation)
                .font(selectedTextFont)
                .lineLimit(nil)
                .multilineTextAlignment(selectedAlignment.toMultilineTextAlignment())
                .frame(maxWidth: .infinity, alignment: selectedAlignment.toFrameAlignment())
                .foregroundColor(selectedTextColor)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, selectedHorizontalPadding)
        .padding(.vertical, selectedVerticalPadding)
        .background {
            if let image = selectedBackgroundImage {
                image
                    .resizable()
                    .scaledToFill()
                    .blur(radius: selectedBackgroundImageBlurRadius)
                    .clipped()
            } else {
                selectedBackgroundColor
            }
        }
        .frame(width: width)
        .fixedSize(horizontal: false, vertical: true)
    }

    private var selectedTextFont: Font {
        let fontSize = CGFloat(selectedSize)

        if selectedFont == Config.systemFontName {
            return .system(size: fontSize)
        }

        return .custom(selectedFont, size: fontSize)
    }
}

#Preview {
    TranslationImageView(translation: "Ѳома, лѣто - это радость пробужденія, ласковое ​мѵро​, чудный ароматъ!")
}
