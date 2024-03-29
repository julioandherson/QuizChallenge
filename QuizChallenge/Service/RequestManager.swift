//
//  RequestManager.swift
//  QuizChallenge
//
//  Created by Julio Andherson de Oliveira Silva on 28/09/19.
//  Copyright © 2019 Julio Andherson de Oliveira Silva. All rights reserved.
//

import Foundation

/// Resposible to manager requests.
class RequestManager {
    
    /// Request to get Quiz informations.
    /// - Parameter completionHandler: The completion handler.
    static func getQuiz(completionHandler: @escaping (Quiz?) -> Void) {
        let url = URL(string: "https://codechallenge.arctouch.com/quiz/1")!
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
            DispatchQueue.main.async {
                if error != nil {
                    print("Request error: \(error!)")
                    completionHandler(nil)
                } else {
                    do {
                        let quiz = try JSONDecoder().decode(Quiz.self, from: data!)
                        
                        completionHandler(quiz)
                    } catch {
                        print("Decode error")
                        completionHandler(nil)
                    }
                }
            }
        })
        task.resume()
    }
}
