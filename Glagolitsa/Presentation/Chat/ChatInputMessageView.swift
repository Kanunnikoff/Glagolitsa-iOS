//
//  ChatInputMessageView.swift
//  Yat
//
//  Created by Kanunnikov Dmitriy  on 4/26/25.
//

import SwiftUI
import OSLog

struct ChatInputMessageView: View {

    private let logger = MyLogger(category: "ChatInputMessageView")

    @Bindable var viewModel: ChatViewModel
    @Binding var chatMessageForEdit: ChatMessage?
    @Binding var chatMessageForReply: ChatMessage?
    @Binding var showingErrorAlert: Bool
    @Binding var error: Error?

    private enum Layout {
        static let buttonSize: CGFloat = 32

#if os(macOS)
        static let newline = "\n"
        static let inputLineLimit = 3...7
        static let inputCornerRadius: CGFloat = 8
        static let inputBorderWidth: CGFloat = 1
#else
        static let inputLineLimit = 1...7
#endif
    }

    private var canSendMessage: Bool {
        !viewModel.chatMessageDraft.isEmpty && !viewModel.isSendingChatMessage
    }

    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif

        VStack {
            if chatMessageForEdit != nil {
                HStack {
                    VStack {
                    }
                    .frame(maxWidth: 2, maxHeight: 50)
                    .background(Color.accentColor)

                    VStack {
                        Text("Edit Message")
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.accentColor)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text(chatMessageForEdit!.text)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Spacer()

                    Button {
                        withAnimation {
                            chatMessageForEdit = nil
                            viewModel.chatMessageDraft = ""
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill") // 􀁡
                            .resizable()
                            .frame(width: Layout.buttonSize, height: Layout.buttonSize)
                    }
#if os(macOS)
                    .buttonStyle(.plain)
#endif
                }
            }

            if let chatMessage = chatMessageForReply {
                HStack {
                    VStack {
                    }
                    .frame(maxWidth: 2, maxHeight: 50)
                    .background(Color.accentColor)

                    VStack {
                        Text("Reply to \(chatMessage.userName)")
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.accentColor)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text(chatMessage.text)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Spacer()

                    Button {
                        withAnimation {
                            chatMessageForReply = nil
                            viewModel.chatMessageDraft = ""
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill") // 􀁡
                            .resizable()
                            .frame(width: Layout.buttonSize, height: Layout.buttonSize)
                    }
#if os(macOS)
                    .buttonStyle(.plain)
#endif
                }
            }

            HStack {
                TextField("Do you have something to say? Speak up!", text: $viewModel.chatMessageDraft, axis: .vertical)
                    .lineLimit(Layout.inputLineLimit)
#if os(macOS)
                    .textFieldStyle(.plain)
                    .onKeyPress(.return, phases: .down) { keyPress in
                        if keyPress.modifiers.contains(.shift) {
                            insertNewline()
                            return .handled
                        }

                        guard keyPress.modifiers.isEmpty else {
                            return .ignored
                        }

                        guard canSendMessage else {
                            return .handled
                        }

                        submitMessage()
                        return .handled
                    }
#endif
                    .padding()
#if !os(macOS)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(.rect(corners: .concentric, isUniform: true))
#else
                    .overlay {
                        RoundedRectangle(cornerRadius: Layout.inputCornerRadius)
                            .stroke(.separator, lineWidth: Layout.inputBorderWidth)
                    }
#endif
//                    .disabled(viewModel.isSendingChatMessage) // НЕЛЬЗЯ ИСПОЛЬЗОВАТЬ - ИНАЧЕ КЛАВИАТУРА БУДЕТ СКАКАТЬ!!!
                    .lengthValidator(text: $viewModel.chatMessageDraft, maxLength: Config.DEFAULT_MESSAGE_MAX_LENGTH)

                Button {
                    submitMessage()
                } label: {
                    if viewModel.isSendingChatMessage {
                        ProgressView()
                            .frame(width: Layout.buttonSize, height: Layout.buttonSize)
                    } else {
                        if chatMessageForEdit != nil {
                            Image(systemName: "checkmark.circle.fill") // 􀁣
                                .resizable()
                                .frame(width: Layout.buttonSize, height: Layout.buttonSize)
                        } else {
                            Image(systemName: "arrow.up.circle.fill") // 􀁷
                                .resizable()
                                .frame(width: Layout.buttonSize, height: Layout.buttonSize)
                        }
                    }
                }
                .disabled(!canSendMessage)
#if os(macOS)
                .buttonStyle(.plain)
#endif
            }
        }
        .padding()
        .containerShape(.rect(cornerRadius: 50))
        .onChange(of: chatMessageForEdit) { _, newValue in
            guard let newValue else {
                return
            }

            viewModel.chatMessageDraft = newValue.text
        }
    }

#if os(macOS)
    private func insertNewline() {
        guard !viewModel.isSendingChatMessage else {
            return
        }

        guard viewModel.chatMessageDraft.count < Config.DEFAULT_MESSAGE_MAX_LENGTH else {
            return
        }

        // SwiftUI TextField на macOS не всегда сам вставляет перенос строки по Shift+Return.
        viewModel.chatMessageDraft.append(Layout.newline)
    }
#endif

    private func submitMessage() {
        guard canSendMessage else {
            return
        }

        sendMessage()
    }

    private func sendMessage() {
        Task {
            if let chatMessage = chatMessageForEdit {
                await viewModel.editChatMessage(messageId: chatMessage.id, newText: viewModel.chatMessageDraft) { error in
                    if let error {
                        logger.error("editChatMessage error: \(error)")

                        self.error = error
                        self.showingErrorAlert.toggle()
                    } else {
                        chatMessageForEdit = nil
                        viewModel.chatMessageDraft = ""
                    }
                }
            } else if let chatMessage = chatMessageForReply {
                await viewModel.addChatMessage(text: viewModel.chatMessageDraft, quotedChatMessageId: chatMessage.id) { documentReference, error  in
                    if let error {
                        logger.error("addChatMessage (with quoted) error: \(error)")

                        self.error = error
                        self.showingErrorAlert.toggle()
                    } else {
                        chatMessageForReply = nil
                        viewModel.chatMessageDraft = ""
                    }
                }
            } else {
                await viewModel.addChatMessage(text: viewModel.chatMessageDraft) { documentReference, error  in
                    if let error {
                        logger.error("addChatMessage error: \(error)")

                        self.error = error
                        self.showingErrorAlert.toggle()
                    } else {
                        viewModel.chatMessageDraft = ""
                    }
                }
            }
        }
    }
}

#Preview {
    ChatInputMessageView(
        viewModel: ChatViewModel(),
        chatMessageForEdit: .constant(.stub),
        chatMessageForReply: .constant(.stub),
        showingErrorAlert: .constant(false),
        error: .constant(nil)
    )
}
