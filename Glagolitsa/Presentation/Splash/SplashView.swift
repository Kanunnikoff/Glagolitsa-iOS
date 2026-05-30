//
//  SplashView.swift
//  Glagolitsa
//
//  Created by Kanunnikov Dmitriy  on 04.05.2025.
//

import SwiftUI

struct SplashView: View {

    private static let colorComponentMaxValue = 255.0
    private static let logoRed = 76.0 / colorComponentMaxValue
    private static let logoGreen = 39.0 / colorComponentMaxValue
    private static let logoBlue = 179.0 / colorComponentMaxValue
    private static let logoLetterSize: CGFloat = 160
    private static let titleSize: CGFloat = 30
    private static let contentSpacing: CGFloat = 18

    private static let logoLetter = "Ⰳ"
    private static let title = "glagolitsa"

    // Повторяет прежний основной оттенок iOS 0x4C27B3 без UIKit,
    // чтобы цвет знака не зависел от платформы.
    private static let logoColor = Color(
        red: logoRed,
        green: logoGreen,
        blue: logoBlue
    )

    var body: some View {
        VStack(spacing: Self.contentSpacing) {
            Text(Self.logoLetter)
                .font(.system(size: Self.logoLetterSize, weight: .regular, design: .serif))
                .foregroundStyle(Self.logoColor)

            Text(Self.title)
                .font(.custom("Monomakh Unicode TT", size: Self.titleSize, relativeTo: .title))
                .textCase(.lowercase)
                .foregroundStyle(Util.labelColor)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Util.systemBackgroundColor)
        .ignoresSafeArea(.all)
    }
}

#Preview {
    SplashView()
}
