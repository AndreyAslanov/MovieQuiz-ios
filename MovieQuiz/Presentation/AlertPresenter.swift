//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Андрей Асланов on 20.04.23.
//

import UIKit

final class AlertPresenter: AlertPresenterProtocol {
    private weak var viewController: UIViewController?
    init(viewController: UIViewController?) {
        self.viewController = viewController
    }

    func showAlert(quiz alertModel: AlertModel) {
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(
            title: alertModel.buttonText,
            style: .default,
            handler: alertModel.completion
        )
        
        alert.view.accessibilityIdentifier = "Game results"
        alert.addAction(action)
        viewController?.present(alert, animated: true, completion: nil)
    }
    
}
