//
//  AppDelegate.swift
//  iDelo
//
//  Created by Дмитрiй Канунниковъ on 13.04.2024.
//

import SwiftUI
import FirebaseCore

#if os(macOS)
import AppKit
import CoreText

class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {
        BundledFontRegistrar.registerFonts()

        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
    }
}

private enum BundledFontRegistrar {
    private static let infoPlistFontKey = "UIAppFonts"
    private static let fontFileExtensions = ["ttf", "otf"]

    static func registerFonts() {
        for fontURL in bundledFontURLs {
            registerFont(at: fontURL)
        }
    }

    private static var bundledFontURLs: [URL] {
        if let fontFileNames = Bundle.main.object(forInfoDictionaryKey: infoPlistFontKey) as? [String] {
            let fontURLs = fontFileNames.compactMap { fontFileName in
                Bundle.main.url(forResource: fontFileName, withExtension: nil)
            }

            if !fontURLs.isEmpty {
                return fontURLs
            }
        }

        guard let resourceURL = Bundle.main.resourceURL,
              let resourceURLs = try? FileManager.default.contentsOfDirectory(
                at: resourceURL,
                includingPropertiesForKeys: nil
              ) else {
            return []
        }

        return resourceURLs.filter { fontFileExtensions.contains($0.pathExtension.lowercased()) }
    }

    private static func registerFont(at fontURL: URL) {
        var registrationError: Unmanaged<CFError>?

        let didRegister = CTFontManagerRegisterFontsForURL(
            fontURL as CFURL,
            .process,
            &registrationError
        )

        // CoreText возвращает ошибку и для уже зарегистрированного шрифта.
        // Нам важно только подключить доступные файлы, поэтому освобождаем ошибку без показа пользователю.
        if !didRegister, let registrationError {
            _ = registrationError.takeRetainedValue()
        }
    }
}
#else
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }

        return true
    }

    func application(
        _ application: UIApplication, configurationForConnecting
        connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let sceneConfiguration = UISceneConfiguration(name: "Custom Configuration", sessionRole: connectingSceneSession.role)
        sceneConfiguration.delegateClass = CustomSceneDelegate.self
        return sceneConfiguration
    }
}
#endif
