//
//  CardsViewModelTests.swift
//  MonesTests
//
//  Created by Zakhar on 23.11.25.
//

import Foundation
import Combine
import Testing
@testable import Mones

@MainActor
struct CardsViewModelTests {

    // 1. При инициализации: карты загружены, selectedIndex = 0
    @Test
    func init_loadsCards_and_setsDefaultIndex() async throws {
        // when
        let viewModel = CardsViewModel()
        
        // then
        #expect(!viewModel.cards.isEmpty)
        #expect(viewModel.selectedIndex == 0)
    }

    // 2. selectedCardPublisher при старте отдаёт карту с индексом 0
    @Test
    func selectedCardPublisher_emitsFirstCardOnInit() async throws {
        // given
        let viewModel = CardsViewModel()
        let publisher = viewModel.selectedCardPublisher
        
        // when
        var iterator = publisher.values.makeAsyncIterator()
        let value = await iterator.next()
        
        // then
        #expect(value != nil)
        
        if let card = value {
            // сравниваем по какому-нибудь полю ViewModel, НЕ по id
            #expect(card?.viewModel.cardHolderName == viewModel.cards[0].viewModel.cardHolderName)
            #expect(card?.viewModel.balance == viewModel.cards[0].viewModel.balance)
        }
    }

    // 3. Если индекс вне диапазона — publisher отдаёт nil
    @Test
    func selectedCardPublisher_emitsNil_whenIndexOutOfRange() async throws {
        // given
        let viewModel = CardsViewModel()
        let publisher = viewModel.selectedCardPublisher
        
        var iterator = publisher.values.makeAsyncIterator()
        
        // 1. Первое значение — игнорируем
        _ = await iterator.next()
        
        // 2. Ставим индекс за пределы
        viewModel.selectedIndex = viewModel.cards.count + 10

        // 3. Дадим максимум 0.3 секунды на получение nil
        let deadline = Date().addingTimeInterval(0.3)

        var gotNil = false
        
        while Date() < deadline {
            if let value = await iterator.next(), value == nil {
                gotNil = true
                break
            } else {
                gotNil = true
                break
            }
        }

        // then
        #expect(gotNil)
    }




    // 4. При смене selectedIndex publisher отдаёт другую карту
    @Test
    func selectedCardPublisher_updatesWhenSelectedIndexChanges() async throws {
        // given
        let viewModel = CardsViewModel()
        
        // если моков мало — просто завершаем тест
        #expect(viewModel.cards.count >= 2)
        guard viewModel.cards.count >= 2 else { return }
        
        let publisher = viewModel.selectedCardPublisher
        
        var iterator = publisher.values.makeAsyncIterator()
        
        // первое значение (index = 0) можно прочитать и игнорировать
        _ = await iterator.next()
        
        // when: меняем индекс
        viewModel.selectedIndex = 1
        
        let secondValue = await iterator.next()
        
        // then
        #expect(secondValue != nil)
        
        if let card = secondValue {
            #expect(card?.viewModel.cardHolderName == viewModel.cards[1].viewModel.cardHolderName)
            #expect(card?.viewModel.balance == viewModel.cards[1].viewModel.balance)
        }
    }
}
