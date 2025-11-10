//
//  BankAccountViewModel.swift
//  Mones
//
//  Created by Zakhar on 04.11.25.
//

import Foundation
import Combine

class BankAccountViewModel: ObservableObject, Identifiable {
    let id: UUID
    
    @Published var userName: String
    @Published var userAvatar: String
    @Published var telefone: String
    @Published var email: String
    
    //MARK: - Inits
    init(id: UUID, userName: String, userAvatar: String, telefone: String, email: String) {
        self.id = id
        self.userName = userName
        self.userAvatar = userAvatar
        self.telefone = telefone
        self.email = email
    }
    
    convenience init(from model: BankAccountModel) {
        self.init(
            id: model.id,
            userName: model.userName,
            userAvatar: model.userAvatar,
            telefone: model.telefone,
            email: model.email,
        )
    }
}


