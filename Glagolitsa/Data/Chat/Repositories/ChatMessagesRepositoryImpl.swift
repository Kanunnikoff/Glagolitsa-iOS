//
//  ChatMessagesRepositoryImpl.swift
//  Yat
//
//  Created by Kanunnikov Dmitriy  on 27.04.2025.
//

import FirebaseFirestore

class ChatMessagesRepositoryImpl : ChatMessagesRepository {
    
    let chatMessagesDataSource: ChatMessagesDataSource
    
    init(chatMessagesDataSource: ChatMessagesDataSource) {
        self.chatMessagesDataSource = chatMessagesDataSource
    }
    
    func getAll() -> AsyncThrowingStream<[ChatMessage], Error> {
        chatMessagesDataSource.getAll()
    }
    
    func getAllForUser(userId: String) async throws -> [ChatMessage] {
        try await chatMessagesDataSource.getAllForUser(userId: userId)
    }
    
    func add(
        userId: String,
        userName: String,
        text: String,
        quotedChatMessageId: String?
    ) async throws -> DocumentReference {
        try await chatMessagesDataSource.add(
            userId: userId,
            userName: userName,
            text: text,
            quotedChatMessageId: quotedChatMessageId
        )
    }
    
    func edit(messageId: String, newText: String) async throws {
        try await chatMessagesDataSource.edit(messageId: messageId, newText: newText)
    }
    
    func delete(messageId: String) async throws {
        try await chatMessagesDataSource.delete(messageId: messageId)
    }
}
