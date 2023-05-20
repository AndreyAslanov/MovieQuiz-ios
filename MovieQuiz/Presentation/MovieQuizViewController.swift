import UIKit
import Foundation

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    // MARK: - Lifecycle
    
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var questionTitleLabel: UILabel!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    
    //    private var correctAnswers = 0
    //    private var currentQuestion: QuizQuestion?                  // не знаю убрать или нет
    //    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter: AlertPresenterProtocol?
    //    private var statisticService: StatisticService?
    private var presenter = MovieQuizPresenter!                // добавил
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MovieQuizPresenter(viewController: self)
        alertPresenter = AlertPresenter(viewController: self, presenter: presenter)
        showLoadingIndicator()
        
        textLabel.font = UIFont(name:"YSDisplay-Bold", size: 23)
        counterLabel.font = UIFont(name:"YSDisplay-Medium", size: 20)
        yesButton.titleLabel?.font = UIFont(name:"YSDisplay-Medium", size: 20)
        noButton.titleLabel?.font = UIFont(name:"YSDisplay-Medium", size: 20)
        questionTitleLabel.font = UIFont(name:"YSDisplay-Medium", size: 20)
        
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        
        //        questionFactory = QuestionFactory (moviesLoader: MoviesLoader(), delegate: self)
        //        statisticService = StatisticServiceImplementation()
        //
        //
        //        questionFactory?.loadData()
        
        
    }
    // MARK: - QuestionFactoryDelegate
    
    
    //        func didReceiveNextQuestion(question: QuizQuestion?) {
    //        hideLoadingIndicator()
    //        guard let question = question else {
    //            return
    //        }
    //
    //        currentQuestion = question
    //
    //        // разблокировка кнопок ответа
    //        noButton.isEnabled = true
    //        yesButton.isEnabled = true
    //
    //        let viewModel = presenter.convert(model: question)
    //        DispatchQueue.main.async { [weak self] in
    //            self?.show(quiz: viewModel)
    //        }
    //    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    //        // блокировка кнопок ответа                                   //не знаю что с этим делать
    //        noButton.isEnabled = false
    //        yesButton.isEnabled = false
    //
    //        let givenAnswer = false
    //
    //        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    func enableButtons() {
        noButton.isEnabled = true
        yesButton.isEnabled = true
    }
    
    func disableButtons() {
        noButton.isEnabled = false
        yesButton.isEnabled = false
    }
    
    //        // блокировка кнопок ответа                                   //не знаю что с этим делать
    //        noButton.isEnabled = false
    //        yesButton.isEnabled = false
    //
    //        let givenAnswer = true
    //
    //        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    //    }
    // метод конвертации, который принимает моковый вопрос и возвращает вью модель для экрана вопроса
    //    private func convert(model: QuizQuestion) -> QuizStepViewModel {
    //        return QuizStepViewModel(
    //            image: UIImage(data: model.image) ?? UIImage(),
    //            question: model.text,
    //            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    //    }
    
    // метод вывода на экран вопроса
    func show(quiz step: QuizStepViewModel) {
        enableButtons()
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    // метод для показа результатов раунда квиза
    func show(quiz alertModel: AlertModel) {
        
        let message = presenter.makeResultMessage()
        
        let alert = UIAlertController(
            title: alertModel.title,
            message: message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: alertModel.buttonText, style: .default) { [weak self] _ in
            guard let self = self else { return }
            alertModel.completion()
            self.presenter.restartGame()
        }
        
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
        alert.view.accessibilityIdentifier = "Game result"
    }
    // метод, который меняет цвет рамки
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        disableButtons()

    }

//    private func showNextQuestionOrResults() {
//        showLoadingIndicator()
//        if presenter.isLastQuestion() {
//            
//            guard let statisticService = statisticService else {
//                return
//            }
//            
//            statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
//            
//            let bestGame = statisticService.bestGame
//            let date = bestGame.date.dateTimeString
//            let gamesCount = statisticService.gamesCount
//            
//            let message =   """
//                            Ваш результат: \(correctAnswers)/10
//                            Количество сыгранных квизов: \(gamesCount)
//                            Рекорд: \(bestGame.correct)/10 (\(date))
//                            Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
//                            """
//            
//            let viewModel: AlertModel = AlertModel(
//                id: "Game results",
//                title: "Этот раунд окончен!",
//                message: message,
//                buttonText: "Сыграть еще раз") {[weak self] _ in
//                    guard let self = self else { return }
//                    self.presenter.resetQuestionIndex()
//                    self.correctAnswers = 0
//                    self.questionFactory?.requestNextQuestion()
//                }
//            alertPresenter?.showAlert(quiz: viewModel)
//            
//        }else{
//            presenter.switchToNextQuestion()
//            questionFactory?.requestNextQuestion()
//        }
//    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(
                               title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] _ in
            guard let self = self else { return }
            
            self.presenter.restartGame()
            
        }
        alertPresenter?.showAlert(quiz: model)
    }
    
//    func didLoadDataFromServer() {
//        hideLoadingIndicator()
//        questionFactory?.requestNextQuestion()
//    }
//    
//    func didFailToLoadData (with error: Error) {
//        showNetworkError (message: error.localizedDescription)
//    }

        /*
         Mock-данные
         
         
         Картинка: The Godfather
         Настоящий рейтинг: 9,2
         Вопрос: Рейтинг этого фильма больше чем 6?
         Ответ: ДА
         
         
         Картинка: The Dark Knight
         Настоящий рейтинг: 9
         Вопрос: Рейтинг этого фильма больше чем 6?
         Ответ: ДА
         
         
         Картинка: Kill Bill
         Настоящий рейтинг: 8,1
         Вопрос: Рейтинг этого фильма больше чем 6?
         Ответ: ДА
         
         
         Картинка: The Avengers
         Настоящий рейтинг: 8
         Вопрос: Рейтинг этого фильма больше чем 6?
         Ответ: ДА
         
         
         Картинка: Deadpool
         Настоящий рейтинг: 8
         Вопрос: Рейтинг этого фильма больше чем 6?
         Ответ: ДА
         
         
         Картинка: The Green Knight
         Настоящий рейтинг: 6,6
         Вопрос: Рейтинг этого фильма больше чем 6?
         Ответ: ДА
         
         
         Картинка: Old
         Настоящий рейтинг: 5,8
         Вопрос: Рейтинг этого фильма больше чем 6?
         Ответ: НЕТ
         
         
         Картинка: The Ice Age Adventures of Buck Wild
         Настоящий рейтинг: 4,3
         Вопрос: Рейтинг этого фильма больше чем 6?
         Ответ: НЕТ
         
         
         Картинка: Tesla
         Настоящий рейтинг: 5,1
         Вопрос: Рейтинг этого фильма больше чем 6?
         Ответ: НЕТ
         
         
         Картинка: Vivarium
         Настоящий рейтинг: 5,8
         Вопрос: Рейтинг этого фильма больше чем 6?
         Ответ: НЕТ
         */
    }

