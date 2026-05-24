//
//  ChatUserScopesRepositoryImpl.swift
//  Yat
//
//  Created by Codex on 08.03.2026.
//

import Foundation

final class ChatUserScopesRepositoryImpl: ChatUserScopesRepository {
    
    private let chatUserScopesDataSource: ChatUserScopesDataSource

    init(chatUserScopesDataSource: ChatUserScopesDataSource) {
        self.chatUserScopesDataSource = chatUserScopesDataSource
    }

    func getScope(userId: String) async throws -> ChatUserScope? {
        try await chatUserScopesDataSource.getScope(userId: userId)
    }

    func setScope(userId: String, scope: ChatUserScope) async throws {
        try await chatUserScopesDataSource.setScope(userId: userId, scope: scope)
    }
    
    func getMetadata(userId: String) async throws -> ChatUserMetadata? {
        try await chatUserScopesDataSource.getMetadata(userId: userId)
    }
    
    func setGlobalBlock(userId: String, reason: String) async throws {
        try await chatUserScopesDataSource.setGlobalBlock(userId: userId, reason: reason)
    }
    
    func clearGlobalBlock(userId: String) async throws {
        try await chatUserScopesDataSource.clearGlobalBlock(userId: userId)
    }
    
    func subscribeToMetadata(userId: String) -> AsyncThrowingStream<ChatUserMetadata, Error> {
        chatUserScopesDataSource.subscribeToMetadata(userId: userId)
    }
}
