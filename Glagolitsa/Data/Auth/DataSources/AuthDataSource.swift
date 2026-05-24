//
//  AuthDataSource.swift
//  Yat
//
//  Created by Kanunnikov Dmitriy  on 4/26/25.
//

import FirebaseAuth

protocol AuthDataSource {
    
    func signUp(
        email: String,
        password: String,
        completion: @escaping (AuthDataResult?, Error?) -> Void
    )
    
    func signIn(
        email: String,
        password: String,
        completion: @escaping (AuthDataResult?, Error?) -> Void
    )
    
    func signIn(
        withIDToken idToken: String,
        rawNonce: String?,
        fullName: PersonNameComponents?,
        completion: @escaping (AuthDataResult?, Error?) -> Void
    )
    
    func verifyBeforeUpdateEmail(email: String) async throws
    
    func sendEmailVerification() async throws
    
    func updatePassword(password: String) async throws
    
    func sendPasswordResetEmail(email: String) async throws
    
    func reauthenticate(email: String, password: String) async throws
    
    func reauthenticate(appleIdToken: String, rawNonce: String) async throws -> AuthDataResult?
    
    func changeUserName(name: String) async throws
    
    func getCurrentUser() -> User?
    
    func reload() async throws
    
    func subscribeToAuthStateChanges() -> AsyncStream<User?>
    
    func signOut() throws
    
    func revokeToken(authCodeString: String) async throws
    
    func deleteAccount() async throws
}
