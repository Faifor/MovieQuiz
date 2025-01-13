//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Данила Спиридонов on 13.01.2025.
//

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
    func setButtonsEnabled(_ isEnabled: Bool)
}
