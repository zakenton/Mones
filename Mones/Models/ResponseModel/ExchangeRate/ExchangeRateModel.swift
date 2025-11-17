//
//  ExchangeRateModel.swift
//  Mones
//
//  Created by Zakhar on 13.11.25.
//

import Foundation

// MARK: - ExchangeRateResponse
struct ExchangeRateResponse: Codable {
    let result: String
    let documentation: String
    let termsOfUse: String
    let timeLastUpdateUnix: Int
    let timeLastUpdateUtc: String
    let timeNextUpdateUnix: Int
    let timeNextUpdateUtc: String
    let baseCode: String
    let conversionRates: [String: Double]
    
}

extension ExchangeRateResponse {
    
    var filteredRates: [Currency: Double] {
        Dictionary(
            uniqueKeysWithValues: Currency.allCases.compactMap { currency in
                guard let value = conversionRates[currency.rawValue] else { return nil }
                return (currency, value)
            }
        )
    }
}

// MARK: - Currency Enum
enum Currency: String, CaseIterable, Codable {
    case uah = "UAH"
    case usd = "USD"
    case eur = "EUR"
    case gbp = "GBP"
    case czk = "CZK"
    case pln = "PLN"
    case rub = "RUB"
    
    var flag: String {
        switch self {
        case .uah: return "🇺🇦"
        case .usd: return "🇺🇸"
        case .eur: return "🇪🇺"
        case .gbp: return "🇬🇧"
        case .czk: return "🇨🇿"
        case .pln: return "🇵🇱"
        case .rub: return "🇷🇺"
        }
    }
    
    var name: String {
        switch self {
        case .uah: return "Ukrainian Hryvnia"
        case .usd: return "US Dollar"
        case .eur: return "Euro"
        case .gbp: return "British Pound"
        case .czk: return "Czech Koruna"
        case .pln: return "Polish Zloty"
        case .rub: return "Russian Ruble"
        }
    }
    
    var symbol: String {
        switch self {
        case .uah: return "₴"
        case .usd: return "$"
        case .eur: return "€"
        case .gbp: return "£"
        case .czk: return "Kč"
        case .pln: return "zł"
        case .rub: return "₽"
        }
    }
}
