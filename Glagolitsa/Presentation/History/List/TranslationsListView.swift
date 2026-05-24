//
//  TranslationsListView.swift
//  Yat
//
//  Created by Kanunnikov Dmitriy  on 19.04.2025.
//

import SwiftUI
import OrderedCollections

private enum Destinations: Hashable {
    case translationDetails(Translation)
}

struct TranslationsListView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.prefersTabNavigation) private var prefersTabNavigation
    
    @AppStorage("isConfirmDeletion")
    private var isConfirmDeletion: Bool = true
    
    @AppStorage("isOldRusMonthNames")
    private var isOldRusMonthNames: Bool = false
    
    @State private var translationForDelete: Translation? = nil
    @State private var showingDeleteTranslationAlert: Bool = false
    
    let searchedTranslations: [Translation]
    @Binding var searchText: String
    
    var body: some View {
        ScrollViewReader { proxy in
            ZStack(alignment: .bottomTrailing) {
                translationList
                    .scrollDismissesKeyboard(.immediately)
                    .overlay {
                        if searchedTranslations.isEmpty && searchText.isEmpty {
                            ContentUnavailableView {
                                Label("Your translation history will be here", systemImage: "clock") // 􀐫
                            } description: {
                                Text("Save your first translation and it will appear here.")
                            }
                        } else if searchedTranslations.isEmpty && !searchText.isEmpty {
                            ContentUnavailableView.search(text: searchText)
                        }
                    }
            }
            .navigationDestination(for: Destinations.self) { destination in
                switch destination {
                    case .translationDetails(let translation):
                        TranslationDetailsView(translation: translation, isOldRusMonthNames: isOldRusMonthNames)
                }
            }
            .alert(
                "Attention",
                isPresented: $showingDeleteTranslationAlert,
                presenting: translationForDelete
            ) { translation in
                Button("Cancel", role: .cancel) {
                    translationForDelete = nil
                }
                
                Button("Delete", role: .destructive) {
                    delete(translation: translation)
                }
            } message: { _ in
                Text("Are you sure you want to delete the translation?")
            }
        }
    }
    
    private var translationList: some View {
        List {
            ForEach(searchedTranslations, id: \.id) { translation in
                NavigationLink(value: Destinations.translationDetails(translation)) {
                    TranslationListItemView(translation: translation, isOldRusMonthNames: isOldRusMonthNames)
                }
                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                    Button {
                        Util.copyToClipboard(text: translation.originalText)
                    } label: {
                        Label("Copy Original", systemImage: "square.on.square") // 􀐅
                    }
                    .tint(.accentColor)
                    
                    Button {
                        Util.copyToClipboard(text: translation.translatedText)
                    } label: {
                        Label("Copy Translation", systemImage: "square.on.square") // 􀐅
                    }
                    .tint(.accentColor)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        if isConfirmDeletion {
                            translationForDelete = translation
                            showingDeleteTranslationAlert.toggle()
                        } else {
                            delete(translation: translation)
                        }
                    } label: {
                        Label("Delete", systemImage: "trash") // 􀈑
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search...")
    }
    
    private func delete(translation: Translation) {
        modelContext.delete(translation)
        try? modelContext.save()
    }
}

#Preview {
    TranslationsListView(
        searchedTranslations: [],
        searchText: .constant("")
    )
}
