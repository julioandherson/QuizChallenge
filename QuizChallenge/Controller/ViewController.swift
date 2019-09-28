//
//  ViewController.swift
//  QuizChallenge
//
//  Created by Julio Andherson de Oliveira Silva on 28/09/19.
//  Copyright © 2019 Julio Andherson de Oliveira Silva. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hitCountLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!

    @IBOutlet weak var startOrResetButton: UIButton!

    var mainViewModel: MainViewModel!
    
    var totalTimeInSeconds = 300
    
    var hitKeyWordsList: [String] = [String]()
    var hitsCount = 0
    var totalWords = 50

    var timer: Timer!

    var isPlaying = false

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        requestQuiz()
    }

    // MARK: Private functions
    private func reset() {
        hitsCount = 0
        totalTimeInSeconds = 300
        isPlaying = false
        
        setupButtonToStart()
        updateHitCountLabel()
        updateTimeLabel()

        hitKeyWordsList.removeAll()
        tableView.reloadData()
    }
    // MARK: Request
    private func requestQuiz() {
        RequestManager.getQuiz { (quiz) in
            if quiz == nil {
                print("error")
            } else {
                self.mainViewModel = MainViewModel(question: quiz!.question!, answers: quiz!.answer!)

                self.titleLabel.text = self.mainViewModel.question
                self.totalWords = self.mainViewModel.answers.count

                self.updateHitCountLabel()
            }
        }
    }
    
    // MARK: UI
    @objc func updateTime() {
        self.totalTimeInSeconds -= 1
        print("### Time in seconds: \(self.totalTimeInSeconds) - Time formatted \(mainViewModel.formatterSeconds(seconds: self.totalTimeInSeconds))")

        if totalTimeInSeconds < 0 {
            timer.invalidate()
            timer = nil

            showRetryAlert()
        } else {
            updateTimeLabel()
        }
    }

    func updateTimeLabel() {
        self.timerLabel.text = mainViewModel.formatterSeconds(seconds: self.totalTimeInSeconds)
    }

    func updateHitCountLabel() {
        self.hitCountLabel.text = "\(hitsCount)/\(totalWords)"
    }

    func setupButtonToStart() {
        startOrResetButton.setTitle("Start", for: .normal)
    }

    func setupButtonToReset() {
        startOrResetButton.setTitle("Reset", for: .normal)
    }

    // MARK: Alerts
    private func showPlayAgainAlert() {
        timer.invalidate()
        timer = nil

        let alert = UIAlertController(title: "Congratulations",
                                      message: "Good job! You found all the aswers on time. Keep up with the great work.",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Play again", style: .default, handler: { _ in
            print("Should play again")
            self.reset()
        }))
        self.present(alert, animated: true, completion: nil)
    }

    private func showRetryAlert() {
        let alert = UIAlertController(title: "Time finished",
                                      message: "Sorry, tie is up! You got \(self.hitsCount) out of \(totalWords) answers.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Try again", style: .default, handler: { _ in
            print("Should try again")
            self.reset()
        }))
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: Actions
    @IBAction func startOrResetAction(_ sender: UIButton) {
        self.isPlaying = !self.isPlaying
        
        if isPlaying {
            setupButtonToReset()
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
            
        } else {
            timer.invalidate()
            timer = nil
            reset()
        }
    }

    @IBAction func onEditingKeyWord(_ sender: UITextField) {
        if isPlaying {
            if let typedWord = sender.text {
                for keyWord in self.mainViewModel.answers where typedWord == keyWord && !hitKeyWordsList.contains(keyWord){
                    self.hitKeyWordsList.insert(keyWord, at: 0)
                    
                    self.hitsCount += 1
                    self.updateHitCountLabel()
                    
                    sender.text = ""
                    tableView.reloadData()
                }
                if hitsCount == mainViewModel.answers.count {
                    showPlayAgainAlert()
                }
            }
        }
    }
}

// MARK: TableView
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hitKeyWordsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = UITableViewCell()
        cell.textLabel?.text = self.hitKeyWordsList[indexPath.row]

        return cell
    }
}

// MARK: Decodable Struct
struct Quiz: Decodable {
    var question: String?
    var answer: [String]?
}

