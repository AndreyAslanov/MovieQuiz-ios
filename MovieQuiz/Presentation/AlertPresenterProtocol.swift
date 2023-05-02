//
//  AlertPresenterProtocol.swift
//  MovieQuiz
//
//  Created by Андрей Асланов on 21.04.23.
//

import UIKit

protocol AlertPresenterProtocol: AnyObject {
    func showAlert (quiz result: AlertModel)
}
