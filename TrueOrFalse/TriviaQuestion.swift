import Foundation

// API 回應的結構，遵循 Codable 協定
struct TriviaResponse: Codable {
    let results: [TriviaQuestion] // 儲存問題的數組
}

// 每道問題的結構，遵循 Codable 協定
struct TriviaQuestion: Codable, Identifiable {
    let id: UUID = UUID() // 使用 UUID 作為唯一識別碼
    var question: String   // Change 'let' to 'var'
    let correct_answer: String
    var incorrect_answers: [String] // Change 'let' to 'var'
    
    // 隨機排列所有答案，並將正確答案與錯誤答案混合
    var allAnswers: [String] {
        (incorrect_answers + [correct_answer]).shuffled()
    }
}
