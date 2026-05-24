//
//  ChatWelcomeView.swift
//  Yat
//
//  Created by Kanunnikov Dmitriy  on 4/26/25.
//

import SwiftUI
import OSLog

enum UserType {
    case existing
    case new
}

struct ChatWelcomeView: View {
    
    private let logger = MyLogger(category: "ChatWelcomeView")
    
    let viewModel: ChatViewModel
    @Binding var showingErrorAlert: Bool
    @Binding var error: Error?
    
//    @AppStorage("isAntiqueFont")
//    private var isAntiqueFont: Bool = false
//    
//    @AppStorage("isPreRevolutionary")
//    private var isPreRevolutionary: Bool = false
    
//    @State private var selectedUserType: UserType  = .existing
//    
//#if DEBUG
//    @State private var email: String = Config.DEVELOPER_EMAIL
//#else
//    @State private var email: String = ""
//#endif
//    
//    @State private var isEmailValid = true
//    @State private var name: String  = ""
//    @State private var password: String = ""
//    @State private var isAgreementChecked: Bool = false
    
    var body: some View {
        VStack {
//            Picker("", selection: $selectedUserType) {
//                Text("Existing")
//                    .tag(UserType.existing)
//                
//                Text("New")
//                    .tag(UserType.new)
//            }
//            .pickerStyle(.segmented)
//            .labelsHidden()
//            .padding(.horizontal)
//            .padding(.top)
            
            ContentUnavailableView {
                Label("Here you will see the conversation messages", systemImage: "ellipsis.message") // 􁒘
            } description: {
                Text("All that's left to do is log in.")
            } actions: {
                SignInWithAppleView(label: .signIn) { idToken, rawNonce, fullName, error in
                    signIn(
                        withIDToken: idToken,
                        rawNonce: rawNonce,
                        fullName: fullName,
                        error: error
                    )
                }
            }
                
//            List {
//                TextField("Email", text: $email)
//                    .textContentType(.emailAddress)
//                    .autocorrectionDisabled(true)
//                    .textInputAutocapitalization(.never)
//#if !os(macOS)
//                    .keyboardType(.emailAddress)
//#endif
//                    .emailValidator(email: $email, isEmailValid: $isEmailValid)
//                    .lengthValidator(text: $email, maxLength: Config.DEFAULT_EMAIL_MAX_LENGTH)
//                
//                SecureField("Password", text: $password)
//                    .textContentType(.password)
//                
//                if selectedUserType == .new {
//                    TextField("Name", text: $name)
//                        .textContentType(.username)
//                        .autocorrectionDisabled(true)
//                        .textInputAutocapitalization(.words)
//                        .lengthValidator(text: $name, maxLength: Config.DEFAULT_NAME_MAX_LENGTH)
//                    
//                    Toggle(
//                        "By joining the conversation, you agree to adhere to generally accepted moral standards, avoid using obscene words and expressions, as well as hateful insults based on religious, national, racial and other grounds. This conversation is intended for cultured people to communicate on intelligent and useful topics, or at least neutral ones.\n\nViolations of this agreement may result in suspension of the account or even its complete blocking.",
//                        isOn: $isAgreementChecked
//                    )
//                    .font(.caption)
//                    
//                    Button("Sign Up") {
//                        signUp()
//                    }
//                    .frame(maxWidth: .infinity, alignment: .center)
//                    .disabled(email.isEmpty || !isEmailValid || password.isEmpty || name.isEmpty || !isAgreementChecked)
//                } else {
//                    Button("Sign In") {
//                        signIn()
//                    }
//                    .frame(maxWidth: .infinity, alignment: .center)
//                    .disabled(email.isEmpty || !isEmailValid || password.isEmpty)
//                }
//            }
        }
    }
    
//    private func signUp() {
//        Task {
//            await viewModel.signUp(email: email, name: name, password: password) { authDataResult, error in
//                if let error = error {
//                    logger.error("signUp error: \(error.localizedDescription)")
//                    
//                    self.error = error
//                    self.showingErrorAlert.toggle()
//                }
//            }
//        }
//    }
//    
//    private func signIn() {
//        Task {
//            await viewModel.signIn(email: email, password: password) { authDataResult, error in
//                if let error = error {
//                    logger.error("signIn error: \(error.localizedDescription)")
//                    
//                    self.error = error
//                    self.showingErrorAlert.toggle()
//                }
//            }
//        }
//    }
    
    private func signIn(
        withIDToken idToken: String,
        rawNonce: String?,
        fullName: PersonNameComponents?,
        error: Error?
    ) {
        if let error = error {
            logger.error("signIn error: \(error.localizedDescription)")
            
            self.error = error
            self.showingErrorAlert.toggle()
            return
        }
        
        Task {
            await viewModel.signIn(
                withIDToken: idToken,
                rawNonce: rawNonce,
                fullName: fullName
            ) { authDataResult, error in
                if let error = error {
                    logger.error("signIn error: \(error.localizedDescription)")
                    
                    self.error = error
                    self.showingErrorAlert.toggle()
                }
            }
        }
    }
}

#Preview {
    ChatWelcomeView(
        viewModel: ChatViewModel(),
        showingErrorAlert: .constant(false),
        error: .constant(nil)
    )
}
