//
//  SplashView.swift
//  Glagolitsa
//
//  Created by Kanunnikov Dmitriy  on 04.05.2025.
//

import SwiftUI

struct SplashView: View {

    private static let colorComponentMaxValue = 255.0
    private static let titleBackgroundOpacity = 0.9
    private static let titleBackgroundRed = 76.0 / colorComponentMaxValue
    private static let titleBackgroundGreen = 39.0 / colorComponentMaxValue
    private static let titleBackgroundBlue = 179.0 / colorComponentMaxValue

    // Повторяет прежний цвет iOS 0x4C27B3 без UIKit, чтобы оттенок не зависел от платформы.
    private static let titleBackgroundColor = Color(
        red: titleBackgroundRed,
        green: titleBackgroundGreen,
        blue: titleBackgroundBlue
    )
    
    private let splashImages = [
        "splash_img_1", "splash_img_2", "splash_img_3", "splash_img_4",
        "splash_img_5", "splash_img_6", "splash_img_7", "splash_img_8",
        "splash_img_9", "splash_img_10", "splash_img_11", "splash_img_12",
        "splash_img_13", "splash_img_14", "splash_img_15", "splash_img_16",
        "splash_img_17", "splash_img_18", "splash_img_19", "splash_img_20",
        "splash_img_21", "splash_img_22", "splash_img_23", "splash_img_24"
    ]
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Translator between Cyrillic and Glagolitic")
                .lineLimit(nil)
                .font(.custom("Monomakh Unicode TT", size: 25, relativeTo: .body))
                .bold()
                .multilineTextAlignment(.center)
                .padding(32)
                .background(Self.titleBackgroundColor.opacity(Self.titleBackgroundOpacity))
                .foregroundStyle(.white)
                .cornerRadius(10)
                .padding(.horizontal, 10)
                .padding(.bottom, 32)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Занимает все доступное место
        .background(
            Image(splashImages[Int.random(in: 0 ..< 23)])
                .resizable()
                .scaledToFill()
        )
        .clipped()
        .ignoresSafeArea(.all)
    }
}

#Preview {
    SplashView()
}
