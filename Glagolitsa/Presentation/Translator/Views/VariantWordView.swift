//
//  VariantWordView.swift
//  Glagolitsa
//
//  Created by Kanunnikov Dmitriy  on 22.11.2025.
//

import SwiftUI

struct VariantWordView: View {

    let variantWord: VariantWord
    let index: Int
    let onChoose: (VariantWord, VariantWordChoose) -> Void

    var body: some View {
        VStack {
            Text(variantWord.word)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom)

            Text(variantWord.getVariant1Description())
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(variantWord.getVariant2Description())
                .frame(maxWidth: .infinity, alignment: .leading)

            if index == 0 {
                HStack {
                    Spacer()

                    Button("VARIANT 1") {
                        onChoose(variantWord, .variant1)
                    }

                    Spacer()

                    Button("VARIANT 2") {
                        onChoose(variantWord, .variant2)
                    }

                    Spacer()

                    Button("SKIP") {
                        onChoose(variantWord, .skip)
                    }

                    Spacer()
                }
                .padding(.top)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            Util.secondarySystemBackgroundColor,
            in: RoundedRectangle(cornerRadius: 12, style: .continuous)
        )
        .padding(.horizontal)
        .padding(.top, index > 0 ? 12 : 0)
    }
}

#Preview {
    VariantWordView(
        variantWord: VariantWord(
            word: "",
            type: .tail,
            position: 0
        ),
        index: 0,
        onChoose: { _, _ in }
    )
}
