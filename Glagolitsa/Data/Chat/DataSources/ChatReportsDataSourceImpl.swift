//
//  ChatReportsDataSourceImpl.swift
//  Yat
//
//  Created by Codex on 08.03.2026.
//

import Foundation
import FirebaseFirestore

private struct ChatMessageReportNetworkModel: Codable {
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

final class ChatReportsDataSourceImpl: ChatReportsDataSource {
    private let firestore: Firestore = Firestore.firestore()

    private let REPORTS_COLLECTION_NAME = "chat_message_reports"
    private let FIELD_MESSAGE_ID = "messageId"
    private let FIELD_REPORTED_USER_ID = "reportedUserId"
    private let FIELD_IS_ACTIVE = "isActive"
    private let FIELD_RESOLVE_DATE = "resolveDate"
    private let FIELD_RESOLVE_REASON = "resolveReason"

    func add(
        messageId: String,
        messageText: String,
        reporterUserId: String,
        reporterUserName: String,
        reportedUserId: String,
        reportedUserName: String,
        reason: String
    ) async throws {
        let report = ChatMessageReportNetworkModel(
            messageId: messageId,
            messageText: messageText,
            reporterUserId: reporterUserId,
            reporterUserName: reporterUserName,
            reportedUserId: reportedUserId,
            reportedUserName: reportedUserName,
            reason: reason,
            createDate: .now,
            isActive: true,
            resolveDate: nil,
            resolveReason: nil
        )

        _ = try firestore.collection(REPORTS_COLLECTION_NAME)
            .addDocument(from: report)
    }

    func getAll() -> AsyncThrowingStream<[ChatMessageReport], Error> {
        AsyncThrowingStream { continuation in
            let registration = firestore.collection(REPORTS_COLLECTION_NAME)
                .order(by: "createDate", descending: true)
                .addSnapshotListener { snapshot, error in
                    if let error {
                        continuation.finish(throwing: error)
                        return
                    }

                    let reports: [ChatMessageReport] = snapshot?.documents.compactMap { document in
                        guard let report = try? document.data(as: ChatMessageReportNetworkModel.self) else {
                            return nil
                        }

                        return ChatMessageReport(
                            id: document.documentID,
                            messageId: report.messageId,
                            messageText: report.messageText,
                            reporterUserId: report.reporterUserId,
                            reporterUserName: report.reporterUserName,
                            reportedUserId: report.reportedUserId,
                            reportedUserName: report.reportedUserName,
                            reason: report.reason,
                            createDate: report.createDate,
                            isActive: report.isActive,
                            resolveDate: report.resolveDate,
                            resolveReason: report.resolveReason
                        )
                    } ?? []

                    continuation.yield(reports)
                }

            continuation.onTermination = { @Sendable _ in
                registration.remove()
            }
        }
    }
    
    func resolveReportsForMessage(messageId: String, reason: String) async throws {
        let snapshot = try await firestore.collection(REPORTS_COLLECTION_NAME)
            .whereField(FIELD_MESSAGE_ID, isEqualTo: messageId)
            .whereField(FIELD_IS_ACTIVE, isEqualTo: true)
            .getDocuments()
        
        try await resolveReports(snapshot.documents, reason: reason)
    }
    
    func resolveReportsForReportedUser(reportedUserId: String, reason: String) async throws {
        let snapshot = try await firestore.collection(REPORTS_COLLECTION_NAME)
            .whereField(FIELD_REPORTED_USER_ID, isEqualTo: reportedUserId)
            .whereField(FIELD_IS_ACTIVE, isEqualTo: true)
            .getDocuments()
        
        try await resolveReports(snapshot.documents, reason: reason)
    }
    
    private func resolveReports(_ documents: [QueryDocumentSnapshot], reason: String) async throws {
        guard !documents.isEmpty else { return }
        
        let batch = firestore.batch()
        
        for document in documents {
            batch.updateData(
                [
                    FIELD_IS_ACTIVE: false,
                    FIELD_RESOLVE_DATE: Date.now,
                    FIELD_RESOLVE_REASON: reason
                ],
                forDocument: document.reference
            )
        }
        
        try await batch.commit()
    }
}
