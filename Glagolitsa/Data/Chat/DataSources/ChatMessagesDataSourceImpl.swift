//
//  ChatMessagesDataSourceImpl.swift
//  Yat
//
//  Created by Kanunnikov Dmitriy  on 27.04.2025.
//

import FirebaseFirestore
import OSLog

private struct ChatMessageNetworkModel: Codable {
    let userId: String
    let userName: String
    let text: String
    let quotedChatMessageId: String?
    let createDate: Date
    let editDate: Date?
    
    init(
        userId: String,
        userName: String,
        text: String,
        quotedChatMessageId: String? = nil,
        createDate: Date = .now,
        editDate: Date? = nil
    ) {
        self.userId = userId
        self.userName = userName
        self.text = text
        self.quotedChatMessageId = quotedChatMessageId
        self.createDate = createDate
        self.editDate = editDate
    }
}

class ChatMessagesDataSourceImpl : ChatMessagesDataSource {
    
    private let logger = MyLogger(category: "ChatMessagesDataSourceImpl")
    
    private let MESSAGES_COLLECTION_NAME = "chat_messages"
    private let MESSAGES_COLLECTION_SIZE = 1_000
    
    private let DOCUMENT_USER_ID_FIELD = "userId"
    private let DOCUMENT_USER_NAME_FIELD = "userName"
    private let DOCUMENT_TEXT_FIELD = "text"
    private let DOCUMENT_QUOTED_CHAT_MESSAGE_ID_FIELD = "quotedMessageId"
    private let DOCUMENT_CREATE_DATE_FIELD = "createDate"
    private let DOCUMENT_EDIT_DATE_FIELD = "editDate"
    
    private let firestore: Firestore = Firestore.firestore()
    
    func getAll() -> AsyncThrowingStream<[ChatMessage], Error> {
        AsyncThrowingStream { continuation in
            let registration = firestore.collection(MESSAGES_COLLECTION_NAME)
                .order(by: DOCUMENT_CREATE_DATE_FIELD, descending: false)
                .limit(toLast: MESSAGES_COLLECTION_SIZE)
                .addSnapshotListener { snapshot, error in
                    if let error = error {
                        continuation.finish(throwing: error)
                    }
                    
                    let chatMessages = snapshot?.documents.compactMap { document in
                        let message = try? document.data(as: ChatMessageNetworkModel.self)
                        
                        // Почему-то не докодируется в message - там оно всегда nil...
                        let quotedChatMessageId = document.data()[self.DOCUMENT_QUOTED_CHAT_MESSAGE_ID_FIELD] as? String
                        
                        return if let message = message {
                            ChatMessage(
                                id: document.documentID,
                                userId: message.userId,
                                userName: message.userName,
                                text: message.text,
                                quotedChatMessageId: quotedChatMessageId,
                                createDate: message.createDate,
                                editDate: message.editDate
                            )
                        } else {
                            nil as ChatMessage?
                        }
                    }
                    
                    continuation.yield(chatMessages ?? [])
                }
            
            continuation.onTermination = { @Sendable _ in
                registration.remove()
            }
        }
    }
    
    func getAllForUser(userId: String) async throws -> [ChatMessage] {
        let snapshot = try await firestore.collection(MESSAGES_COLLECTION_NAME)
            .whereField(DOCUMENT_USER_ID_FIELD, isEqualTo: userId)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            let message = try? document.data(as: ChatMessageNetworkModel.self)
            
            // Почему-то не докодируется в message - там оно всегда nil...
            let quotedChatMessageId = document.data()[self.DOCUMENT_QUOTED_CHAT_MESSAGE_ID_FIELD] as? String
            
            return if let message = message {
                ChatMessage(
                    id: document.documentID,
                    userId: message.userId,
                    userName: message.userName,
                    text: message.text,
                    quotedChatMessageId: quotedChatMessageId,
                    createDate: message.createDate,
                    editDate: message.editDate
                )
            } else {
                nil as ChatMessage?
            }
        }
    }
    
    func add(
        userId: String,
        userName: String,
        text: String,
        quotedChatMessageId: String?
    ) async throws -> DocumentReference {
        let data: [String: Any] = [
            DOCUMENT_USER_ID_FIELD: userId,
            DOCUMENT_USER_NAME_FIELD: userName,
            DOCUMENT_TEXT_FIELD: text,
            DOCUMENT_QUOTED_CHAT_MESSAGE_ID_FIELD: quotedChatMessageId as Any,
            DOCUMENT_CREATE_DATE_FIELD: Date.now
        ]
        
        return try await firestore.collection(MESSAGES_COLLECTION_NAME)
            .addDocument(data: data)
    }
    
    func edit(messageId: String, newText: String) async throws {
        try await firestore.collection(MESSAGES_COLLECTION_NAME)
            .document(messageId)
            .updateData([
                DOCUMENT_TEXT_FIELD: newText,
                DOCUMENT_EDIT_DATE_FIELD: Date.now
            ])
    }
    
    func delete(messageId: String) async throws {
        try await firestore.collection(MESSAGES_COLLECTION_NAME)
            .document(messageId)
            .delete()
    }
    
}
