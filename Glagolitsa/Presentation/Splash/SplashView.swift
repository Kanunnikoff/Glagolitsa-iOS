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
    private static let contentAnimationDuration: TimeInterval = 1.2

    private static let initialOpacity = 0.0
    private static let finalOpacity = 1.0

    private static let logoLetter = "Ⰳ"
    private static let title = "glagolitsa"

    // Смещения разной величины, потому что знак и подпись имеют разную высоту.
    // В конечном состоянии они равны нулю, и прежнее расстояние между элементами сохраняется.
    private static let initialLogoVerticalOffset = (contentSpacing + titleSize) / 2
    private static let initialTitleVerticalOffset = -(logoLetterSize + contentSpacing) / 2

    // Повторяет прежний основной оттенок iOS 0x4C27B3 без UIKit,
    // чтобы цвет знака не зависел от платформы.
    private static let logoColor = Color(
        red: logoRed,
        green: logoGreen,
        blue: logoBlue
    )

    @State private var isContentVisible: Bool = false

    var body: some View {
        VStack(spacing: Self.contentSpacing) {
            Text(Self.logoLetter)
                .font(.custom(Config.shafarikFontName, size: Self.logoLetterSize, relativeTo: .largeTitle))
                .foregroundStyle(Self.logoColor)
                .offset(y: logoVerticalOffset)

            Text(Self.title)
                .font(.custom(Config.shafarikFontName, size: Self.titleSize, relativeTo: .title))
                .textCase(.lowercase)
                .foregroundStyle(Util.labelColor)
                .offset(y: titleVerticalOffset)
        }
        .opacity(contentOpacity)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Util.systemBackgroundColor)
        .ignoresSafeArea(.all)
        .onAppear {
            withAnimation(.easeOut(duration: Self.contentAnimationDuration)) {
                isContentVisible = true
            }
        }
    }

    private var logoVerticalOffset: CGFloat {
        isContentVisible ? .zero : Self.initialLogoVerticalOffset
    }

    private var titleVerticalOffset: CGFloat {
        isContentVisible ? .zero : Self.initialTitleVerticalOffset
    }

    private var contentOpacity: Double {
        isContentVisible ? Self.finalOpacity : Self.initialOpacity
    }
}

#Preview {
    SplashView()
}
