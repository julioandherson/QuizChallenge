//
//  ViewController.swift
//  QuizChallenge
//
//  Created by Julio Andherson de Oliveira Silva on 28/09/19.
//  Copyright © 2019 Julio Andherson de Oliveira Silva. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    // MARK: Outlets
    /// The tableView.
    @IBOutlet weak var tableView: UITableView!
    /// The title of question label..
    @IBOutlet weak var titleLabel: UILabel!
    /// The hitCountLabel.
    @IBOutlet weak var hitCountLabel: UILabel!
    /// The timerLabel.
    @IBOutlet weak var timerLabel: UILabel!
    /// The startOrResetButton.
    @IBOutlet weak var startOrResetButton: UIButton!

    // MARK: View Model
    /// The MainViewModel.
    var mainViewModel: MainViewModel!

    // MARK: Variables
    /// The total time of quiz.
    var totalTimeInSeconds = 300
    /// The provisional list of hit keywords.
    var hitKeyWordsList: [String] = [String]()
    /// The hits count.
    var hitsCount = 0
    /// The total of keywords.
    var totalWords = 50
    /// The timer handler.
    var timer: Timer!
    /// The isPlaying flag.
    var isPlaying = false

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        requestQuiz()
        
//        let storyboard = UIStoryboard(name: "LoadingView", bundle: nil)
//        let myAlert = storyboard.instantiateViewController(withIdentifier: "loadingAlert")
//        myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
//        myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
//
//        self.present(myAlert, animated: true)
    }

    // MARK: Private functions
    /// Reset all quiz data.
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
    /// Request quiz data from endpoint.
    private func requestQuiz() {
        let alert = createLoadingAlert()
        self.present(alert, animated: true, completion: nil)

        RequestManager.getQuiz { (quiz) in
            alert.dismiss(animated: true, completion: {
                if quiz == nil {
                    print("Error")
                } else {
                    self.mainViewModel = MainViewModel(question: quiz!.question!, answers: quiz!.answer!)

                    self.titleLabel.text = self.mainViewModel.question
                    self.totalWords = self.mainViewModel.answers.count
                    
                    self.updateHitCountLabel()
                }
            })
        }
    }
    
    // MARK: UI
    /// Called each second to update labels or endgame.
    @objc func updateTime() {
        self.totalTimeInSeconds -= 1

        if totalTimeInSeconds < 0 {
            timer.invalidate()
            timer = nil

            showRetryAlert()
        } else {
            updateTimeLabel()
        }
    }

    /// Update time label.
    func updateTimeLabel() {
        self.timerLabel.text = mainViewModel.formatterSeconds(seconds: self.totalTimeInSeconds)
    }

    /// Update hit counting label.
    func updateHitCountLabel() {
        let formattedCount = String(format: "%02d", hitsCount)
        
        self.hitCountLabel.text = "\(formattedCount)/\(totalWords)"
    }

    /// Set button title to Start.
    func setupButtonToStart() {
        startOrResetButton.setTitle("Start", for: .normal)
    }
    
    /// Set button title to Reset.
    func setupButtonToReset() {
        startOrResetButton.setTitle("Reset", for: .normal)
    }

    // MARK: Alerts
    /// Create Alert with Loading indicator.
    /// - Returns: The alert.
    func createLoadingAlert() -> UIAlertController {

        let alert = UIAlertController(title: nil, message: "Loading...", preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();

        alert.view.addSubview(loadingIndicator)

        return alert
    }

    /// Show play again alert.
    private func showPlayAgainAlert() {
        timer.invalidate()
        timer = nil

        let alert = UIAlertController(title: "Congratulations",
                                      message: "Good job! You found all the aswers on time. Keep up with the great work.",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Play again", style: .default, handler: { _ in
            self.reset()
        }))
        self.present(alert, animated: true, completion: nil)
    }

    /// Show retry alert.
    private func showRetryAlert() {
        let alert = UIAlertController(title: "Time finished",
                                      message: "Sorry, tie is up! You got \(self.hitsCount) out of \(totalWords) answers.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Try again", style: .default, handler: { _ in
            self.reset()
        }))
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: Actions
    /// Start or Reset action.
    /// - Parameter sender: The sender.
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

    /// Callback while editing text field.
    /// - Parameter sender: The sender.
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
/// Struct to describe decodable object Quiz.
struct Quiz: Decodable {
    var question: String?
    var answer: [String]?
}
