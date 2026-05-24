//
//  ChatReportsRepositoryImpl.swift
//  Yat
//
//  Created by Codex on 08.03.2026.
//

import Foundation

final class ChatReportsRepositoryImpl: ChatReportsRepository {
    private let chatReportsDataSource: ChatReportsDataSource

    init(chatReportsDataSource: ChatReportsDataSource) {
        self.chatReportsDataSource = chatReportsDataSource
    }

    func add(
        messageId: String,
        messageText: String,
        reporterUserId: String,
        reporterUserName: String,
        reportedUserId: String,
        reportedUserName: String,
        reason: String
    ) async throws {
        try await chatReportsDataSource.add(
            messageId: messageId,
            messageText: messageText,
            reporterUserId: reporterUserId,
            reporterUserName: reporterUserName,
            reportedUserId: reportedUserId,
            reportedUserName: reportedUserName,
            reason: reason
        )
    }

    func getAll() -> AsyncThrowingStream<[ChatMessageReport], Error> {
        chatReportsDataSource.getAll()
    }
    
    func resolveReportsForMessage(messageId: String, reason: String) async throws {
        try await chatReportsDataSource.resolveReportsForMessage(messageId: messageId, reason: reason)
    }
    
    func resolveReportsForReportedUser(reportedUserId: String, reason: String) async throws {
        try await chatReportsDataSource.resolveReportsForReportedUser(
            reportedUserId: reportedUserId,
            reason: reason
        )
    }
}
