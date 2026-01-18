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
    // MARK: - Published Properties
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
    private var conversionRates: [Currency: Double] = [:]
    private var cancellables = Set<AnyCancellable>()
    private let networkManager = NetworkManager.shared
    
    // MARK: - Init
    init() {
        setupBindings()
        fetchExchangeRates()
    }
    
    deinit {
        cancellables.removeAll()
    }
}

// MARK: - Setup & Bindings
extension ExchangeViewModel {
    private func setupBindings() {
        // Update rates when currencies change
        Publishers.CombineLatest($firstCurrency, $secondCurrency)
            .sink { [weak self] _ in
                self?.updateConversionRates()
            }
            .store(in: &cancellables)
        
        // Fetch new rates when base currency changes
        $selectedToConvert
            .dropFirst()
            .sink { [weak self] _ in
                self?.fetchExchangeRates()
            }
            .store(in: &cancellables)
        
        // Handle errors
        $error
            .compactMap { $0 }
            .sink { errorMessage in
                print("Exchange Error: \(errorMessage)")
            }
            .store(in: &cancellables)
    }
}

// MARK: - Network Operations
extension ExchangeViewModel {
    func fetchExchangeRates() {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        
        networkManager.fetchExchangeRate(for: selectedToConvert)
        
        networkManager.exchangeRatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                    self?.resetRates()
                }
            } receiveValue: { [weak self] rates in
                self?.conversionRates = rates
                self?.isLoading = false
                self?.error = nil
                self?.updateConversionRates()
            }
            .store(in: &cancellables)
    }
    
    private func resetRates() {
        firstCurrencyRate = "..."
        secondCurrencyRate = "..."
    }
}

// MARK: - Currency Selection & Conflict Resolution
extension ExchangeViewModel {
    func showPicker(for type: CurrencyPickerType) {
        selectedPickerType = type
        showCurrencyPicker = true
    }
    
    func selectCurrency(_ currency: Currency, for type: CurrencyPickerType) {
        switch type {
        case .first:
            firstCurrency = currency
        case .second:
            secondCurrency = currency
        case .toConvert:
            selectedToConvert = currency
        }
        
        resolveCurrencyConflicts()
        updateConversionRates()
        showCurrencyPicker = false
    }
    
    private func resolveCurrencyConflicts() {
        // Prevent same currency selection
        if firstCurrency == secondCurrency {
            secondCurrency = findAlternativeCurrency(for: secondCurrency, excluding: [firstCurrency, selectedToConvert])
        }
        
        if selectedToConvert == firstCurrency || selectedToConvert == secondCurrency {
            selectedToConvert = findAlternativeCurrency(for: selectedToConvert, excluding: [firstCurrency, secondCurrency])
        }
    }
    
    private func findAlternativeCurrency(
        for currency: Currency,
        excluding excludedCurrencies: [Currency]
    ) -> Currency {
        let allCurrencies = Currency.allCases
        let availableCurrencies = allCurrencies.filter { !excludedCurrencies.contains($0) }
        return availableCurrencies.first ?? .usd
    }
}

// MARK: - Rate Calculations
extension ExchangeViewModel {
    private func updateConversionRates() {
        guard !conversionRates.isEmpty else {
            resetRates()
            return
        }
        
        firstCurrencyRate = calculateRate(for: firstCurrency)
        secondCurrencyRate = calculateRate(for: secondCurrency)
    }
    
    private func calculateRate(for targetCurrency: Currency) -> String {
        guard let targetRate = conversionRates[targetCurrency],
              let baseRate = conversionRates[selectedToConvert],
              baseRate > 0, targetRate > 0 else {
            return "..."
        }
        
        let conversionRate = targetRate / baseRate
        return formatConversionRate(conversionRate, targetCurrency: targetCurrency)
    }
    
    private func formatConversionRate(_ rate: Double, targetCurrency: Currency) -> String {
        let formattedRate = formatRateValue(rate)
        return "1 \(selectedToConvert.rawValue) = \(formattedRate) \(targetCurrency.rawValue)"
    }
    
    private func formatRateValue(_ rate: Double) -> String {
        switch rate {
        case ...0.0001: return String(format: "%.6f", rate)
        case ...0.001: return String(format: "%.5f", rate)
        case ...0.01: return String(format: "%.4f", rate)
        case ...0.1: return String(format: "%.3f", rate)
        case ...1: return String(format: "%.3f", rate)
        case ...10: return String(format: "%.2f", rate)
        case ...100: return String(format: "%.1f", rate)
        default: return String(format: "%.0f", rate)
        }
    }
}
