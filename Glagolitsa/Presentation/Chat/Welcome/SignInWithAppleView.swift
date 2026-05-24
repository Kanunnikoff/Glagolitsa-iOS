//
//  SignInWithAppleView.swift
//  Yat
//
//  Created by Kanunnikov Dmitriy  on 03.11.2025.
//

import SwiftUI
import AuthenticationServices
import FirebaseAuth

struct SignInWithAppleView: View {
    
    let label: SignInWithAppleButton.Label
    let signInCallback: (String, String?, PersonNameComponents?, Error?) -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    // Unhashed nonce.
    @State private var currentNonce: String? = nil
    
    var body: some View {
        SignInWithAppleButton(label) { request in
            let nonce = Util.randomNonceString()
            self.currentNonce = nonce
            
            request.requestedScopes = [.fullName]
            request.nonce = Util.sha256(nonce)
        } onCompletion: { result in
            switch result {
                case .success(let authorization):
                    handleSuccessfulLogin(with: authorization)
                case .failure(let error):
                    handleLoginError(with: error)
            }
        }
        .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
        .cornerRadius(50)
        .frame(height: 50)
    }
    
    private func handleSuccessfulLogin(with authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                signInCallback("", nonce, appleIDCredential.fullName, nil)
                return
            }
            
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                signInCallback("", nonce, appleIDCredential.fullName, nil)
                return
            }
            
            signInCallback(idTokenString, nonce, appleIDCredential.fullName, nil)
        }
    }
    
    private func handleLoginError(with error: Error) {
        print("Could not authenticate: \(error.localizedDescription)")
        signInCallback("", nil, nil, error)
    }
}

#Preview {
    SignInWithAppleView(label: .signIn) { idTokenString, nonce, fullName, error in
        // Nothing to do
    }
}
