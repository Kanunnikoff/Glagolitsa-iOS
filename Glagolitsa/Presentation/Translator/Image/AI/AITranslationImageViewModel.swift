//
//  AITranslationImageViewModel.swift
//  Glagolitsa
//
//  Created by Kanunnikov Dmitriy  on 16.06.2025.
//

import SwiftUI
import FirebaseAI
import OSLog
#if os(macOS)
import AppKit

typealias AITranslationGeneratedImage = NSImage
#else
import UIKit

typealias AITranslationGeneratedImage = UIImage
#endif

@Observable
final class AITranslationImageViewModel: ObservableObject {

    private static let TEXT_STUB = "{STUB}"
//    private static let IMAGE_GENERATION_PROMT = "Generate an image with this text centered in an old Russian-style font that supports pre-revolutionary letters: {STUB}"
    private static let IMAGE_GENERATION_PROMT = "Generate an image with this text centered: {STUB}"

    private let logger = MyLogger(category: "AITranslationImageViewModel")

    private var model: GenerativeModel? = nil

    var isGeneratng: Bool = false

    init() {
        // Initialize the Gemini Developer API backend service
        let ai = FirebaseAI.firebaseAI(backend: .googleAI())

        // Create a `GenerativeModel` instance with a Gemini model that supports image output
        model = ai.generativeModel(
            modelName: "gemini-2.0-flash-preview-image-generation",
            // Configure the model to respond with text and images
            generationConfig: GenerationConfig(responseModalities: [.text, .image])
        )
    }

    func generateImage(
        from text: String,
        completion: @escaping (AITranslationGeneratedImage?, Error?) -> Void
    ) async {
        guard let model else {
            logger.error("Failed to initialize the generative model.")
            return
        }

        await MainActor.run {
            isGeneratng = true
        }

        do {
            let template = AITranslationImageViewModel.IMAGE_GENERATION_PROMT
            let promt = template.replacingFirstOccurrence(of: AITranslationImageViewModel.TEXT_STUB, with: text)

            let response = try await model.generateContent(promt)

            // Handle the generated image
            guard let inlineDataPart = response.inlineDataParts.first else {
                logger.error("No image data in response.")

                await MainActor.run {
                    isGeneratng = false
                }

                completion(nil, nil)
                return
            }

            // Одинъ отвѣтъ модели превращаемъ въ родной типъ изображенія текущей платформы.
            guard let image = AITranslationGeneratedImage(data: inlineDataPart.data) else {
                logger.error("Failed to convert data to platform image.")

                await MainActor.run {
                    isGeneratng = false
                }

                completion(nil, nil)
                return
            }

            completion(image, nil)
        } catch {
            logger.error("\(error.localizedDescription)")
            completion(nil, error)
        }

        await MainActor.run {
            isGeneratng = false
        }
    }
}
