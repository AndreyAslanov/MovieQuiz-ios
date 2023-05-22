//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Андрей Асланов on 18.04.23.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error) 
}
