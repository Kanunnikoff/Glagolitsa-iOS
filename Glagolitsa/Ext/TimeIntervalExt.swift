//
//  TimeIntervalExt.swift
//  Glagolitsa
//
//  Created by Kanunnikov Dmitriy  on 16.03.2025.
//

import Foundation

extension TimeInterval {
    
    init?(dispatchTimeInterval: DispatchTimeInterval) {
        switch dispatchTimeInterval {
            case .seconds(let value):
                self = Double(value)
            case .milliseconds(let value):
                self = Double(value) / 1_000
            case .microseconds(let value):
                self = Double(value) / 1_000_000
            case .nanoseconds(let value):
                self = Double(value) / 1_000_000_000
            case .never:
                return nil
            @unknown default:
                return nil
        }
    }
}
