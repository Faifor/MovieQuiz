//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Данила Спиридонов on 25/11/2024.
//

import UIKit

protocol StatisicServiceProtocol {
    var gamesCount: Int { get }
    var bestGame: GameResult { get }
    var totalAccuracy: Double { get }
    
    func store(correct count: Int, total amount: Int)
}
