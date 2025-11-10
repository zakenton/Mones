//
//  BankAccountModel.swift
//  Mones
//
//  Created by Zakhar on 04.11.25.
//

import Foundation

struct BankAccountModel: Identifiable, Codable {
    let id: UUID
    let userName: String
    let userAvatar: String
    let telefone: String
    let email: String
}
