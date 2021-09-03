//
//  MainView.swift
//  MainView
//
//  Created by Kanunnikov Dmitriy Sergeevich on 03.09.2021.
//

import SwiftUI

struct MainView: View {
    
    private let converter: Converter = Converter.create()
    
    @State private var orientation = UIDeviceOrientation.unknown
    
    @State private var cyrillicText: String = ""
    @State private var glagoliticText: String = ""
    
    @State private var isFromCyrillicToGlagolitic: Bool = true
    
    var body: some View {
        if orientation.isLandscape {
            HStack {
                if isFromCyrillicToGlagolitic {
                    cyrillicEditor
                } else {
                    glagoliticEditor
                }
                
                verticalButtonsBlock
                
                if isFromCyrillicToGlagolitic {
                    glagoliticEditor
                } else {
                    cyrillicEditor
                }
            }
            .navigationTitle("Ⰳⰾⰰⰳⱁⰾⰻⱌⰰ")
            .onRotate { newOrientation in
                orientation = newOrientation
            }
        } else {
            VStack {
                if isFromCyrillicToGlagolitic {
                    cyrillicEditor
                } else {
                    glagoliticEditor
                }
                
                horizontalButtonsBlock
                
                if isFromCyrillicToGlagolitic {
                    glagoliticEditor
                } else {
                    cyrillicEditor
                }
            }
            .navigationTitle("Ⰳⰾⰰⰳⱁⰾⰻⱌⰰ")
            .onRotate { newOrientation in
                orientation = newOrientation
            }
        }
    }
    
    var cyrillicEditor: some View {
        ZStack(alignment: Alignment(horizontal: .leading, vertical: .top)) {
            if cyrillicText.isEmpty {
                Text("Кириллица")
                    .foregroundColor(Color(.label))
                    .padding(.top, 10)
            }
            
            TextEditor(text: $cyrillicText)
                .opacity(cyrillicText.isEmpty ? 0.7 : 1)
                .font(.custom("PTSerif-Regular", size: 20))
                .disableAutocorrection(true)
                .autocapitalization(.sentences)
                .onChange(of: cyrillicText, perform: { value in
                    convert()
                })
        }
        .padding([.leading, .trailing], 10)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color(.systemGray5), lineWidth: 1.0)
        )
        .padding([.leading, .trailing], 10)
    }
    
    var glagoliticEditor: some View {
        ZStack(alignment: Alignment(horizontal: .leading, vertical: .top)) {
            if glagoliticText.isEmpty {
                Text("Ⰳⰾⰰⰳⱁⰾⰻⱌⰰ")
                    .foregroundColor(Color(.label))
                    .padding(.top, 10)
            }
            
            TextEditor(text: $glagoliticText)
                .opacity(glagoliticText.isEmpty ? 0.7 : 1)
                .font(.custom("Glagolitsa", size: 20))
                .disableAutocorrection(true)
                .autocapitalization(.sentences)
        }
        .padding([.leading, .trailing], 10)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color(.systemGray5), lineWidth: 1.0)
        )
        .padding([.leading, .trailing], 10)
    }
    
    var clearButton: some View {
        Button(action: {
            clear()
        }) {
            Text(Image(systemName: "trash"))
                .font(.system(size: 15))
                .frame(width: 15, height: 15)
                .padding()
                .foregroundColor(.red)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color(.red), lineWidth: 1.0)
                )
        }
    }
    
    var convertButton: some View {
        Button(action: {
            convert()
        }) {
            Text(Image(systemName: "chevron.down"))
                .font(.system(size: 15))
                .frame(width: 30, height: 30)
                .padding()
                .foregroundColor(.green)
                .overlay(
                    RoundedRectangle(cornerRadius: 40)
                        .stroke(Color(.green), lineWidth: 1.0)
                )
        }
    }
    
    var copyButton: some View {
        Button(action: {
            copy()
        }) {
            Text(Image(systemName: "doc.on.doc"))
                .font(.system(size: 15))
                .frame(width: 20, height: 20)
                .padding()
                .foregroundColor(.yellow)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color(.yellow), lineWidth: 1.0)
                )
        }
    }
    
    var toggle: some View {
        HStack {
            if isFromCyrillicToGlagolitic {
                Text("К-Ⰳ")
            } else {
                Text("Ⰳ-К")
            }
            
            Toggle(isOn: $isFromCyrillicToGlagolitic.animation()) {
            }
            .frame(width: 50)
        }
    }
    
    var horizontalButtonsBlock: some View {
        HStack {
            clearButton
            copyButton
            convertButton
            
            Spacer()
            
            toggle
        }
        .padding()
    }
    
    var verticalButtonsBlock: some View {
        VStack {
            clearButton
            copyButton
            convertButton
            
            Spacer()
            
            toggle
        }
        .padding()
    }
    
    private func clear() {
        cyrillicText = ""
        glagoliticText = ""
    }
    
    private func convert() {
        if isFromCyrillicToGlagolitic {
            if !cyrillicText.isEmpty {
                Task(priority: .background) {
                    await glagoliticText = converter.convert(fromCyrillic: cyrillicText)
                }
            }
        } else {
            if !glagoliticText.isEmpty {
                Task(priority: .background) {
                    await cyrillicText = converter.convert(fromGlagolitic: glagoliticText)
                }
            }
        }
    }
    
    private func copy() {
        if isFromCyrillicToGlagolitic {
            if !glagoliticText.isEmpty {
                Util.copyToClipboard(text: glagoliticText)
            }
        } else {
            if !cyrillicText.isEmpty {
                Util.copyToClipboard(text: cyrillicText)
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
