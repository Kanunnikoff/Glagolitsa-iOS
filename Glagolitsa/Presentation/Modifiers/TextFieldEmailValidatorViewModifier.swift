//
//  TextFieldEmailValidatorViewModifier.swift
//  Glagolitsa
//
//  Created by Kanunnikov Dmitriy  on 15.06.2025.
//

import SwiftUI

struct TextFieldEmailValidatorViewModifier: ViewModifier {
    
    @Binding var email: String
    @Binding var isEmailValid: Bool
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(isEmailValid ? .primary : .red)
            .onChange(of: email) { _, newValue in
                isEmailValid = Util.isEmailValid(newValue)
            }
    }
}

extension View {
    
    func emailValidator(email: Binding<String>, isEmailValid: Binding<Bool>) -> some View {
        modifier(TextFieldEmailValidatorViewModifier(email: email, isEmailValid: isEmailValid))
    }
}
