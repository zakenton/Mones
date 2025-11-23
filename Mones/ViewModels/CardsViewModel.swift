//
//  CardsViewModel.swift
//  Mones
//
//  Created by Zakhar on 22.11.25.
//

import Foundation
import Combine

protocol CardIdentifiable {
    var id: UUID {get}
    var viewModel: BankCardViewModel {get}
}

struct Card: CardIdentifiable {
    let id: UUID
    let viewModel: BankCardViewModel
}

//@MainActor
final class CardsViewModel: ObservableObject {
    @Published private(set) var cards: [Card] = []
    @Published var selectedIndex: Int = 0
    
    var selectedCardPublisher: AnyPublisher<Card?, Never> {
        Publishers
            .CombineLatest($cards, $selectedIndex)
            .map { cards, index in
                guard cards.indices.contains(index) else { return nil }
                return cards[index]
            }
            .eraseToAnyPublisher()
    }
    
    init() {
        loadCards()
    }
    
    private func loadCards() {
        let mokArray = {
            BankCardViewModel.mockArray.map { Card(id: UUID(), viewModel: $0)}
        }
        self.cards = mokArray()
    }
}

//extension CardsViewModel: Mockable {
//    typealias MockObject = CardsViewModel
//    
//    static var mock: CardsViewModel {
//        let viewModel = CardsViewModel()
//        viewModel.cards = BankCardViewModel.mockArray
//        viewModel.selectedCard = BankCardViewModel.mockArray.first
//        return viewModel
//    }
//    
//    static var mockArray: [CardsViewModel] {
//        let viewModel1 = CardsViewModel()
//        viewModel1.cards = Array(BankCardViewModel.mockArray.prefix(2))
//        viewModel1.selectedCard = BankCardViewModel.mockArray.first
//        
//        let viewModel2 = CardsViewModel()
//        viewModel2.cards = Array(BankCardViewModel.mockArray.suffix(2))
//        viewModel2.selectedCard = BankCardViewModel.mockArray.last
//        
//        return [viewModel1, viewModel2]
//    }
//    
//    // Мок с пустым списком карт
//    static var mockEmpty: CardsViewModel {
//        let viewModel = CardsViewModel()
//        viewModel.cards = []
//        viewModel.isLoading = false
//        return viewModel
//    }
//    
//    // Мок с загрузкой
//    static var mockLoading: CardsViewModel {
//        let viewModel = CardsViewModel()
//        viewModel.isLoading = true
//        return viewModel
//    }
//}
//
//// MARK: - Mock Protocol
//protocol Mockable: ObservableObject {
//    associatedtype MockObject
//    static var mock: MockObject { get }
//    static var mockArray: [MockObject] { get }
//}
//
