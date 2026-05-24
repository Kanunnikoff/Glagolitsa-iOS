//
//  VariantWordsView.swift
//  Glagolitsa
//
//  Created by Kanunnikov Dmitriy  on 4/26/25.
//

import SwiftUI

enum VariantWordChoose {
    case variant1
    case variant2
    case skip
}

struct VariantWordsView: View {
    
    let variantWords: [VariantWord]
    let onChoose: (VariantWord, VariantWordChoose) -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(Array(variantWords.enumerated()), id: \.element) { index, variantWord in
                    VariantWordView(
                        variantWord: variantWord,
                        index: index,
                        onChoose: onChoose
                    )
                }
            }
        }
    }
}

#Preview {
    VariantWordsView(
        variantWords: [],
        onChoose: { _, _ in }
    )
}
