//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Андрей Асланов on 19.05.23.
//

import UIKit

final class MovieQuizPresenter {
    
    let questionsAmount: Int = 10                                       
    private var currentQuestionIndex = 0
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
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

    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = isYes
        
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
        // блокировка кнопок ответа
//        noButton.isEnabled = false
//        yesButton.isEnabled = false
    
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
    
    func showNextQuestionOrResults() {
//        showLoadingIndicator()                            //не знаю куда 
        if self.isLastQuestion() {
            
            guard let statisticService = statisticService else {
                return
            }
            
            statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
            
            let bestGame = statisticService.bestGame
            let date = bestGame.date.dateTimeString
            let gamesCount = statisticService.gamesCount
            
            let message =   """
                            Ваш результат: \(correctAnswers)/10
                            Количество сыгранных квизов: \(gamesCount)
                            Рекорд: \(bestGame.correct)/10 (\(date))
                            Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
                            """
            
            let viewModel = QuizResultsViewModel(
                id: "Game results",
                title: "Этот раунд окончен!",
                message: message,
                buttonText: "Сыграть еще раз") {[weak self] _ in
                    guard let self = self else { return }
                    self.presenter.resetQuestionIndex()
                    self.correctAnswers = 0
                    self.questionFactory?.requestNextQuestion()
                }
            alertPresenter?.showAlert(quiz: viewModel)
            
        }else{
            presenter.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
}

