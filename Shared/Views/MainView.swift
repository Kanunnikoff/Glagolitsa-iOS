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
        ZStack {
            if orientation.isLandscape {
                HStack {
                    if isFromCyrillicToGlagolitic {
                        cyrillicEditor
                    } else {
                        glagoliticEditor
                    }
                    
                    toggle
                    
                    if isFromCyrillicToGlagolitic {
                        glagoliticEditor
                    } else {
                        cyrillicEditor
                    }
                }
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
                    
                    toggle
                    
                    if isFromCyrillicToGlagolitic {
                        glagoliticEditor
                    } else {
                        cyrillicEditor
                    }
                }
                .onRotate { newOrientation in
                    orientation = newOrientation
                }
            }
        }
        .navigationTitle("Ⰳⰾⰰⰳⱁⰾⰻⱌⰰ")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    clear()
                }, label: {
                    Image(systemName: "trash")
                })
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button(action: {
                    copy()
                }, label: {
                    Image(systemName: "doc.on.doc")
                })
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
    
    var toggle: some View {
        ZStack {
            if orientation.isLandscape {
                VStack(alignment: .center) {
                    if isFromCyrillicToGlagolitic {
                        Text("К-Ⰳ")
                    } else {
                        Text("Ⰳ-К")
                    }
                    
                    Toggle("", isOn: $isFromCyrillicToGlagolitic.animation())
                        .labelsHidden()
                }
            } else {
                HStack {
                    if isFromCyrillicToGlagolitic {
                        Text("К-Ⰳ")
                    } else {
                        Text("Ⰳ-К")
                    }
                    
                    Toggle("", isOn: $isFromCyrillicToGlagolitic.animation())
                        .labelsHidden()
                }
            }
        }
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
