//
//  NetworkError.swift
//  Mones
//
//  Created by Zakhar on 13.11.25.
//

import Foundation

// MARK: - Error Handling
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode response"
        }
    }
}
