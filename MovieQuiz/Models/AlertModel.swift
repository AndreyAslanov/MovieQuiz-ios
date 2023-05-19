//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Андрей Асланов on 20.04.23.
//

import UIKit

struct AlertModel {
    let id: String
    let title: String
    let message: String
    let buttonText: String
    let completion: ((UIAlertAction) -> Void)?
}
