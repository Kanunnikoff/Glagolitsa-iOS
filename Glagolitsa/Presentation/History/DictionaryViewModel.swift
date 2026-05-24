//
//  DictionaryViewModel.swift
//  Glagolitsa
//
//  Created by Дмитрiй Канунниковъ on 03.07.2023.
//

import Foundation
import Observation
import SwiftUI
import OSLog

@Observable
final class HistoryViewModel {
    
    private let logger = Logger(subsystem: Util.getAppDisplayName(), category: "DictionaryViewModel")
    private let downloadManager = DownloadManager()
    
    func downloadDictionaries(
        url: URL,
        progressHandler: ((Int64, Int64, Float) -> Void)?,
        completionHandler: ((URL) async -> Void)?,
        errorHandler: ((Error?) async -> Void)?
    ) async {
        downloadManager.progressHandler = { totalBytesWritten, totalBytesExpectedToWrite, progress in
            progressHandler?(totalBytesWritten, totalBytesExpectedToWrite, progress)
        }
        
        downloadManager.completionHandler = completionHandler
        downloadManager.errorHandler = errorHandler
        
        downloadManager.downloadFile(with: url)
    }
}
