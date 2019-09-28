//
//  QuizChallengeTests.swift
//  QuizChallengeTests
//
//  Created by Julio Andherson de Oliveira Silva on 28/09/19.
//  Copyright © 2019 Julio Andherson de Oliveira Silva. All rights reserved.
//

import XCTest
@testable import QuizChallenge

class QuizChallengeTests: XCTestCase {
    var mockedViewModel: MainViewModel!
    var requestViewModel: MainViewModel!
    
    override func setUp() {
        RequestManager.getQuiz { (quiz) in
            if quiz != nil {
                self.requestViewModel = MainViewModel(question: quiz!.question!, answers: quiz!.answer!)
            }
        }

        let answersList = ["abstract", "assert", "boolean", "break", "byte", "case", "catch", "char", "class", "const",
                            "continue", "default", "do", "double", "else", "enum", "extends", "final", "finally",
                            "float", "for", "goto", "if", "implements", "import", "instanceof", "int", "interface",
                            "long", "native", "new", "package", "private", "protected", "public", "return", "short",
                            "static", "strictfp", "super", "switch", "synchronized", "this", "throw", "throws",
                            "transient", "try", "void", "volatile", "while"]
        mockedViewModel = MainViewModel(question: "What are all the java keywords?", answers: answersList)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testViewModelMocked() {
        XCTAssertTrue(mockedViewModel.answers.count == 50, "Must contains 50")
        XCTAssertTrue(mockedViewModel.question == "What are all the java keywords?", "Wrong question")
    }

    func testViewModelRequest() {
        let expectation = XCTestExpectation(description: "Waiting for request...")
        XCTWaiter().wait(for: [expectation], timeout: 5)
        XCTAssertTrue(requestViewModel.answers.count == 50, "Must contains 50")
        XCTAssertTrue(requestViewModel.question == "What are all the java keywords?", "Wrong question")
    }

    func testSecondsFormatter() {
        var seconds = mockedViewModel.formatterSeconds(seconds: 300)
        XCTAssertTrue(seconds == "05:00", "Must be 05:00")
        
        seconds = mockedViewModel.formatterSeconds(seconds: 200)
        XCTAssertTrue(seconds == "03:20", "Must be 03:20")

        seconds = mockedViewModel.formatterSeconds(seconds: 150)
        XCTAssertTrue(seconds == "02:30", "Must be 02:30")

        seconds = mockedViewModel.formatterSeconds(seconds: 50)
        XCTAssertTrue(seconds == "00:50", "Must be 00:50")

        seconds = mockedViewModel.formatterSeconds(seconds: 0)
        XCTAssertTrue(seconds == "00:00", "Must be 00:00")

    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
