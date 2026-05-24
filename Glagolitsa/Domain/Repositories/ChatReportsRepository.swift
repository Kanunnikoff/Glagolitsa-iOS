//
//  ChatReportsRepository.swift
//  Yat
//
//  Created by Codex on 08.03.2026.
//

import Foundation

protocol ChatReportsRepository {
    func add(
        messageId: String,
        messageText: String,
        reporterUserId: String,
        reporterUserName: String,
        reportedUserId: String,
        reportedUserName: String,
        reason: String
    ) async throws

    func getAll() -> AsyncThrowingStream<[ChatMessageReport], Error>
    
    func resolveReportsForMessage(messageId: String, reason: String) async throws
    
    func resolveReportsForReportedUser(reportedUserId: String, reason: String) async throws
}
