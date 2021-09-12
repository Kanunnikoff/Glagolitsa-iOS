//
//  SaveImageSheet.swift
//  SaveImageSheet
//
//  Created by Kanunnikov Dmitriy Sergeevich on 06.09.2021.
//

import SwiftUI

struct SaveImageSheet: View {
    
    let text: String
    
    @State private var fgColor = Color(UIColor.label)
    @State private var bgColor = Color(UIColor.systemBackground)
    @State private var size = 30
    
    private static let sizes = [15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100]
    
    @State private var imageSize = CGSize()
    
    @AppStorage("SettingsView.isSystemFontAndSize")
    private var isSystemFontAndSize: Bool = false
    
    var body: some View {
        ScrollView {
            VStack {
                textForImage
                
                ColorPicker("Цвет текста", selection: $fgColor)
                    .padding([.leading, .trailing], 10)
                
                ColorPicker("Цвет фона", selection: $bgColor)
                    .padding([.leading, .trailing, .top], 10)
                
                Picker("Размер", selection: $size) {
                    ForEach(SaveImageSheet.sizes, id: \.self) {
                        Text("\($0)")
                    }
                }
                .pickerStyle(.wheel)
                .padding([.leading, .trailing, .top], 10)
                
                Spacer()
                
                Button(role: .none, action: {
                    save()
                }, label: {
                    Text("Сохранить")
                        .bold()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .cornerRadius(10)
                })
                    .padding()
            }
        }
    }
    
    private var textForImage: some View {
        let text = Text(text)
            .padding()
            .foregroundColor(fgColor)
            .background(bgColor)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
            .readSize { newSize in
                imageSize = newSize
            }
        
        if isSystemFontAndSize {
            return AnyView(
                text
                    .font(.system(size: CGFloat(size)))
            )
        } else {
            return AnyView(
                text
                    .font(.custom("Shafarik-Regular", size: CGFloat(size), relativeTo: .body))
            )
        }
    }
    
    private func save() {
        convertViewToData(view: textForImage, size: imageSize) {
            guard let imageData = $0, let uiImage = UIImage(data: imageData) else { return }
            UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
        }
    }
}
