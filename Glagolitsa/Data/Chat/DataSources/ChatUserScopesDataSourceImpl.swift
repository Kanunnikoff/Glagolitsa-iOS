//
//  ChatUserScopesDataSourceImpl.swift
//  Yat
//
//  Created by Codex on 08.03.2026.
//

import Foundation
import FirebaseFirestore

final class ChatUserScopesDataSourceImpl: ChatUserScopesDataSource {
    
    private let firestore: Firestore = Firestore.firestore()

    private let CHAT_USERS_COLLECTION_NAME = "chat_users"
    private let CHAT_USER_SCOPE_FIELD = "scope"
    private let CHAT_USER_IS_GLOBALLY_BLOCKED_FIELD = "isGloballyBlocked"
    private let CHAT_USER_GLOBAL_BLOCK_REASON_FIELD = "globalBlockReason"
    private let CHAT_USER_GLOBAL_BLOCK_DATE_FIELD = "globalBlockDate"
    private let CHAT_USER_UPDATE_DATE_FIELD = "updateDate"

    func getScope(userId: String) async throws -> ChatUserScope? {
        let document = try await firestore.collection(CHAT_USERS_COLLECTION_NAME)
            .document(userId)
            .getDocument()

        guard
            let data = document.data(),
            let rawScope = data[CHAT_USER_SCOPE_FIELD] as? String
        else {
            return nil
        }

        return ChatUserScope(rawValue: rawScope)
    }

    func setScope(userId: String, scope: ChatUserScope) async throws {
        try await firestore.collection(CHAT_USERS_COLLECTION_NAME)
            .document(userId)
            .setData([
                CHAT_USER_SCOPE_FIELD: scope.rawValue,
                CHAT_USER_UPDATE_DATE_FIELD: Date.now
            ], merge: true)
    }
    
    func getMetadata(userId: String) async throws -> ChatUserMetadata? {
        let document = try await firestore.collection(CHAT_USERS_COLLECTION_NAME)
            .document(userId)
            .getDocument()
        
        guard let data = document.data() else {
            return nil
        }
        
        let scope: ChatUserScope
        if
            let rawScope = data[CHAT_USER_SCOPE_FIELD] as? String,
            let parsedScope = ChatUserScope(rawValue: rawScope)
        {
            scope = parsedScope
        } else {
            scope = .user
        }
        
        let isGloballyBlocked = data[CHAT_USER_IS_GLOBALLY_BLOCKED_FIELD] as? Bool ?? false
        let globalBlockReason = data[CHAT_USER_GLOBAL_BLOCK_REASON_FIELD] as? String
        
        return ChatUserMetadata(
            scope: scope,
            isGloballyBlocked: isGloballyBlocked,
            globalBlockReason: globalBlockReason
        )
    }
    
    func setGlobalBlock(userId: String, reason: String) async throws {
        try await firestore.collection(CHAT_USERS_COLLECTION_NAME)
            .document(userId)
            .setData([
                CHAT_USER_IS_GLOBALLY_BLOCKED_FIELD: true,
                CHAT_USER_GLOBAL_BLOCK_REASON_FIELD: reason,
                CHAT_USER_GLOBAL_BLOCK_DATE_FIELD: Date.now,
                CHAT_USER_UPDATE_DATE_FIELD: Date.now
            ], merge: true)
    }
    
    func clearGlobalBlock(userId: String) async throws {
        try await firestore.collection(CHAT_USERS_COLLECTION_NAME)
            .document(userId)
            .setData([
                CHAT_USER_IS_GLOBALLY_BLOCKED_FIELD: false,
                CHAT_USER_GLOBAL_BLOCK_REASON_FIELD: FieldValue.delete(),
                CHAT_USER_GLOBAL_BLOCK_DATE_FIELD: FieldValue.delete(),
                CHAT_USER_UPDATE_DATE_FIELD: Date.now
            ], merge: true)
    }
    
    func subscribeToMetadata(userId: String) -> AsyncThrowingStream<ChatUserMetadata, Error> {
        AsyncThrowingStream { continuation in
            let registration = firestore.collection(CHAT_USERS_COLLECTION_NAME)
                .document(userId)
                .addSnapshotListener { snapshot, error in
                    if let error {
                        continuation.finish(throwing: error)
                        return
                    }
                    
                    guard let data = snapshot?.data() else {
                        continuation.yield(ChatUserMetadata())
                        return
                    }
                    
                    let scope: ChatUserScope
                    if
                        let rawScope = data[self.CHAT_USER_SCOPE_FIELD] as? String,
                        let parsedScope = ChatUserScope(rawValue: rawScope)
                    {
                        scope = parsedScope
                    } else {
                        scope = .user
                    }
                    
                    continuation.yield(
                        ChatUserMetadata(
                            scope: scope,
                            isGloballyBlocked: data[self.CHAT_USER_IS_GLOBALLY_BLOCKED_FIELD] as? Bool ?? false,
                            globalBlockReason: data[self.CHAT_USER_GLOBAL_BLOCK_REASON_FIELD] as? String
                        )
                    )
                }
            
            continuation.onTermination = { @Sendable _ in
                registration.remove()
            }
        }
    }
}
