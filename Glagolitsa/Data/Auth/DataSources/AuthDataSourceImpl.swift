//
//  AuthDataSourceImpl.swift
//  Yat
//
//  Created by Kanunnikov Dmitriy  on 4/26/25.
//

import Foundation
import FirebaseAuth
import AuthenticationServices
#if !os(macOS)
import UIKit
#endif

class AuthDataSourceImpl: AuthDataSource {

    private let auth: Auth = Auth.auth()

    init() {
        auth.useAppLanguage()
    }

    func signUp(
        email: String,
        password: String,
        completion: @escaping (AuthDataResult?, Error?) -> Void
    ) {
        auth.createUser(
            withEmail: email,
            password: password,
            completion: completion
        )
    }

    func signIn(
        email: String,
        password: String,
        completion: @escaping (AuthDataResult?, Error?) -> Void
    ) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard self != nil else { return }

            completion(authResult, error)
        }
    }

    func signIn(
        withIDToken idToken: String,
        rawNonce: String?,
        fullName: PersonNameComponents?,
        completion: @escaping (AuthDataResult?, Error?) -> Void
    ) {
        let newFullName = if fullName?.givenName == nil {
            AnonymousUserName.personNameComponents
        } else {
            fullName
        }

        let credential = OAuthProvider.appleCredential(
            withIDToken: idToken,
            rawNonce: rawNonce,
            fullName: newFullName
        )

        Auth.auth().signIn(with: credential) { authResult, error in
            completion(authResult, error)
        }
    }

    func verifyBeforeUpdateEmail(email: String) async throws {
        try await auth.currentUser?.sendEmailVerification(beforeUpdatingEmail: email)
    }

    func sendEmailVerification() async throws {
        try await auth.currentUser?.sendEmailVerification()
    }

    func updatePassword(password: String) async throws {
        try await auth.currentUser?.updatePassword(to: password)
    }

    func sendPasswordResetEmail(email: String) async throws {
        try await auth.sendPasswordReset(withEmail: email)
    }

    func reauthenticate(email: String, password: String) async throws {
        let authCredential = EmailAuthProvider.credential(withEmail: email, password: password)

        try await auth.currentUser?.reauthenticate(with: authCredential)
    }

    func reauthenticate(appleIdToken: String, rawNonce: String) async throws -> AuthDataResult? {
        let credential = OAuthProvider.credential(
            providerID: AuthProviderID.apple,
            idToken: appleIdToken,
            rawNonce: rawNonce
        )

        return try await auth.currentUser?.reauthenticate(with: credential)
    }

    func changeUserName(name: String) async throws {
        let request = auth.currentUser?.createProfileChangeRequest()
        request?.displayName = name

        try await request?.commitChanges()
    }

    func getCurrentUser() -> User? {
        auth.currentUser
    }

    func reload() async throws {
        try await auth.currentUser?.reload()
    }

    func subscribeToAuthStateChanges() -> AsyncStream<User?> {
        AsyncStream { continuation in
            let listener = Auth.auth().addStateDidChangeListener { auth, user in
                continuation.yield(user)
            }

            continuation.onTermination = { @Sendable _ in
                Auth.auth().removeStateDidChangeListener(listener)
            }
        }
    }

    func signOut() throws {
        try auth.signOut()
    }

    func revokeToken(authCodeString: String) async throws {
        try await auth.revokeToken(withAuthorizationCode: authCodeString)
    }

    func deleteAccount() async throws {
        try await auth.currentUser?.delete()
    }
}

private enum AnonymousUserName {

    static let givenNamePrefix = "Anonymous"

    static var personNameComponents: PersonNameComponents {
        PersonNameComponents(givenName: "\(givenNamePrefix) \(deviceName)")
    }

    private static var deviceName: String {
#if os(macOS)
        ProcessInfo.processInfo.hostName
#else
        UIDevice.current.name
#endif
    }
}
