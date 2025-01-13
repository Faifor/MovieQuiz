//
//  MovieQuizViewController.swift
//  MovieQuiz
//
//  Created by Данила Спиридонов on 12.01.2025.
//

import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    
    // MARK: - Lifecycle
    private let presenter = MovieQuizPresenter()
    private var alertPresenter: AlertPresenterProtocol?
    private var correctAnswers = 0
    private var isEnabled: Bool = true
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticService = StatisticService()
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    
    override func viewDidLoad() {
        alertPresenter = AlertPresenter(delegate: self)
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)

        showLoadingIndicator()
        questionFactory?.loadData()
        
        super.viewDidLoad()
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }

    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.hidesWhenStopped = true
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    func show(alert: UIAlertController) {
        self.present(alert, animated: true)
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        imageView.layer.borderColor = UIColor.ypBlack.cgColor
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let currentGameResultLine = "Ваш результат: \(correctAnswers)\\\(presenter.questionsAmount)"

        statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)

        let alertModel = AlertModel(
            title: result.title,
            message: "\(result.text)\n\n\(currentGameResultLine)",
            buttonText: result.buttonText,
            buttonAction: { [weak self] in
                guard let self = self else { return }
                self.presenter.resetQuestionIndex()
                self.correctAnswers = 0
                self.questionFactory?.requestNextQuestion()
            }
        )

        alertPresenter?.show(alertModel: alertModel)
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alertModel = AlertModel(title: "Что-то пошло не так(",
                                    message: message,
                                    buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            
            self.questionFactory?.loadData()
        }
        
        alertPresenter?.show(alertModel: alertModel)
    }
    
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
            let quizCount = statisticService.gamesCount
            let bestGame = statisticService.bestGame
            let formattedAccuracy = String(format: "%.0f%%", statisticService.totalAccuracy * 100)
            let text = """
            Количество сыгранных квизов: \(quizCount)
            Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
            Средняя точность: \(formattedAccuracy)
            """

            let results = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть еще раз")
            show(quiz: results)
        } else {
            presenter.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect { correctAnswers += 1 }
        isEnabled = false
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.yPGreen.cgColor : UIColor.yPRed.cgColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {[weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
            self.isEnabled = true
        }
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard isEnabled else { return }
        guard let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == true)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard isEnabled else { return }
        guard let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == false)
    }
}
