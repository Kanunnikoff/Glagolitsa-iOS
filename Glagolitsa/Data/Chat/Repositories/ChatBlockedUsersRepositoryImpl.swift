//
//  ChatBlockedUsersRepositoryImpl.swift
//  Yat
//
//  Created by Codex on 08.03.2026.
//

import Foundation

final class ChatBlockedUsersRepositoryImpl: ChatBlockedUsersRepository {
    private let chatBlockedUsersDataSource: ChatBlockedUsersDataSource

    init(chatBlockedUsersDataSource: ChatBlockedUsersDataSource) {
        self.chatBlockedUsersDataSource = chatBlockedUsersDataSource
    }

    func subscribeBlockedUserIds(userId: String) -> AsyncThrowingStream<Set<String>, Error> {
        chatBlockedUsersDataSource.subscribeBlockedUserIds(userId: userId)
    }

    func block(userId: String, blockedUserId: String) async throws {
        try await chatBlockedUsersDataSource.block(userId: userId, blockedUserId: blockedUserId)
    }

    func unblock(userId: String, blockedUserId: String) async throws {
        try await chatBlockedUsersDataSource.unblock(userId: userId, blockedUserId: blockedUserId)
    }
}
