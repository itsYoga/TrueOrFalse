import Foundation
import SwiftUI

class QuizViewModel: ObservableObject {
    @Published var questions: [TriviaQuestion] = []
    @Published var currentQuestionIndex = 0
    @Published var score = 0
    @Published var hearts = 5  // Starts with 5 hearts
    @Published var showAnswerFeedback = false
    @Published var isCorrectAnswer = false
    @Published var isGameOver = false  // To track game over state
    
    var currentQuestion: TriviaQuestion? {
        questions.isEmpty ? nil : questions[currentQuestionIndex]
    }
    
    var difficulty: String = "Easy"  // Default difficulty, can be changed to Medium or Hard
    
    init() {
        fetchQuestions()
    }
    
    func fetchQuestions() {
        let urlString = "https://opentdb.com/api.php?amount=10&type=boolean"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decodedResponse = try JSONDecoder().decode(TriviaResponse.self, from: data)

                    // Decode all questions and answers
                    let decodedQuestions = decodedResponse.results.map { triviaQuestion in
                        var newQuestion = triviaQuestion
                        newQuestion.question = triviaQuestion.question.htmlDecoded
                        newQuestion.incorrect_answers = triviaQuestion.incorrect_answers.map { $0.htmlDecoded }
                        return newQuestion
                    }

                    DispatchQueue.main.async {
                        self.questions = decodedQuestions
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            } else if let error = error {
                print("Network error: \(error)")
            }
        }.resume()
    }
    
    func submitAnswer(_ answer: String) {
        guard let question = currentQuestion else { return }
        
        // Check if the answer is correct
        isCorrectAnswer = (answer == question.correct_answer)
        
        if isCorrectAnswer {
            // Update the score based on difficulty
            switch difficulty {
            case "Medium":
                score += 2
            case "Hard":
                score += 3
            default:
                score += 1
            }
        } else {
            // Deduct one heart for incorrect answers
            hearts -= 1
        }
        
        // Show feedback for a short time
        showAnswerFeedback = true
        
        // Check if game is over (no hearts left)
        if hearts == 0 {
            isGameOver = true
        }
    }
    
    func nextQuestion() {
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            showAnswerFeedback = false
        } else {
            // Game is over when all questions are answered
            isGameOver = true
        }
    }
}
