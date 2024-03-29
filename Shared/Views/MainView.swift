//
//  MainView.swift
//  MainView
//
//  Created by Kanunnikov Dmitriy Sergeevich on 03.09.2021.
//

import SwiftUI
import Combine

struct MainView: View {
    
    @EnvironmentObject var viewModel: MainViewModel
    
    private let subject: PassthroughSubject = PassthroughSubject<Int, Never>()
    
    @State private var cancellable: Cancellable? = nil
    
#if os(iOS)
    @State private var orientation: UIDeviceOrientation = UIDevice.current.orientation
#endif
    
    @State private var isFromCyrillicToGlagolitic: Bool = true
    
#if os(iOS)
    @State private var showImageScreen: Bool = false
#endif
    
    @AppStorage("SettingsView.isSystemFontAndSize")
    private var isSystemFontAndSize: Bool = false
    
    var body: some View {
        ZStack {
#if os(iOS)
            if orientation.isLandscape {
                landscapeView
                    .onRotate { newOrientation in
                        if newOrientation.isPortrait {
                            orientation = newOrientation
                        }
                    }
            } else {
                portraitView
                    .onRotate { newOrientation in
                        if newOrientation.isLandscape {
                            orientation = newOrientation
                        }
                    }
            }
            
            if isFromCyrillicToGlagolitic {
                Text("")
                    .hidden()
                    .navigatePush(whenTrue: $showImageScreen, text: viewModel.glagoliticText)
            } else {
                Text("")
                    .hidden()
                    .navigatePush(whenTrue: $showImageScreen, text: viewModel.cyrillicText)
            }
#elseif os(macOS)
            landscapeView
#endif
        }
        .navigationTitle("Ⰳⰾⰰⰳⱁⰾⰻⱌⰰ")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    copy()
                }, label: {
                    Image(systemName: "doc.on.doc")
                })
                    .keyboardShortcut("C", modifiers: .command)
            }
            
            ToolbarItem(placement: .primaryAction) {
                menu
            }
        }
        .onAppear(perform: {
#if os(iOS)
            orientation = UIDevice.current.orientation
#endif
            
            cancellable = subject
                .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
                .sink { _ in
                    convert()
                }
        })
        .onDisappear(perform: {
            cancellable?.cancel()
        })
    }
    
    var landscapeView: some View {
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
    }
    
    var portraitView: some View {
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
    }
    
    var cyrillicEditor: some View {
        let editor = TextEditor(text: $viewModel.cyrillicText)
            .opacity(viewModel.cyrillicText.isEmpty ? 0.7 : 1)
            .disableAutocorrection(true)
#if os(iOS)
            .autocapitalization(.sentences)
            .padding([.leading, .trailing], 10)
            .padding([.top, .bottom], 1)
#elseif os(macOS)
            .padding(10)
#endif
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(.gray), lineWidth: 1.0)
            )
            .padding(10)
            .onChange(of: viewModel.cyrillicText, perform: { value in
                if isFromCyrillicToGlagolitic {
                    subject.send(Int.zero)
                }
            })
        
        if isSystemFontAndSize {
            return AnyView(editor)
        } else {
            return AnyView(
                editor
                    .font(.custom("Shafarik-Regular", size: 25, relativeTo: .body))
            )
        }
    }
    
    var glagoliticEditor: some View {
        let editor = TextEditor(text: $viewModel.glagoliticText)
            .opacity(viewModel.glagoliticText.isEmpty ? 0.7 : 1)
            .disableAutocorrection(true)
#if os(iOS)
            .autocapitalization(.sentences)
            .padding([.leading, .trailing], 10)
            .padding([.top, .bottom], 1)
#elseif os(macOS)
            .padding(10)
#endif
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(.gray), lineWidth: 1.0)
            )
            .padding(10)
            .onChange(of: viewModel.glagoliticText, perform: { value in
                if !isFromCyrillicToGlagolitic {
                    subject.send(Int.zero)
                }
            })
        
        if isSystemFontAndSize {
            return AnyView(editor)
        } else {
            return AnyView(editor
                .font(.custom("Shafarik-Regular", size: 25, relativeTo: .body)))
        }
    }
    
    var toggle: some View {
        ZStack {
#if os(iOS)
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
#elseif os(macOS)
            VStack(alignment: .center) {
                if isFromCyrillicToGlagolitic {
                    Text("К-Ⰳ")
                } else {
                    Text("Ⰳ-К")
                }
                
                Toggle("", isOn: $isFromCyrillicToGlagolitic.animation(.spring(response: 0.55, dampingFraction: 0.45, blendDuration: 0)))
                    .labelsHidden()
            }
#endif
        }
    }
    
    var menu: some View {
        Menu {
#if os(iOS)
            if isFromCyrillicToGlagolitic && !viewModel.glagoliticText.isEmpty ||
                !isFromCyrillicToGlagolitic && !viewModel.cyrillicText.isEmpty {
                Button(action: {
                    showImageScreen.toggle()
                }) {
                    Label("Картинка перевода", systemImage: "photo")
                }
            }
#endif
            
            Button(action: {
                viewModel.clear()
            }) {
                Label("Очистить", systemImage: "trash")
            }
        }  label: {
            Image(systemName: "ellipsis.circle")
        }
    }
    
    private func convert() {
        if isFromCyrillicToGlagolitic {
            viewModel.convertFromCyrillicToGlagolitic()
        } else {
            viewModel.convertFromGlagoliticToCyrillic()
        }
    }
    
    private func copy() {
        if isFromCyrillicToGlagolitic {
            if !viewModel.glagoliticText.isEmpty {
                Util.copyToClipboard(text: viewModel.glagoliticText)
            }
        } else {
            if !viewModel.cyrillicText.isEmpty {
                Util.copyToClipboard(text: viewModel.cyrillicText)
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
