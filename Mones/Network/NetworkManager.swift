//
//  NetworkManager.swift
//  Mones
//
//  Created by Zakhar on 09.11.25.
//

import Foundation
import Combine

final class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    private let mainQueue = DispatchQueue.main
    private let exchangeRateSubject = PassthroughSubject<[Currency: Double], Error>()
    
    var exchangeRatePublisher: AnyPublisher<[Currency: Double], Error> {
        exchangeRateSubject.eraseToAnyPublisher()
    }
    
    func fetchExchangeRate(for currency: Currency) {
        let urlString = "\(NetworkEndPoint.exchangeRate.rawValue)\(currency.rawValue)"
        print(urlString)
        print("fetch")
        performNetworkRequest(urlString)
    }
}

extension NetworkManager {
    
    private func performNetworkRequest(_ url: String) {
        guard let url = URL(string: url) else {
            mainQueue.async { [weak self] in
                self?.exchangeRateSubject.send(completion: .failure(NetworkError.invalidURL))
            }
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            self?.handleNetworkResponse(data: data, response: response, error: error)
        }.resume()
    }
    
    private func handleNetworkResponse(data: Data?, response: URLResponse?, error: Error?) {
        if let error = error {
            mainQueue.async { [weak self] in
                self?.exchangeRateSubject.send(completion: .failure(error))
            }
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode),
              let data = data else {
            mainQueue.async { [weak self] in
                self?.exchangeRateSubject.send(completion: .failure(NetworkError.noData))
            }
            return
        }
        
        do {
            print(String(data: data, encoding: .utf8) ?? "Some error")
            let result = try decoder.decode(ExchangeRateResponse.self, from: data)
            mainQueue.async { [weak self] in
                self?.exchangeRateSubject.send(result.filteredRates) // Map to [Currecy: Double]
            }

//        } catch {
//            print(error.localizedDescription)
//            mainQueue.async { [weak self] in
//                self?.exchangeRateSubject.send(completion: .failure(NetworkError.decodingError))
//            }
        } catch let DecodingError.keyNotFound(key, context) {
            print("Missing key:", key.stringValue)
            print(context.debugDescription)
        } catch let DecodingError.valueNotFound(value, context) {
            print("Value not found for:", value)
            print(context.debugDescription)
        } catch let DecodingError.typeMismatch(type, context) {
            print("Type mismatch:", type)
            print(context.debugDescription)
        } catch {
            print("Other error:", error)
        }
        
    }
}
