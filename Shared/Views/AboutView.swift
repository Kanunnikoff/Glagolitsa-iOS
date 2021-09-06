//
//  AboutView.swift
//  AboutView
//
//  Created by Kanunnikov Dmitriy Sergeevich on 03.09.2021.
//

import SwiftUI

struct AboutView: View {
    
    @State private var showingShareAlert = false
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("App Store")) {
                    Link("Оценить", destination: URL(string: Config.APPSTORE_APP_REVIEW_URL)!)
                        .font(.system(size: 17, weight: .regular, design: .rounded))
                    
                    Button("Поделиться") {
                        showingShareAlert = true
                    }
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    
                    Link("Другие приложения", destination: URL(string: Config.APPSTORE_DEVELOPER_URL)!)
                        .font(.system(size: 17, weight: .regular, design: .rounded))
                }
                
                Section(header: Text("Обратная связь")) {
                    Link("Написать письмо", destination: URL(string: Config.EMAIL_URL)!)
                        .font(.system(size: 17, weight: .regular, design: .rounded))
                }
                
                Section(header: Text("Политика конфиденциальности")) {
                    Link("Читать", destination: URL(string: Config.PRIVACY_POLICY_URL)!)
                        .font(.system(size: 17, weight: .regular, design: .rounded))
                }
            }
            .navigationTitle("О программе")
            .sheet(isPresented: $showingShareAlert) {
                ShareSheet(activityItems: [ Config.APPSTORE_APP_URL ])
            }
            
            Spacer()
            
            Text("Версия \(getAppVersion()), сборка \(getAppBuild())")
                .font(.system(size: 10, weight: .regular, design: .rounded))
        }
    }
    
    private func getAppVersion() -> String {
        guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else {
            return ""
        }
        
        return currentVersion
    }
    
    private func getAppBuild() -> String {
        let infoDictionaryKey = kCFBundleVersionKey as String
        guard let build = Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String else {
            return ""
            
        }
        
        return build
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}

