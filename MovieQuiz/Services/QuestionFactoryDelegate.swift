//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Данила Спиридонов on 20/11/2024.
//

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
}
