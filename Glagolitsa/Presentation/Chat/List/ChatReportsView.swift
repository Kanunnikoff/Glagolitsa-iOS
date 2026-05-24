//
//  ChatReportsView.swift
//  Yat
//
//  Created by Codex on 08.03.2026.
//

import SwiftUI

struct ChatReportsView: View {
    @Environment(\.dismiss) private var dismiss

    let reports: [ChatMessageReport]
    let onDeleteMessage: (String) -> Void
    let onGlobalBlockUser: (ChatMessageReport) -> Void
    let onUnblockGlobalUser: (ChatMessageReport) -> Void

    private enum Layout {
        static let rowVerticalPadding: CGFloat = 6
        static let detailsSpacing: CGFloat = 8

#if os(macOS)
        static let sheetMinWidth: CGFloat = 640
        static let sheetIdealWidth: CGFloat = 760
        static let sheetMinHeight: CGFloat = 420
        static let sheetIdealHeight: CGFloat = 540
        static let headerHorizontalPadding: CGFloat = 24
        static let headerVerticalPadding: CGFloat = 18
        static let contentPadding: CGFloat = 20
        static let rowSpacing: CGFloat = 16
        static let actionSpacing: CGFloat = 8
        static let actionButtonWidth: CGFloat = 132
#endif
    }

    var body: some View {
#if os(macOS)
        macOSContent
#else
        iOSContent
#endif
    }

#if os(macOS)
    private var macOSContent: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Reports")
                    .font(.title2.weight(.semibold))

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark") // 􀆄
                }
                .buttonStyle(.borderless)
            }
            .padding(.horizontal, Layout.headerHorizontalPadding)
            .padding(.vertical, Layout.headerVerticalPadding)

            Divider()

            Group {
                if reports.isEmpty {
                    ContentUnavailableView {
                        Label("No Reports", systemImage: "checkmark.circle")
                    } description: {
                        Text("New reports from users will appear here.")
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(sortedReports) { report in
                        macOSReportRow(report)
                    }
                    .listStyle(.inset(alternatesRowBackgrounds: true))
                }
            }
            .padding(.horizontal, reports.isEmpty ? Layout.contentPadding : 0)
            .padding(.vertical, reports.isEmpty ? Layout.contentPadding : 0)
        }
        .frame(
            minWidth: Layout.sheetMinWidth,
            idealWidth: Layout.sheetIdealWidth,
            minHeight: Layout.sheetMinHeight,
            idealHeight: Layout.sheetIdealHeight
        )
    }

    private func macOSReportRow(_ report: ChatMessageReport) -> some View {
        HStack(alignment: .top, spacing: Layout.rowSpacing) {
            reportDetails(report)

            Spacer(minLength: Layout.rowSpacing)

            VStack(alignment: .trailing, spacing: Layout.actionSpacing) {
                macOSReportActions(report)
            }
        }
        .padding(.vertical, Layout.rowVerticalPadding)
        .opacity(report.isActive ? 1 : 0.45)
        .contextMenu {
            reportContextMenu(report)
        }
    }

    @ViewBuilder
    private func macOSReportActions(_ report: ChatMessageReport) -> some View {
        if canUnblockGlobalUser(for: report) {
            Button("Unblock User") {
                onUnblockGlobalUser(report)
            }
            .frame(width: Layout.actionButtonWidth)
        }

        if report.isActive {
            Button("Delete Message", role: .destructive) {
                onDeleteMessage(report.messageId)
            }
            .frame(width: Layout.actionButtonWidth)

            Button("Global Block", role: .destructive) {
                onGlobalBlockUser(report)
            }
            .frame(width: Layout.actionButtonWidth)
        }
    }

    @ViewBuilder
    private func reportContextMenu(_ report: ChatMessageReport) -> some View {
        if canUnblockGlobalUser(for: report) {
            Button("Unblock User") {
                onUnblockGlobalUser(report)
            }
        }

        if report.isActive {
            if canUnblockGlobalUser(for: report) {
                Divider()
            }

            Button("Delete Message", role: .destructive) {
                onDeleteMessage(report.messageId)
            }

            Button("Global Block", role: .destructive) {
                onGlobalBlockUser(report)
            }
        }
    }
#endif

    private var iOSContent: some View {
        NavigationStack {
            Group {
                if reports.isEmpty {
                    ContentUnavailableView {
                        Label("No Reports", systemImage: "checkmark.circle")
                    } description: {
                        Text("New reports from users will appear here.")
                    }
                } else {
                    List(sortedReports) { report in
                        reportDetails(report)
                        .padding(.vertical, Layout.rowVerticalPadding)
                        .opacity(report.isActive ? 1 : 0.45)
                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                            if canUnblockGlobalUser(for: report) {
                                Button("Unblock User") {
                                    onUnblockGlobalUser(report)
                                }
                                .tint(.green)
                            }
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            if report.isActive {
                                Button("Delete Message", role: .destructive) {
                                    onDeleteMessage(report.messageId)
                                }

                                Button("Global Block", role: .destructive) {
                                    onGlobalBlockUser(report)
                                }
                                .tint(.brown)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Reports")
#if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark") // 􀆄
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func reportDetails(_ report: ChatMessageReport) -> some View {
        VStack(alignment: .leading, spacing: Layout.detailsSpacing) {
            Text(report.messageText)
                .font(.body)

            Text("Reported by: \(report.reporterUserName)")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("Reported user: \(report.reportedUserName)")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("Total reports on user: \(reportsCount(for: report.reportedUserId))")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("Reason: \(report.reason)")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(report.createDate.prettyFormat())
                .font(.caption2)
                .foregroundStyle(.secondary)

            if !report.isActive {
                Text("Resolved: \(report.resolveReason ?? "Processed")")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                if let resolveDate = report.resolveDate {
                    Text(resolveDate.prettyFormat())
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func reportsCount(for reportedUserId: String) -> Int {
        reports.filter { $0.reportedUserId == reportedUserId }.count
    }

    private var sortedReports: [ChatMessageReport] {
        reports.sorted {
            if $0.isActive != $1.isActive {
                return $0.isActive && !$1.isActive
            }

            return $0.createDate > $1.createDate
        }
    }

    private func canUnblockGlobalUser(for report: ChatMessageReport) -> Bool {
        guard !report.isActive else { return false }

        let resolveReason = report.resolveReason?.lowercased() ?? ""
        return resolveReason.contains("globally blocked")
    }
}

#Preview {
    ChatReportsView(
        reports: [
            .init(
                id: "r1",
                messageId: "m1",
                messageText: "Offensive sample message",
                reporterUserId: "u1",
                reporterUserName: "Reporter",
                reportedUserId: "u2",
                reportedUserName: "Reported",
                reason: "Inappropriate content",
                createDate: .now,
                isActive: true,
                resolveDate: nil,
                resolveReason: nil
            )
        ],
        onDeleteMessage: { _ in },
        onGlobalBlockUser: { _ in },
        onUnblockGlobalUser: { _ in }
    )
}
