//
//  Config.swift
//  Glagolitsa
//
//  Created by Дмитрiй Канунниковъ on 03.07.2023.
//

import Foundation

struct Config {
    
    //--- MARK: Test
    
#if DEBUG
    static let isTestMode = true
#else
    static let isTestMode = false
#endif
    
    //--- MARK: Constants
    
    static let REQUEST_REVIEW_LAUNCHES_COUNT_THRESHOLD = 5
    static let DEVELOPER_EMAIL = "dmitry.kanunnikoff@gmail.com"
    
    static let DEFAULT_NAME_MAX_LENGTH = 100
    static let DEFAULT_EMAIL_MAX_LENGTH = 320
    static let DEFAULT_MESSAGE_MAX_LENGTH = 500
    static let SPLASH_HIDNG_DELAY_SECONDS = 3
    static let SPLASH_HIDNG_DURAION_SECONDS = 1
    
    static let WIKI_URL = "https://ru.wikipedia.org/wiki/%D0%93%D0%BB%D0%B0%D0%B3%D0%BE%D0%BB%D0%B8%D1%86%D0%B0"
    
    static let customFonts = [
        "system": "System",
        "old_standard_tt_regular": "Old Standard TT Regular",
        "old_standard_tt_italic": "Old Standard TT Italic",
        "old_standard_tt_bold": "Old Standard TT Bold",
        "akademitscheskaja_buch": "Akademitscheskaja Buch",
        "arctika_script": "Arctika script",
        "asturia_script": "Asturia script",
        "auriol_c_italic": "AuriolC Italic",
        "behrens_kursiv_c": "Behrens KursivC",
        "calligraph_modern": "Calligraph Modern",
        "carmen": "Carmen",
        "elisabethische": "EIisabethische",
        "elizabeth_tt_uni_italic": "Elizabeth_tt Uni Italic",
        "kornilow": "Kornilow",
        "monomakh_unicode": "Monomakh Unicode TT",
        "nocturne_victorian": "Nocturne Victorian",
        "preciosa": "Preciosa",
        "rococo_initial": "Rococo Initial",
        "rose_versailles_1": "Rose Versailles1",
        "russian_land_cyrillic_sinod": "Russian Land Cyrillic Sinod",
        "snell_roundhand": "Snell Roundhand",
        "spsl_russian_souvenir": "SPSLRussianSouvenir",
        "zaragoza_c": "ZaragozaC",
        "ptserif_regular": "PTSerif-Regular",
        "ptserif_italic": "PTSerif-Italic",
        "cormorant_infant_light_italic": "CormorantInfant-LightItalic",
        "dilyan": "Dilyana",
        "medieval_english": "Medieval English",
        "shafarik_regular": "Shafarik-Regular"
    ]
    
    static let fontSizes = [
        14, 15, 16, 17, 20, 23, 26, 29, 36, 40, 44, 48, 55, 58, 60, 62, 64, 68, 72, 75, 80, 84, 90, 96, 100, 110, 120, 130, 140
    ]
    
    //--- MARK: App Store
    
    static let APPSTORE_APP_ID = 1584419808
    static let APPSTORE_APP_URL = URL(string: "https://itunes.apple.com/app/id\(APPSTORE_APP_ID)")!
    static let APPSTORE_APP_REVIEW_URL = URL(string: "https://itunes.apple.com/app/id\(APPSTORE_APP_ID)?action=write-review")!
    static let APPSTORE_DEVELOPER_URL = URL(string: "https://itunes.apple.com/developer/id1449411291")!
    
    static let PACKAGE_NAME = "software.kanunnikoff.Glagolitsa"
    
    //--- MARK: Feedback
    
    static let EMAIL_URL = URL(string: "mailto:\(DEVELOPER_EMAIL)?subject=%E2%B0%83%E2%B0%BE%E2%B0%B0%E2%B0%B3%E2%B1%81%E2%B0%BE%E2%B0%BB%E2%B1%8C%E2%B0%B0%20%28iOS%29")!
    
    //--- MARK: Privacy
    
    static let PRIVACY_POLICY_URL = URL(string: "https://docs.google.com/document/d/17KDsA6T1DPX07jo_oeuJhTtJJ2qrQmzXwgjXFABd_Gg/edit?usp=sharing")!
    
    //--- MARK: Keychain Group
    
    static let KEYCHAIN_ACCESS_GROUP = "9FJ6F4TT5T.\(PACKAGE_NAME).keychain"
    static let KEYCHAIN_ACCOUNT_IDENTITY_TOKEN = "identity_token"
}
