//
//  ExchangeViewModel.swift
//  Mones
//
//  Created by Zakhar on 13.11.25.
//

import Foundation
import Combine

enum CurrencyPickerType {
    case first, second, toConvert
}

final class ExchangeViewModel: ObservableObject {
    @Published var firstCurrency: Currency = .eur
    @Published var secondCurrency: Currency = .gbp
    @Published var selectedToConvert: Currency = .uah
    
    @Published var isLoading: Bool = false
    @Published var error: String?
    
    @Published var showCurrencyPicker: Bool = false
    @Published var selectedPickerType: CurrencyPickerType = .first
    
    @Published var firstCurrencyRate: String = ""
    @Published var secondCurrencyRate: String = ""
    
    // MARK: - Private Properties
    private var exchangeRates: [Currency: Double] = [:]
    private var cancellables = Set<AnyCancellable>()
    private var networkManager = NetworkManager.shared
    
    // MARK: - Init
    init() {
        setupBinding()
        fetchExchangeRates()
    }
    
    private func setupBinding() {
        // Обновляем курсы при изменении выбранных валют
        Publishers.CombineLatest($firstCurrency, $secondCurrency)
            .sink { [weak self] _ in
                self?.updateRates()
            }
            .store(in: &cancellables)
        
        // При изменении базовой валюты автоматически делаем новый запрос к API
        $selectedToConvert
            .dropFirst() // Пропускаем initial value при инициализации
            .sink { [weak self] newBaseCurrency in
                self?.fetchExchangeRates()
            }
            .store(in: &cancellables)
        
        $error
            .compactMap { $0 } // Игнорируем nil
            .sink { errorMessage in
                print("Error: \(errorMessage)")
            }
            .store(in: &cancellables)
    }
    
    func fetchExchangeRates() {
        isLoading = true
        error = nil
        networkManager.fetchExchangeRate(for: selectedToConvert)
        
        networkManager.exchangeRatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] exchangeRates in
                self?.exchangeRates = exchangeRates
                self?.isLoading = false
                self?.error = nil
                self?.updateRates()
            }
            .store(in: &cancellables)
    }
    
    func selectCurrency(_ currency: Currency, for type: CurrencyPickerType) {
        let oldFirst = firstCurrency
        let oldSecond = secondCurrency
        let oldBase = selectedToConvert
        
        switch type {
        case .first:
            firstCurrency = currency
            // Если новая первая валюта совпадает со второй - меняем вторую на старую первую
            if firstCurrency == secondCurrency {
                secondCurrency = oldFirst
            }
            // Если новая первая валюта совпадает с базовой - меняем базовую на старую первую
            if firstCurrency == selectedToConvert {
                selectedToConvert = oldFirst
            }
            
        case .second:
            secondCurrency = currency
            // Если новая вторая валюта совпадает с первой - меняем первую на старую вторую
            if secondCurrency == firstCurrency {
                firstCurrency = oldSecond
            }
            // Если новая вторая валюта совпадает с базовой - меняем базовую на старую вторую
            if secondCurrency == selectedToConvert {
                selectedToConvert = oldSecond
            }
            
        case .toConvert:
            selectedToConvert = currency
            // Если новая базовая валюта совпадает с первой - меняем первую на старую базовую
            if selectedToConvert == firstCurrency {
                firstCurrency = oldBase
            }
            // Если новая базовая валюта совпадает со второй - меняем вторую на старую базовую
            if selectedToConvert == secondCurrency {
                secondCurrency = oldBase
            }
        }
        
        updateRates()
        showCurrencyPicker = false
    }
    
    private func updateRates() {
        
        // Получаем курс базовой валюты к самой себе (всегда 1)
        let baseRate = 1.0
        
        // Вычисляем, сколько единиц базовой валюты нужно для 1 единицы каждой из выбранных валют
        let firstRate = exchangeRates[firstCurrency] ?? 0.0
        let secondRate = exchangeRates[secondCurrency] ?? 0.0
        
        // Формула: (1 / rate) чтобы получить сколько базовой валюты нужно для 1 единицы целевой
        // Например: если 1 UAH = 0.02 EUR, то 1 EUR = 1 / 0.02 = 50 UAH
        if firstRate > 0 {
            let calculatedFirstRate = baseRate / firstRate
            firstCurrencyRate = formatRate(calculatedFirstRate, from: firstCurrency, to: selectedToConvert)
        } else {
            firstCurrencyRate = "..."
        }
        
        if secondRate > 0 {
            let calculatedSecondRate = baseRate / secondRate
            secondCurrencyRate = formatRate(calculatedSecondRate, from: secondCurrency, to: selectedToConvert)
        } else {
            secondCurrencyRate = "..."
        }
    }
    
    private func formatRate(_ rate: Double, from fromCurrency: Currency, to toCurrency: Currency) -> String {
        // Форматируем в зависимости от величины курса
        if rate >= 1000 {
            return String(format: "1 %@ = %.0f %@", fromCurrency.rawValue, rate, toCurrency.rawValue)
        } else if rate >= 100 {
            return String(format: "1 %@ = %.1f %@", fromCurrency.rawValue, rate, toCurrency.rawValue)
        } else if rate >= 10 {
            return String(format: "1 %@ = %.2f %@", fromCurrency.rawValue, rate, toCurrency.rawValue)
        } else if rate >= 1 {
            return String(format: "1 %@ = %.3f %@", fromCurrency.rawValue, rate, toCurrency.rawValue)
        } else {
            return String(format: "1 %@ = %.4f %@", fromCurrency.rawValue, rate, toCurrency.rawValue)
        }
    }
    
    // MARK: - Helper Methods
    func showPicker(for type: CurrencyPickerType) {
        selectedPickerType = type
        showCurrencyPicker = true
    }
    
    var firstCurrencyDisplay: String {
        return "\(firstCurrency.flag) \(firstCurrency.rawValue)"
    }
    
    var secondCurrencyDisplay: String {
        return "\(secondCurrency.flag) \(secondCurrency.rawValue)"
    }
    
    var baseCurrencyDisplay: String {
        return "\(selectedToConvert.flag) \(selectedToConvert.rawValue)"
    }
}
