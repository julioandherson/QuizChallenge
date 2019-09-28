//
//  MainViewModel.swift
//  QuizChallenge
//
//  Created by Julio Andherson de Oliveira Silva on 28/09/19.
//  Copyright © 2019 Julio Andherson de Oliveira Silva. All rights reserved.
//

import Foundation

class MainViewModel {
    var question: String
    var answers: [String]
    
    init(question: String, answers: [String]) {
        self.question = question
        self.answers = answers
    }

    func formatterSeconds(seconds: Int) -> String {
        let duration: TimeInterval = Double.init(exactly: seconds)!
        
        let seconds: Int = Int(duration) % 60
        let minutes: Int = Int(duration) / 60
        
        let formattedDuration = String(format: "%0d:%02d", minutes, seconds)
        return formattedDuration
    }
}
