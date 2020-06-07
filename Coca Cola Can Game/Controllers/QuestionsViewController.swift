//
//  QuestionsViewController.swift
//  Coca Cola Can Game
//
//  Created by macbook on 5/21/20.
//  Copyright © 2020 assylkhantleubayev. All rights reserved.
//

import UIKit
import Firebase

class QuestionsViewController: UIViewController {
    
    // MARK: - Variables
    
    var currentQuestionNumber = 0
    
    // MARK: - Outlets
    @IBOutlet weak var questionTextLabel: UILabel!
    
    @IBOutlet weak var aButton: UIButton!
    @IBOutlet weak var bButton: UIButton!
    @IBOutlet weak var cButton: UIButton!
    @IBOutlet weak var dButton: UIButton!
    
    private func setRandomButtonTitle() {
        let randomButton = Int.random(in: 0..<4)
        
        if randomButton == 0 {
            aButton.setTitle(postfeed[currentQuestionNumber].title, for: .normal)
            bButton.setTitle("Button B", for: .normal)
            cButton.setTitle("Button C", for: .normal)
            dButton.setTitle("Button D", for: .normal)
            
            sendAnswer(question: postfeed[currentQuestionNumber].text, isRight: true)
            
        } else if randomButton == 1 {
            aButton.setTitle("Button A", for: .normal)
            bButton.setTitle(postfeed[currentQuestionNumber].title, for: .normal)
            cButton.setTitle("Button C", for: .normal)
            dButton.setTitle("Button D", for: .normal)
            
            sendAnswer(question: postfeed[currentQuestionNumber].text, isRight: true)
        } else if randomButton == 2 {
            aButton.setTitle("Button A", for: .normal)
            bButton.setTitle("Button B", for: .normal)
            cButton.setTitle(postfeed[currentQuestionNumber].title, for: .normal)
            dButton.setTitle("Button D", for: .normal)
            
            sendAnswer(question: postfeed[currentQuestionNumber].text, isRight: true)
        } else {
            aButton.setTitle("Button A", for: .normal)
            bButton.setTitle("Button B", for: .normal)
            cButton.setTitle("Button C", for: .normal)
            dButton.setTitle(postfeed[currentQuestionNumber].title, for: .normal)
            
            sendAnswer(question: postfeed[currentQuestionNumber].text, isRight: true)
        }
    }
    
    private func sendAnswer(question: String, isRight: Bool) {

        // Data upload
        let POST_DB_REF: DatabaseReference = Database.database().reference().child("QuestionAnswers").childByAutoId()
        
        let timestamp = Int(Date().timeIntervalSince1970 * 1000)
        
        
        let post: [String : Any] = ["user": "Assylkhan Tleubayev",
                                    "timestamp": timestamp,
                                    "question": question,
                                    "isRight": isRight]
        
        POST_DB_REF.setValue(post)
        
    }
    
    // MARK: - Actions
    @IBAction func buttonAPressed(_ sender: UIButton) {
        currentQuestionNumber += 1
        questionTextLabel.text = postfeed[currentQuestionNumber].text
        setRandomButtonTitle()
    }
    @IBAction func buttonBPressed(_ sender: UIButton) {
        currentQuestionNumber += 1
        questionTextLabel.text = postfeed[currentQuestionNumber].text
        setRandomButtonTitle()
    }
    @IBAction func buttonCPressed(_ sender: UIButton) {
        currentQuestionNumber += 1
        questionTextLabel.text = postfeed[currentQuestionNumber].text
        setRandomButtonTitle()
    }
    @IBAction func buttonDPressed(_ sender: UIButton) {
        currentQuestionNumber += 1
        questionTextLabel.text = postfeed[currentQuestionNumber].text
        setRandomButtonTitle()
    }
    
    // MARK:- Firebase
        
    var postfeed: [DigItem] = []
    fileprivate var isLoadingPost = false // used for infinite scroll
    
    @objc fileprivate func loadRecentPosts() {
        isLoadingPost = true
        PostService.shared.getRecentDigPosts(start: postfeed.first?.timestamp, limit: 10) { (newPosts) in
            
            self.postfeed = []
            if newPosts.count > 0 {
                // Add the array to the beginning of the posts arrays
                self.postfeed.insert(contentsOf: newPosts, at: 0)
                self.questionTextLabel.text = self.postfeed[self.currentQuestionNumber].text
                self.setRandomButtonTitle()
            }
            
            self.isLoadingPost = false
            
        }
    }
    
    //MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        postfeed = []
        loadRecentPosts()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Constants.modifyNavigationController(navigationController: navigationController)
        self.title = "Опрос"
        
        postfeed = []
        loadRecentPosts()
        // Do any additional setup after loading the view.
        
        if postfeed.count > 0 {
            questionTextLabel.text = postfeed[currentQuestionNumber].text
        }
    }
    
}
