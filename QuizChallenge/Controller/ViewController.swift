//
//  ViewController.swift
//  QuizChallenge
//
//  Created by Julio Andherson de Oliveira Silva on 28/09/19.
//  Copyright © 2019 Julio Andherson de Oliveira Silva. All rights reserved.
//

import UIKit

/// The main ViewController.
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
    /// The keyboardTextField.
    @IBOutlet weak var keywordTextField: UITextField!

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

    // MARK: Constraints
    /// The keyboardAdjusted flag.
    var keyboardAdjusted = false
    /// The keyboardOffset.
    var lastKeyboardOffset: CGFloat = 0
    /// The bottomView Constraint.
    @IBOutlet weak var bottomViewConstraint: NSLayoutConstraint!
    /// The titleLabelHeight Constraint.
    @IBOutlet weak var titleLabelHeightConstraint: NSLayoutConstraint!
    /// The titleLabelTopConstraint.
    @IBOutlet weak var titleLabelTopConstraint: NSLayoutConstraint!
    /// The bottomViewHeightConstraint.
    @IBOutlet weak var bottomViewHeightConstraint: NSLayoutConstraint!

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        keywordTextField.delegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification , object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        requestQuiz()
    }

    // MARK: Constraints Adjusts
    /// Show keyboard callback.
    /// - Parameter notification: The notification
    @objc func keyboardWillShow(notification: NSNotification) {
        if keyboardAdjusted == false {
            lastKeyboardOffset = getKeyboardHeight(notification: notification)

            bottomViewConstraint.constant -= lastKeyboardOffset
            keyboardAdjusted = true

            if UIDevice.current.orientation.isLandscape {
                titleLabelHeightConstraint.constant = 0
                titleLabelTopConstraint.constant = 5
            } else {
                setupDefaultPortraitConstraints()
            }
        }
    }

    /// Hide keyboard callback.
    /// - Parameter notification: The notification.
    @objc func keyboardWillHide(notification: NSNotification) {
        if keyboardAdjusted == true {
            bottomViewConstraint.constant += lastKeyboardOffset

            titleLabelHeightConstraint.constant = 95
            titleLabelTopConstraint.constant = 44
            keyboardAdjusted = false

            if UIDevice.current.orientation.isLandscape {
                titleLabelHeightConstraint.constant = 16
                titleLabelTopConstraint.constant = 5
            } else {
                setupDefaultPortraitConstraints()
            }
        }
    }

    /// Get keyboard size.
    /// - Parameter notification: The notification.
    /// - Returns: The size.
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }

    /// Setup constraints values for constraints with portraint orientation.
    func setupDefaultPortraitConstraints() {
        titleLabelHeightConstraint.constant = 95
        titleLabelTopConstraint.constant = 44
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
                    let alert = UIAlertController.init(title: NSLocalizedString("request.error.title", comment: "The request title error"),
                                                       message: NSLocalizedString("request.error.message", comment: "The request message error"),
                                                       preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("alert.retry.button", comment: "The request retry button"),
                                                  style: .default, handler: { _ in
                        self.requestQuiz()
                    }))
                    self.present(alert, animated: true, completion: nil)
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
        startOrResetButton.setTitle(NSLocalizedString("start", comment: "The start button"), for: .normal)
    }
    
    /// Set button title to Reset.
    func setupButtonToReset() {
        startOrResetButton.setTitle(NSLocalizedString("reset", comment: "The reset button"), for: .normal)
    }

    // MARK: Alerts
    /// Create Alert with Loading indicator.
    /// - Returns: The alert.
    func createLoadingAlert() -> UIAlertController {
        let alert = UIAlertController(title: nil,
                                      message: NSLocalizedString("loading", comment: "The loading message"),
                                      preferredStyle: .alert)

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

        let alert = UIAlertController(title: NSLocalizedString("alert.success.title", comment: "The success title"),
                                      message: NSLocalizedString("alert.success.message", comment: "The success message"),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("alert.success.button", comment: "The success button"),
                                      style: .default, handler: { _ in
            self.reset()
        }))
        self.present(alert, animated: true, completion: nil)
    }

    /// Show retry alert.
    private func showRetryAlert() {
        
        let alert = UIAlertController(title: NSLocalizedString("alert.retry.title", comment: "The retry title"),
                                      message: String(format: NSLocalizedString("alert.retry.message", comment: "The retry message"),
                                               String(self.hitsCount), String(self.totalWords)),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("alert.retry.button", comment: "The retry button"),
                                      style: .default, handler: { _ in
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

// MARK: TableView Delegate
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hitKeyWordsList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = self.hitKeyWordsList[indexPath.row].firstUppercased

        return cell
    }
}

// MARK: TextField Delegate
extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

// MARK: StringProtocol
extension StringProtocol {

    /// First character uppercased.
    var firstUppercased: String {
        return prefix(1).uppercased() + dropFirst()
    }
}

// MARK: Decodable Struct
/// Struct to describe decodable object Quiz.
struct Quiz: Decodable {
    var question: String?
    var answer: [String]?
}
