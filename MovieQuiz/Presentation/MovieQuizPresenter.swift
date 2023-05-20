//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Андрей Асланов on 19.05.23.
//

import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func showAlert(quiz alertModel: AlertModel)
    
    func highlightImageBorder(isCorrectAnswer: Bool)

    func showLoadingIndicator()
    func hideLoadingIndicator()

    func showNetworkError(message: String)
}

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    private let questionsAmount: Int = 10
    private var currentQuestionIndex = 0
    private var correctAnswers: Int = 0
    private var currentQuestion: QuizQuestion?
    
    private weak var viewController: MovieQuizViewControllerProtocol?
    private let statisticService: StatisticService!
    private var questionFactory: QuestionFactoryProtocol?
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController

        statisticService = StatisticServiceImplementation()

        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        self.viewController?.showLoadingIndicator()
    }
    
    //MARK: - QuestionFactoryDelegate
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData (with error: Error) {
        viewController?.showNetworkError (message: error.localizedDescription)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        
//        // разблокировка кнопок ответа
//        noButton.isEnabled = true
//        yesButton.isEnabled = true
        
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
            self?.viewController?.hideLoadingIndicator()
        }
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
         QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }
    
//    func resetQuestionIndex() {                                 //можно убрать?
//        currentQuestionIndex = 0
//    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
        self.viewController?.showLoadingIndicator()
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
        
        // блокировка кнопок ответа
//        noButton.isEnabled = false
//        yesButton.isEnabled = false
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    // блокировка кнопок ответа
//        noButton.isEnabled = false
//        yesButton.isEnabled = false

    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = isYes
        
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
        // блокировка кнопок ответа
//        noButton.isEnabled = false
//        yesButton.isEnabled = false
    
    private func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isYes: true)
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.proceedToNextQuestionOrResults()
        }
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    private func proceedToNextQuestionOrResults() {
        //        showLoadingIndicator()                            //не знаю куда
        if self.isLastQuestion() {
            let text = correctAnswers == self.questionsAmount ?
            "Поздравляем, вы ответили на 10 из 10!" :
            "Вы ответили на \(correctAnswers) из 10, попробуйте еще раз!"
            
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть еще раз")
            
            let alertModel = AlertModel(
                title: viewModel.title,
                message: viewModel.text,
                buttonText: viewModel.buttonText,
                completion: { [weak self] _ in
                    self?.restartGame()
                })
            viewController?.showAlert(quiz: alertModel)
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    func makeResultMessage() -> String {                        
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        
        let bestGame = statisticService.bestGame
        
        let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let currentGameResultLine = "Ваш результат: \(correctAnswers)\\\(questionsAmount)"
        let bestGameInfoLine = "Рекорд: \(correctAnswers)\\\(bestGame.total)"
        + " (\(bestGame.date.dateTimeString))%"
        let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        
        let resultMessage = [currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine].joined(separator: "\n")
        
        return resultMessage
    }
    
}

