//
//  MyLogger.swift
//  Glagolitsa
//
//  Created by Kanunnikov Dmitriy  on 08.11.2025.
//

import Foundation
import OSLog

class MyLogger {
    
    private let logger: Logger
    
    init(category: String) {
        self.logger = Logger(subsystem: Util.getAppDisplayName(), category: category)
    }
    
    func info(_ message: String) {
#if DEBUG
        logger.info("\(message)")
#endif
    }
    
    func debug(_ message: String) {
#if DEBUG
        logger.debug("\(message)")
#endif
    }
    
    func error(_ message: String) {
#if DEBUG
        logger.error("\(message)")
#endif
    }
}
