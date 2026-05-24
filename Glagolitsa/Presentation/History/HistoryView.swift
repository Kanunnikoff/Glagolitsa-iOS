//
//  HistoryView.swift
//  Yat
//
//  Created by Дмитрiй Канунниковъ on 03.07.2023.
//

import SwiftUI
import SwiftData
import OSLog
import Foundation

struct HistoryView: View {
    
    private let logger = MyLogger(category: "HistoryView")
    
    @Binding var searchText: String
    
    @Environment(\.modelContext) private var modelContext
    
    @AppStorage("isConfirmDeletion")
    private var isConfirmDeletion: Bool = true
    
    @Bindable private var viewModel = HistoryViewModel()
    
    @State private var showingDeleteAllTranslationsAlert: Bool = false
    
    @Query(sort: \Translation.createDate, order: .reverse)
    private var allTranslations: [Translation] = []
    
    var searchedTranslations: [Translation] {
        if searchText.isEmpty {
            return allTranslations
        } else {
            return allTranslations.filter {
                $0.originalText.localizedStandardContains(searchText) || $0.translatedText.localizedStandardContains(searchText)
            }
        }
    }
    
    var body: some View {
        TranslationsListView(
            searchedTranslations: searchedTranslations,
            searchText: $searchText
        )
        .navigationTitle("History")
        .navigationSubtitle("^[\(searchedTranslations.count) translations](inflect: true)")
#if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .toolbar {
            if !allTranslations.isEmpty {
                ToolbarItem {
                    Button {
                        if isConfirmDeletion {
                            showingDeleteAllTranslationsAlert.toggle()
                        } else {
                            deleteAllTranslations()
                        }
                    } label: {
                        Label("Delete All", systemImage: "trash") // 􀈑
                    }
                }
            }
        }
        .alert(
            "Attention",
            isPresented: $showingDeleteAllTranslationsAlert,
            actions: {
                Button("Cancel", role: .cancel) {
                    showingDeleteAllTranslationsAlert = false
                }
                
                Button("Delete", role: .destructive) {
                    deleteAllTranslations()
                }
            }
        ) {
            Text("Are you sure you want to delete all translations?")
        }
    }
    
    private func deleteAllTranslations() {
        try? modelContext.delete(model: Translation.self)
        try? modelContext.save()
    }
}

#Preview {
    HistoryView(searchText: .constant(""))
}
