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
    
    @State private var showImageSheet: Bool = false
    
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
                    copy()
                }, label: {
                    Image(systemName: "doc.on.doc")
                })
            }
            
            ToolbarItem(placement: .primaryAction) {
                menu
            }
        }
        .sheet(isPresented: $showImageSheet, content: {
            if isFromCyrillicToGlagolitic {
                SaveImageSheet(text: glagoliticText)
            } else {
                SaveImageSheet(text: cyrillicText)
            }
        })
    }
    
    var cyrillicEditor: some View {
        TextEditor(text: $cyrillicText)
            .opacity(cyrillicText.isEmpty ? 0.7 : 1)
            .font(.custom("PTSerif-Regular", size: 20, relativeTo: .body))
            .disableAutocorrection(true)
            .autocapitalization(.sentences)
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(.systemGray5), lineWidth: 1.0)
            )
            .transition(AnyTransition.asymmetric(insertion: .identity, removal: .move(edge: .bottom)))
            .onChange(of: cyrillicText, perform: { value in
                if isFromCyrillicToGlagolitic {
                    convert()
                }
            })
    }
    
    var glagoliticEditor: some View {
        TextEditor(text: $glagoliticText)
            .opacity(glagoliticText.isEmpty ? 0.7 : 1)
            .font(.custom("Shafarik-Regular", size: 30, relativeTo: .body))
            .disableAutocorrection(true)
            .autocapitalization(.sentences)
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(.systemGray5), lineWidth: 1.0)
            )
            .transition(AnyTransition.asymmetric(insertion: .identity, removal: .move(edge: .bottom)))
            .onChange(of: glagoliticText, perform: { value in
                if !isFromCyrillicToGlagolitic {
                    convert()
                }
            })
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
                    
                    Toggle("", isOn: $isFromCyrillicToGlagolitic.animation(.spring(response: 0.55, dampingFraction: 0.45, blendDuration: 0)))
                        .labelsHidden()
                }
            } else {
                HStack {
                    if isFromCyrillicToGlagolitic {
                        Text("К-Ⰳ")
                    } else {
                        Text("Ⰳ-К")
                    }
                    
                    Toggle("", isOn: $isFromCyrillicToGlagolitic.animation(.spring(response: 0.55, dampingFraction: 0.45, blendDuration: 0)))
                        .labelsHidden()
                }
            }
        }
    }
    
    var menu: some View {
        Menu {
            Button(action: {
                showImageSheet.toggle()
            }) {
                Label("Картинка перевода", systemImage: "photo")
            }
            
            Button(action: {
                clear()
            }) {
                Label("Очистить", systemImage: "trash")
            }
        }  label: {
            Image(systemName: "ellipsis.circle")
        }
    }
    
    private func clear() {
        cyrillicText = ""
        glagoliticText = ""
    }
    
    private func convert() {
        if isFromCyrillicToGlagolitic {
            Task(priority: .background) {
                await glagoliticText = converter.convert(fromCyrillic: cyrillicText)
            }
        } else {
            Task(priority: .background) {
                await cyrillicText = converter.convert(fromGlagolitic: glagoliticText)
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
