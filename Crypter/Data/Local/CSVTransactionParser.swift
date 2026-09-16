//
//  CSVTransactionParser.swift
//  Crypter
//

import Foundation

enum CSVTransactionParser {

    enum ParseError: LocalizedError {
        case unreadable
        case missingColumns
        case noValidRows

        var errorDescription: String? {
            switch self {
            case .unreadable:
                return "That file couldn't be read as text."
            case .missingColumns:
                return "The file needs date, coin, type, amount and price_per_coin columns."
            case .noValidRows:
                return "No usable rows were found in that file."
            }
        }
    }

    /// Matches columns by header name, so a file edited in a spreadsheet still imports.
    static func parse(_ text: String) throws -> [ImportedTransaction] {
        let lines = text
            .split(whereSeparator: \.isNewline)
            .map(String.init)
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }

        guard let header = lines.first else { throw ParseError.unreadable }

        let columns = splitRow(header).map { $0.lowercased().trimmingCharacters(in: .whitespaces) }

        guard let dateIndex = columns.firstIndex(of: "date"),
              let coinIndex = columns.firstIndex(of: "coin"),
              let typeIndex = columns.firstIndex(of: "type"),
              let amountIndex = columns.firstIndex(of: "amount"),
              let priceIndex = columns.firstIndex(of: "price_per_coin") else {
            throw ParseError.missingColumns
        }

        let rows = lines.dropFirst().compactMap { line -> ImportedTransaction? in
            let fields = splitRow(line)
            let highest = max(dateIndex, coinIndex, typeIndex, amountIndex, priceIndex)

            guard fields.count > highest else { return nil }

            let coinID = fields[coinIndex].trimmingCharacters(in: .whitespaces).lowercased()
            let kind = TransactionKind(rawValue: fields[typeIndex].trimmingCharacters(in: .whitespaces).lowercased())

            guard !coinID.isEmpty,
                  let kind,
                  let amount = Double(fields[amountIndex].trimmingCharacters(in: .whitespaces)),
                  amount > 0,
                  let price = Double(fields[priceIndex].trimmingCharacters(in: .whitespaces)),
                  let date = parseDate(fields[dateIndex].trimmingCharacters(in: .whitespaces)) else {
                return nil
            }

            return ImportedTransaction(
                coinID: coinID,
                kind: kind,
                amount: amount,
                pricePerCoin: price,
                date: date
            )
        }

        guard !rows.isEmpty else { throw ParseError.noValidRows }

        return rows
    }

    private static func splitRow(_ line: String) -> [String] {
        var fields: [String] = []
        var current = ""
        var inQuotes = false

        for character in line {
            switch character {
            case "\"":
                inQuotes.toggle()
            case "," where !inQuotes:
                fields.append(current)
                current = ""
            default:
                current.append(character)
            }
        }

        fields.append(current)
        return fields
    }

    private static func parseDate(_ value: String) -> Date? {
        let isoDay = ISO8601DateFormatter()
        isoDay.formatOptions = [.withFullDate]

        if let date = isoDay.date(from: value) { return date }

        let isoFull = ISO8601DateFormatter()
        if let date = isoFull.date(from: value) { return date }

        // Exchanges commonly export these two.
        for format in ["yyyy-MM-dd HH:mm:ss", "MM/dd/yyyy"] {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = format

            if let date = formatter.date(from: value) { return date }
        }

        return nil
    }
}
