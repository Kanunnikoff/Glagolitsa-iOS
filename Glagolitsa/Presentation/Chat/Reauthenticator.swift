//
//  Reauthenticator.swift
//  Yat
//
//  Created by Kanunnikov Dmitriy  on 22.11.2025.
//

import Foundation
import AuthenticationServices
import FirebaseAuth
#if os(macOS)
import AppKit
#else
import UIKit
#endif

class Reauthenticator: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

    private let logger = MyLogger(category: "Reauthenticator")

    private var reauthorizateCallback: ((String?, String?, String?, Error?) -> Void)? = nil
    private var currentNonce: String? = nil

    func reauthenticate(reauthorizateCallback: @escaping (String?, String?, String?, Error?) -> Void) {
        self.reauthorizateCallback = reauthorizateCallback

        let nonce = Util.randomNonceString()
        currentNonce = nonce

        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName]
        request.nonce = Util.sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    // MARK: - ASAuthorizationControllerDelegate

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            logger.error("Unable to retrieve AppleIDCredential")
            reauthorizateCallback?(nil, nil, nil, nil)
            return
        }

        guard let nonce = currentNonce else {
            fatalError("Invalid state: A login callback was received, but no login request was sent.")
        }

        guard let appleIDToken = String(data: appleIDCredential.identityToken!, encoding: .utf8) else {
            logger.error("Unable to fetch identity token")
            reauthorizateCallback?(nil, nil, nonce, nil)
            return
        }

        guard let appleAuthCode = appleIDCredential.authorizationCode else {
            logger.error("Unable to fetch authorization code")
            reauthorizateCallback?(appleIDToken, nil, nonce, nil)
            return
        }

        // Нужен для Auth.auth().revokeToken(withAuthorizationCode: authCodeString), но сейчас не используется
        guard let authCodeString = String(data: appleAuthCode, encoding: .utf8) else {
            logger.error("Unable to serialize auth code string from data: \(appleAuthCode.debugDescription)")
            reauthorizateCallback?(appleIDToken, nil, nonce, nil)
            return
        }

        reauthorizateCallback?(appleIDToken, authCodeString, nonce, nil)
    }

    // MARK: - ASAuthorizationControllerPresentationContextProviding

    // Нужно указать, где показывать окно входа Apple.
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let window = currentPresentationWindow else {
            fatalError(ReauthenticatorText.missingPresentationWindow)
        }

        return window
    }

    private var currentPresentationWindow: ASPresentationAnchor? {
#if os(macOS)
        NSApplication.shared.keyWindow
        ?? NSApplication.shared.mainWindow
        ?? NSApplication.shared.windows.first
#else
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)
#endif
    }
}

private enum ReauthenticatorText {

    static let missingPresentationWindow = "Нет активного окна для отображения входа Apple."
}
