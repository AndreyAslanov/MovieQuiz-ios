//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Андрей Асланов on 20.04.23.
//

import UIKit

final class AlertPresenter: AlertPresenterProtocol {
    private weak var viewController: UIViewController?
    private var presenter: MovieQuizPresenter
    init(viewController: UIViewController?, presenter: MovieQuizPresenter) {
        self.viewController = viewController
        self.presenter = presenter
    }

    func showAlert(quiz alertModel: AlertModel) {
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert
        )
        
//        alert.view.accessibilityIdentifier = "Game results"
        
        let action = UIAlertAction(
            title: alertModel.buttonText,
            style: .default,
            handler: alertModel.completion
        )
        alert.addAction(action)
        viewController?.present(alert, animated: true, completion: nil)
    }
    
}
