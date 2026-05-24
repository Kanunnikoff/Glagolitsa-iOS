//
//  ChatMessage.swift
//  Glagolitsa
//
//  Created by Kanunnikov Dmitriy  on 4/26/25.
//

import Foundation

enum ChatUserScope: String, Codable {
    case user
    case moderator
    case admin
}

struct ChatUserMetadata: Codable {
    let scope: ChatUserScope
    let isGloballyBlocked: Bool
    let globalBlockReason: String?
    
    init(
        scope: ChatUserScope = .user,
        isGloballyBlocked: Bool = false,
        globalBlockReason: String? = nil
    ) {
        self.scope = scope
        self.isGloballyBlocked = isGloballyBlocked
        self.globalBlockReason = globalBlockReason
    }
}

struct ChatMessage: Codable, Equatable {
    let id: String
    let userId: String
    let userName: String
    let text: String
    let quotedChatMessageId: String?
    let createDate: Date
    let editDate: Date?
    
    init(
        id: String,
        userId: String,
        userName: String,
        text: String,
        quotedChatMessageId: String? = nil,
        createDate: Date = .now,
        editDate: Date? = nil
    ) {
        self.id = id
        self.userId = userId
        self.userName = userName
        self.text = text
        self.quotedChatMessageId = quotedChatMessageId
        self.createDate = createDate
        self.editDate = editDate
    }
    
    static var stub: ChatMessage {
        get {
            .init(
                id: "123",
                userId: "123",
                userName: "Test User",
                text: "Hello, world!"
            )
        }
    }
}
