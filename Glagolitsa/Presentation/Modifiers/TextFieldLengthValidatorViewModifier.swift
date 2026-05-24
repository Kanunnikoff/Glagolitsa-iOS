//
//  TextFieldLengthValidatorViewModifier.swift
//  Glagolitsa
//
//  Created by Kanunnikov Dmitriy  on 15.06.2025.
//

import SwiftUI

struct TextFieldLengthValidatorViewModifier: ViewModifier {
    
    @Binding var text: String
    let maxLength: Int
    
    @State private var isLengthInvalid = false
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(isLengthInvalid ? .red : .primary)
            .onChange(of: text) { _, newValue in
                if newValue.count > maxLength {
                    text = String(newValue.prefix(maxLength))
                    
                    if !isLengthInvalid {
                        isLengthInvalid = true
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            isLengthInvalid = false
                        }
                    }
                }
            }
    }
}

extension View {
    
    func lengthValidator(text: Binding<String>, maxLength: Int = 10) -> some View {
        modifier(TextFieldLengthValidatorViewModifier(text: text, maxLength: maxLength))
    }
}
