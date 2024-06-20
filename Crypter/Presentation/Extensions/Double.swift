//
//  Double.swift
//  Crypter
//
//

import Foundation

extension Date {
    func getDayOfTheWeek()-> String{
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "EEEE"
           let weekDay = dateFormatter.string(from: Date())
           return weekDay
     }
}

extension Double {
    /// Converts a Double into a Currency with 2  decimal place
    ///```
    ///Convert 1234.56 to $1,234.56
 
    ///```
    private var CurrencyFormatter2: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .currency
        //formatter.locale = .current // <- default val
        //formatter.currencyCode = "usd"
        //formatter.currencySymbol = "$"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }
    /// Converts a Double into a Currency as a string with 2 decimal place
    ///```
    ///Convert 1234.56 to "$1,234.56"
    ///```
    func asCurrencyWith2Decimals() -> String {
        let number = NSNumber(value: self)
        return CurrencyFormatter2.string(from: number) ?? "$0.00"
        
    }
    /// Converts a Double into a Currency with 2-6 decimal place
    ///```
    ///Convert 1234.56 to $1,234.56
    ///Convert 12.3456 to $12.3456
    ///Convert 0.123456 to $0.123456
    ///```
    private var CurrencyFormatter6: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .currency
        //formatter.locale = .current // <- default val
        //formatter.currencyCode = "usd"
        //formatter.currencySymbol = "$"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 6
        return formatter
    }
    /// Converts a Double into a Currency as a string with 2-6 decimal place
    ///```
    ///Convert 1234.56 to "$1,234.56"
    ///Convert 12.3456 to "$12.3456"
    ///Convert 0.123456 to "$0.123456"
    ///```
    func asCurrencyWith6Decimals() -> String {
        let number = NSNumber(value: self)
        return CurrencyFormatter6.string(from: number) ?? "$0.00"
        
    }
    /// Converts a Double into a string representation
    ///```
    ///Convert 1.2345 to "$1.23"
    ///```
    func asNumberString() -> String {
        return String(format: "%.2f", self)
    }
    /// Converts a Double into a string representation
    ///```
    ///Convert 1.2345 to "1.23%"
    ///```
    func asPercentString() -> String{
        return asNumberString() + "%"
    }
    /// Converts a Double into a string representation
    ///```
    ///Convert 12 to 12.00
    ///Convert 1234 to 1.23k
    ///Convert 123456 to 123.45k
    ///Convert 123455670 to 12.34M
    ///Convert 1234567890 to 1.23Bn
    ///Convert 12345678901234 to 12.34Tr
    ///
    ///```
    func formattedWithAbbreviations() -> String {
        let num = abs(Double(self))
        let sign = (self < 0) ? "-" : ""
        
        switch num {
        case 1_000_000_000_000...:
            let formatted = num / 1_000_000_000_000
            let stringFormatted = formatted.asNumberString()
            return "\(sign)\(stringFormatted)Tr"
        case 1_000_000_000...:
            let formatted = num / 1_000_000_000
            let stringFormatted = formatted.asNumberString()
            return "\(sign)\(stringFormatted)Bn"
        case 1_000_000...:
            let formatted = num / 1_000
            let stringFormatted = formatted.asNumberString()
            return "\(sign)\(stringFormatted)M"
        case 1_000...:
            let formatted = num / 1_000
            let stringFormatted = formatted.asNumberString()
            return "\(sign)\(stringFormatted)K"
        case 0...:
            return self.asNumberString()
            
        default:
            return "\(sign)\(self)"
        }
    }
}
