//
//  ChatUserScopesRepository.swift
//  Yat
//
//  Created by Codex on 08.03.2026.
//

import Foundation

protocol ChatUserScopesRepository {
    func getScope(userId: String) async throws -> ChatUserScope?
    func setScope(userId: String, scope: ChatUserScope) async throws
    func getMetadata(userId: String) async throws -> ChatUserMetadata?
    func setGlobalBlock(userId: String, reason: String) async throws
    func clearGlobalBlock(userId: String) async throws
    func subscribeToMetadata(userId: String) -> AsyncThrowingStream<ChatUserMetadata, Error>
}
