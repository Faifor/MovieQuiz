//
//  GameResult.swift
//  MovieQuiz
//
//  Created by Данила Спиридонов on 25/11/2024.
//

import UIKit

struct GameResult: Codable {
    let correct: Int
    let total: Int
    let date: Date
    
    func isBetterThan(_ another: GameResult) -> Bool {
        correct > another.correct
    }
}
