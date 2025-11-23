//
//  ExchangeRateView.swift
//  Mones
//
//  Created by Zakhar on 17.11.25.
//

import Foundation
import SwiftUI

struct ExchangeRateView: View {
    
    @ObservedObject var vm: ExchangeViewModel
    
    var body: some View {
        VStack(spacing: 10) {
            // Selected Currency
            HStack {
                Text(vm.selectedToConvert.flag)
                Text(vm.selectedToConvert.name)
            }
            
            HStack {
                CurrencyRateRow(
                    currency: vm.firstCurrency,
                    rateText: vm.firstCurrencyRate
                )
                
                Spacer(minLength: 16)
                
                CurrencyRateRow(
                    currency: vm.secondCurrency,
                    rateText: vm.secondCurrencyRate
                )
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.black.opacity(0.2))
            }
        }
        .padding(20)
        .applyGlassEffect()
        .onTapGesture {
            vm.fetchExchangeRates()
        }
    }
}

fileprivate struct CurrencyRateRow: View {
    let currency: Currency
    let rateText: String
    
    var body: some View {
        HStack {
            Text(currency.flag)
                .font(.system(size: 20))
                .padding(10)
                .background {
                    Circle()
                        .fill(.black.opacity(0.2))
                }
            
            VStack(alignment: .leading) {
                Text(currency.name)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.black.opacity(0.6))
                
                Text(rateText)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
            }
        }
    }
}

