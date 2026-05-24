//
//  Util.swift
//  Glagolitsa
//
//  Created by Дмитрiй Канунниковъ on 03.07.2023.
//

import Foundation
#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif
import SwiftUI
import OSLog
import CryptoKit

struct Util {

    private static let logger = MyLogger(category: "Util")

    static func readLines(fromFile fileName: String, withExtension ext: String) -> Array<String> {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: ext) else {
            logger.error("Util >>> readLines() >>> fileName: \(fileName), invalid URL")
            return []
        }

        guard let data = try? Data(contentsOf: url, options: Data.ReadingOptions.mappedIfSafe) else {
            return []
        }

        guard let string = String(data: data, encoding: .utf8) else {
            return []
        }

        return string.split(separator: "\n").map { line in String(line) }
    }

    static func getAppName() -> String? {
        Bundle.main.infoDictionary?["CFBundleName"] as? String
    }

    static func getAppDisplayName() -> String {
        Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? getAppName() ?? "App Display Name"
    }

    static func getAppVersion() -> String {
        guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else {
            return ""
        }

        return currentVersion
    }

    static func getAppBuild() -> String {
        let infoDictionaryKey = kCFBundleVersionKey as String
        guard let build = Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String else {
            return ""

        }

        return build
    }

    static func getAppIconName(in bundle: Bundle = .main) -> String? {
        guard let icons = bundle.object(forInfoDictionaryKey: "CFBundleIcons") as? [String: Any],
              let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
              let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
              let iconFileName = iconFiles.last else {
            return nil
        }

        return iconFileName
    }

    static var labelColor: Color {
        get {
#if os(macOS)
            Color(NSColor.labelColor)
#elseif os(iOS)
            Color(UIColor.label)
#else
            Color.primary
#endif
        }
    }

    static var systemBackgroundColor: Color {
        get {
#if os(macOS)
            Color(NSColor.windowBackgroundColor)
#elseif os(iOS)
            Color(UIColor.systemBackground)
#else
            Color.primary
#endif
        }
    }

    static var secondarySystemBackgroundColor: Color {
        get {
#if os(macOS)
            Color(NSColor.controlBackgroundColor)
#elseif os(iOS)
            Color(UIColor.secondarySystemBackground)
#else
            Color.primary
#endif
        }
    }

    static var buttonControlSize: ControlSize {
        get {
#if os(macOS)
            ControlSize.large
#else
            ControlSize.regular
#endif
        }
    }

    static func copyToClipboard(text: String) {
#if os(iOS)
        UIPasteboard.general.string = text
#elseif os(macOS)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
#endif
    }

    static func isEmailValid(_ email: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$", options: [.caseInsensitive])
        return regex.firstMatch(in: email, options: [], range: NSRange(location: 0, length: email.utf16.count)) != nil
    }

    static func select(word: String, in str: String) -> AttributedString {
        var result = try! AttributedString(markdown: str)

        if !word.isEmpty, let range = result.range(of: word, options: [.caseInsensitive]) {
            var container = AttributeContainer()
            container.foregroundColor = .orange
            container.font = .title3.bold()
            result[range].mergeAttributes(container)
        }

        return result
    }

    /// Функція для извлеченія всѣхъ URL-адресовъ изъ заданной строки
    ///
    /// - Parameter text: Исходный текстъ съ ссылками.
    /// - Returns: Массивъ найденныхъ URL въ видѣ объектовъ URL.
    static func extractURLs(from text: String) -> [URL] {
        var urls: [URL] = []

        do {
            // Создаемъ детекторъ данныхъ, указавъ типъ сущности .link
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)

            // Осуществляемъ поискъ совпаденій во всемъ діапазонѣ строки
            let matches = detector.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))

            // Перебираемъ найденныя совпаденія и извлекаемъ URL
            for match in matches {
                guard let url = match.url else { continue }
                urls.append(url)
            }
        } catch {
            // Обработка возможныхъ ошибокъ при созданіи детектора
            logger.error("Ошибка при созданіи детектора данныхъ: \(error.localizedDescription)")
        }

        return urls
    }

    static func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)

        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }

        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }

        return String(nonce)
    }

    static func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)

        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()

        return hashString
    }
}
