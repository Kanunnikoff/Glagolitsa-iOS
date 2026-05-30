//
//  TranslationListItemView.swift
//  Glagolitsa
//
//  Created by Kanunnikov Dmitriy  on 19.04.2025.
//

import SwiftUI

private enum TranslationListItemMetrics {
    static let contentSpacing: CGFloat = 10

#if os(macOS)
    static let rowPadding: CGFloat = 12
    static let rowCornerRadius: CGFloat = 8
#endif
}

struct TranslationListItemView: View {
    
    let translation: Translation
    
    var body: some View {
#if os(macOS)
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(TranslationListItemMetrics.rowPadding)
            .background(
                Util.secondarySystemBackgroundColor,
                in: RoundedRectangle(
                    cornerRadius: TranslationListItemMetrics.rowCornerRadius,
                    style: .continuous
                )
            )
#else
        content
#endif
    }

    private var content: some View {
        VStack(spacing: TranslationListItemMetrics.contentSpacing) {
            Text(translation.createDate.prettyFormat())
                .font(.caption)
                .italic()
                .foregroundStyle(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("**Original:** \(translation.originalText)")
                .lineLimit(3)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("**Translation:** \(translation.translatedText)")
                .lineLimit(3)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            let translationDirection = if translation.translationDirection == .glagolitic {
                "From Cyrillic to Glagolitic"
            } else {
                "From Glagolitic to Cyrillic"
            }
            
            Text(LocalizedStringKey(translationDirection))
                .font(.caption)
                .italic()
                .foregroundStyle(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    TranslationListItemView(translation: .stub())
}
