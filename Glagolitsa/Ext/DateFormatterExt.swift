//
//  DateFormatterExt.swift
//  Glagolitsa
//
//  Created by Kanunnikov Dmitriy  on 28.04.2025.
//

import Foundation

extension DateFormatter {
    
    func formatOldRus(date: Date) -> String {
        string(from: date)
            .replace("января", "просинца")
            .replace("февраля", "сечня")
            .replace("марта", "сухия")
            .replace("апреля", "березозола")
            .replace("мая", "травня")
            .replace("июня", "изока")
            .replace("июля", "червня")
            .replace("августа", "зарева")
            .replace("сентября", "ревуна")
            .replace("октября", "листопада")
            .replace("ноября", "грудня")
            .replace("декабря", "студня")
    }
}
