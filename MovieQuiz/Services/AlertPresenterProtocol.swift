//
//  AlertPresenterProtocol.swift
//  MovieQuiz
//
//  Created by Данила Спиридонов on 23/11/2024.
//

import UIKit

protocol AlertPresenterProtocol: AnyObject {
    var delegate: AlertPresenterDelegate? { get set }
        func show(alertModel: AlertModel)
}
