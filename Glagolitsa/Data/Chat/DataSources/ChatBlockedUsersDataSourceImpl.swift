//
//  ChatBlockedUsersDataSourceImpl.swift
//  Yat
//
//  Created by Codex on 08.03.2026.
//

import Foundation
import FirebaseFirestore

final class ChatBlockedUsersDataSourceImpl: ChatBlockedUsersDataSource {
    private let firestore: Firestore = Firestore.firestore()

    private let CHAT_USERS_COLLECTION_NAME = "chat_users"
    private let BLOCKED_USERS_COLLECTION_NAME = "blocked_users"
    private let FIELD_BLOCK_DATE = "blockDate"

    func subscribeBlockedUserIds(userId: String) -> AsyncThrowingStream<Set<String>, Error> {
        AsyncThrowingStream { continuation in
            let registration = firestore
                .collection(CHAT_USERS_COLLECTION_NAME)
                .document(userId)
                .collection(BLOCKED_USERS_COLLECTION_NAME)
                .addSnapshotListener { snapshot, error in
                    if let error {
                        continuation.finish(throwing: error)
                        return
                    }

                    let blockedUserIds = Set(snapshot?.documents.map(\.documentID) ?? [])
                    continuation.yield(blockedUserIds)
                }

            continuation.onTermination = { @Sendable _ in
                registration.remove()
            }
        }
    }

    func block(userId: String, blockedUserId: String) async throws {
        try await firestore
            .collection(CHAT_USERS_COLLECTION_NAME)
            .document(userId)
            .collection(BLOCKED_USERS_COLLECTION_NAME)
            .document(blockedUserId)
            .setData([
                FIELD_BLOCK_DATE: Date.now
            ], merge: true)
    }

    func unblock(userId: String, blockedUserId: String) async throws {
        try await firestore
            .collection(CHAT_USERS_COLLECTION_NAME)
            .document(userId)
            .collection(BLOCKED_USERS_COLLECTION_NAME)
            .document(blockedUserId)
            .delete()
    }
}
