//
//  ChatMessagesRepository.swift
//  Yat
//
//  Created by Kanunnikov Dmitriy  on 27.04.2025.
//

import FirebaseFirestore

protocol ChatMessagesRepository {
    
    func getAll() -> AsyncThrowingStream<[ChatMessage], Error>
    
    func getAllForUser(userId: String) async throws -> [ChatMessage]
    
    func add(
        userId: String,
        userName: String,
        text: String,
        quotedChatMessageId: String?
    ) async throws -> DocumentReference
    
    func edit(messageId: String, newText: String) async throws
    
    func delete(messageId: String) async throws
}
