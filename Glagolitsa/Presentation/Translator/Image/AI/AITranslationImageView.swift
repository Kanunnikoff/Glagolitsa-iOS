//
//  AITranslationImageView.swift
//  Glagolitsa
//
//  Created by Kanunnikov Dmitriy  on 16.06.2025.
//

import SwiftUI
import PhotosUI
#if os(macOS)
import AppKit
#else
import UIKit
#endif

struct AITranslationImageView: View {

    let translation: String

    @Bindable private var viewModel = AITranslationImageViewModel()

    @State private var generatedImage: AITranslationGeneratedImage?

    var body: some View {
        VStack {
            if let generatedImage {
                platformImageView(generatedImage)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "photo") // 􀏅
                    .resizable()
                    .scaledToFit()
            }

            if viewModel.isGeneratng {
                ProgressView()
            } else {
                Button {
                    generateImage()
                } label: {
                    Text("Generate")
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .navigationTitle("Translation Image")
#if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
#if !os(watchOS)
        .onAppear {
            generateImage()
        }
#endif
    }

    private func generateImage() {
        Task {
            await viewModel.generateImage(from: translation) { image, error in
                generatedImage = image
            }
        }
    }

    private func platformImageView(_ image: AITranslationGeneratedImage) -> Image {
#if os(macOS)
        Image(nsImage: image)
#else
        Image(uiImage: image)
#endif
    }
}

#Preview {
    AITranslationImageView(translation: "Ѳома, лѣто - это радость пробужденія, ласковое ​мѵро​, чудный ароматъ!")
}
