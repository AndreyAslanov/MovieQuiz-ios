//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Андрей Асланов on 18.04.23.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer() // сообщение об успешной загрузке
    func didFailToLoadData(with error: Error) // сообщение об ошибке загрузки
}
