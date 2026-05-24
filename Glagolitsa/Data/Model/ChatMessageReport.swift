//
//  ChatMessageReport.swift
//  Glagolitsa
//
//  Created by Codex on 08.03.2026.
//

import Foundation

struct ChatMessageReport: Identifiable, Codable, Equatable {
    let id: String
    let messageId: String
    let messageText: String
    let reporterUserId: String
    let reporterUserName: String
    let reportedUserId: String
    let reportedUserName: String
    let reason: String
    let createDate: Date
    let isActive: Bool
    let resolveDate: Date?
    let resolveReason: String?
}
