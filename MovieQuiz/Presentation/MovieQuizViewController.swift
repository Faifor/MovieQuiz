import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    
    // MARK: - Lifecycle
    
    private var alertPresenter: AlertPresenterProtocol?
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private var isEnabled: Bool = true
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticService = StatisticService()
    
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    
    override func viewDidLoad() {
        alertPresenter = AlertPresenter(delegate: self)

        questionFactory = QuestionFactory(delegate: self)
        
        questionFactory?.requestNextQuestion()
        
        super.viewDidLoad()
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    func show(alert: UIAlertController) {
        self.present(alert, animated: true)
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    private func show(quiz step: QuizStepViewModel) {
            imageView.image = step.image
            imageView.layer.borderColor = UIColor.ypBlack.cgColor
            textLabel.text = step.question
            counterLabel.text = step.questionNumber
        }
    
    private func show(quiz result: QuizResultsViewModel) {
            let alertModel = AlertModel(
                        title: result.title,
                        message: result.text,
                        buttonText: result.buttonText,
                        buttonAction: { [weak self] in
                            guard let self = self else { return }
                            self.currentQuestionIndex = 0
                            self.correctAnswers = 0
                            self.questionFactory?.requestNextQuestion()
                        }
                    )
                    alertPresenter?.show(alertModel: alertModel)
        }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            let quizCount = statisticService.gamesCount
            let bestGame = statisticService.bestGame
            let formattedAccuracy = String(format: "%.0f%%", statisticService.totalAccuracy * 100)
            let text = """
            Ваш результат: \(correctAnswers)/\(questionsAmount)
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
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
            }
    }
    
        private func showAnswerResult(isCorrect: Bool) {
            if isCorrect { correctAnswers += 1 }
            self.isEnabled = false
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


