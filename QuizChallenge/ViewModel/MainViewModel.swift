//
//  MainViewModel.swift
//  QuizChallenge
//
//  Created by Julio Andherson de Oliveira Silva on 28/09/19.
//  Copyright © 2019 Julio Andherson de Oliveira Silva. All rights reserved.
//

import Foundation

/// The view model to manager object Quiz.
class MainViewModel {
    /// The quiz question.
    var question: String
    /// The quiz answers list.
    var answers: [String]
    
    /// Init view model function.
    /// - Parameters:
    ///   - question: The question.
    ///   - answers: The answers list.
    init(question: String, answers: [String]) {
        self.question = question
        self.answers = answers
    }

    /// Formatter seconds to minutes with the following pattern: mm:ss
    /// - Parameter seconds: The seconds.
    /// - Returns: The formatted time.
    func formatterSeconds(seconds: Int) -> String {
        let duration: TimeInterval = Double.init(exactly: seconds)!
        
        let seconds: Int = Int(duration) % 60
        let minutes: Int = Int(duration) / 60
        
        let formattedDuration = String(format: "%02d:%02d", minutes, seconds)
        return formattedDuration
    }
}
