//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Данила Спиридонов on 21/11/2024.
//

import UIKit

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let buttonAction: (() -> Void)?
}
