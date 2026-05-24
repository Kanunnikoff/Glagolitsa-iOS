//
//  AuthRepositoryImpl.swift
//  Yat
//
//  Created by Kanunnikov Dmitriy  on 4/26/25.
//

import FirebaseAuth

class AuthRepositoryImpl: AuthRepository {
    
    private let authDataSource: AuthDataSource
    
    init(authDataSource: AuthDataSource) {
        self.authDataSource = authDataSource
    }
    
    func signUp(
        email: String,
        password: String,
        completion: @escaping (AuthDataResult?, Error?) -> Void
    ) {
        authDataSource.signUp(
            email: email,
            password: password,
            completion: completion
        )
    }
    
    func signIn(
        email: String,
        password: String,
        completion: @escaping (AuthDataResult?, Error?) -> Void
    ) {
        authDataSource.signIn(
            email: email,
            password: password,
            completion: completion
        )
    }
    
    func signIn(
        withIDToken idToken: String,
        rawNonce: String?,
        fullName: PersonNameComponents?,
        completion: @escaping (AuthDataResult?, Error?) -> Void
    ) {
        authDataSource.signIn(
            withIDToken: idToken,
            rawNonce: rawNonce,
            fullName: fullName,
            completion: completion
        )
    }
    
    func verifyBeforeUpdateEmail(email: String) async throws {
        try await authDataSource.verifyBeforeUpdateEmail(email: email)
    }
    
    func sendEmailVerification() async throws {
        try await authDataSource.sendEmailVerification()
    }
    
    func updatePassword(password: String) async throws {
        try await authDataSource.updatePassword(password: password)
    }
    
    func sendPasswordResetEmail(email: String) async throws {
        try await authDataSource.sendPasswordResetEmail(email: email)
    }
    
    func reauthenticate(email: String, password: String) async throws {
        try await authDataSource.reauthenticate(email: email, password: password)
    }
    
    func reauthenticate(appleIdToken: String, rawNonce: String) async throws -> AuthDataResult? {
        try await authDataSource.reauthenticate(
            appleIdToken: appleIdToken,
            rawNonce: rawNonce
        )
    }
    
    func changeUserName(name: String) async throws {
        try await authDataSource.changeUserName(name: name)
    }
    
    func getCurrentUser() -> User? {
        authDataSource.getCurrentUser()
    }
    
    func reload() async throws {
        try await authDataSource.reload()
    }
    
    func subscribeToAuthStateChanges() -> AsyncStream<User?> {
        authDataSource.subscribeToAuthStateChanges()
    }
    
    func signOut() throws {
        try authDataSource.signOut()
    }
    
    func revokeToken(authCodeString: String) async throws {
        try await authDataSource.revokeToken(authCodeString: authCodeString)
    }
    
    func deleteAccount() async throws {
        try await authDataSource.deleteAccount()
    }
}
