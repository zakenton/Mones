//
//  NetworkManager.swift
//  Mones
//
//  Created by Zakhar on 09.11.25.
//

import Foundation

final class NetworkManager {
    private init() {}
    
    static let shared = NetworkManager()
    
    func fetchExchangeRate() {
        let urlString = NetworkEndPoint.exchangeRate.rawValue
        guard let url = URL(string: urlString) else {
            print("error create url")
            return
        }
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
        }
        
        
    }
}
