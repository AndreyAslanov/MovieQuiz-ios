//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by Андрей Асланов on 18.04.23.
//

import Foundation

protocol QuestionFactoryProtocol:AnyObject {
    func requestNextQuestion()
    func loadData()
}




