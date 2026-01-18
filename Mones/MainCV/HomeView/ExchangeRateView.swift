//
//  ExchangeRateView.swift
//  Mones
//
//  Created by Zakhar on 17.11.25.
//

import SwiftUI

struct ExchangeRateView: View {
    @ObservedObject var vm: ExchangeViewModel
    
    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                // Base Currency Header
                baseCurrencyHeader
                
                // Currency Rates
                HStack {
                    currencyRow(
                        currency: vm.firstCurrency,
                        rateText: vm.firstCurrencyRate,
                        type: .first
                    )
                    
                    Spacer(minLength: 16)
                    
                    currencyRow(
                        currency: vm.secondCurrency,
                        rateText: vm.secondCurrencyRate,
                        type: .second
                    )
                }
                .padding(16)
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
            .sheet(isPresented: $vm.showCurrencyPicker) {
                CurrencyPickerView(
                    selectedCurrency: bindingForPickerType(),
                    isPresented: $vm.showCurrencyPicker
                )
            }
            
            // Loading Overlay
            if vm.isLoading {
                LoadingOverlay()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: vm.isLoading)
    }
}

// MARK: - Custom Loading Overlay
struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            // Loading content
            VStack(spacing: 20) {
                CustomProgressView()
                    .scaleEffect(1.2)
                
                Text("Updating exchange rates...")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            )
        }
        .transition(.opacity)
    }
}

// MARK: - Custom Progress View
struct CustomProgressView: View {
    @State private var isRotating = 0.0
    
    var body: some View {
        Circle()
            .trim(from: 0.0, to: 0.7)
            .stroke(
                AngularGradient(
                    gradient: Gradient(colors: [
                        .blue,
                        .purple,
                        .blue
                    ]),
                    center: .center,
                    startAngle: .degrees(0),
                    endAngle: .degrees(360)
                ),
                style: StrokeStyle(lineWidth: 4, lineCap: .round)
            )
            .frame(width: 40, height: 40)
            .rotationEffect(Angle(degrees: isRotating))
            .onAppear {
                withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                    isRotating = 360.0
                }
            }
    }
}

// MARK: - Alternative Progress View Styles
struct DotsProgressView: View {
    @State private var dotScale: [Double] = [0.5, 0.7, 0.5]
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 10, height: 10)
                    .scaleEffect(dotScale[index])
                    .onAppear {
                        withAnimation(
                            .easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2)
                        ) {
                            dotScale[index] = dotScale[index] == 0.5 ? 1.0 : 0.5
                        }
                    }
            }
        }
    }
}

struct PulseProgressView: View {
    @State private var pulseScale: Double = 1.0
    
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [.blue, .purple]),
                    center: .center,
                    startRadius: 5,
                    endRadius: 20
                )
            )
            .frame(width: 40, height: 40)
            .scaleEffect(pulseScale)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    pulseScale = 1.3
                }
            }
    }
}

// MARK: - View Components
extension ExchangeRateView {
    private var baseCurrencyHeader: some View {
        HStack {
            Text(vm.selectedToConvert.flag)
                .font(.title2)
            Text(vm.selectedToConvert.name)
                .font(.headline)
            Text(vm.selectedToConvert.rawValue)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Image(systemName: "chevron.down")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .onTapGesture {
            vm.showPicker(for: .toConvert)
        }
    }
    
    private func currencyRow(
        currency: Currency,
        rateText: String,
        type: CurrencyPickerType
    ) -> some View {
        CurrencyRateRow(
            currency: currency,
            rateText: rateText,
            baseCurrency: vm.selectedToConvert
        )
        .onTapGesture {
            vm.showPicker(for: type)
        }
    }
    
    private func bindingForPickerType() -> Binding<Currency> {
        switch vm.selectedPickerType {
        case .first: return $vm.firstCurrency
        case .second: return $vm.secondCurrency
        case .toConvert: return $vm.selectedToConvert
        }
    }
}

// MARK: - Supporting Views (без изменений)
struct CurrencyPickerView: View {
    @Binding var selectedCurrency: Currency
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            List(Currency.allCases, id: \.self) { currency in
                CurrencyRow(
                    currency: currency,
                    isSelected: currency == selectedCurrency
                ) {
                    selectedCurrency = currency
                    isPresented = false
                }
            }
            .navigationTitle("Select Currency")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

private struct CurrencyRow: View {
    let currency: Currency
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        HStack {
            Text(currency.flag)
            Text(currency.rawValue)
            Text(currency.name)
                .foregroundColor(.secondary)
            Spacer()
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundColor(.blue)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: action)
    }
}

struct CurrencyRateRow: View {
    let currency: Currency
    let rateText: String
    let baseCurrency: Currency
    
    var body: some View {
        HStack(spacing: 12) {
            Text(currency.flag)
                .font(.system(size: 20))
                .frame(width: 40, height: 40)
                .background {
                    Circle()
                        .fill(.black.opacity(0.2))
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(currency.name)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.black.opacity(0.6))
                
                Text(rateText)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.primary)
            }
        }
    }
}
