//
//  DependencyContainer.swift
//  Mones
//
//  Created by Zakhar on 06.11.25.
//

import Foundation
import LocalAuthentication

final class DependencyContainer {
    private let urlSession: URLSession = URLSession.shared
    
    let bankAccountViewModel: BankAccountViewModel
    let cardsViewModel: CardsViewModel
    
    init() {
        self.bankAccountViewModel = BankAccountViewModel(id: UUID(),
                                                         userName: "User name",
                                                         userAvatar: "person",
                                                         telefone: "+38045661199",
                                                         email: "UserEmail@mail.com")
        self.cardsViewModel = CardsViewModel()
    }
}
