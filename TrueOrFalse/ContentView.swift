import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = QuizViewModel()

    var body: some View {
        VStack {
            if let question = viewModel.currentQuestion {
                Text(question.question)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()
                    .animation(.easeInOut, value: viewModel.currentQuestionIndex)

                HStack {
                    ForEach(["True", "False"], id: \.self) { option in
                        Button(option) {
                            viewModel.submitAnswer(option)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                viewModel.nextQuestion()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.horizontal)
                    }
                }

                if viewModel.showAnswerFeedback {
                    Text(viewModel.isCorrectAnswer ? "Correct!" : "Incorrect!")
                        .font(.subheadline)
                        .foregroundColor(viewModel.isCorrectAnswer ? .green : .red)
                        .padding()
                        .transition(.scale)
                }
                
                ProgressView(value: Double(viewModel.currentQuestionIndex + 1), total: Double(viewModel.questions.count))
                    .padding()
                
                Text("Score: \(viewModel.score)")
                    .font(.subheadline)
                    .padding()

                // Show hearts
                HStack {
                    ForEach(0..<5) { index in
                        // Show hearts based on remaining lives
                        if viewModel.isGameOver {
                            // Show all hearts as empty (gray) if the game is over
                            Image(systemName: "heart")
                                .foregroundColor(.gray)
                                .font(.system(size: 24))
                        } else {
                            // Show filled hearts for remaining lives
                            Image(systemName: index < viewModel.hearts ? "heart.fill" : "heart")
                                .foregroundColor(index < viewModel.hearts ? .red : .gray)
                                .font(.system(size: 24))
                        }
                    }
                }
                .padding()

                // Game over message
                if viewModel.isGameOver {
                    Text("Game Over!")
                        .font(.title)
                        .foregroundColor(.red)
                        .padding()
                    Button("Restart Game") {
                        viewModel.score = 0
                        viewModel.hearts = 5 // Reset hearts to 5
                        viewModel.isGameOver = false
                        viewModel.currentQuestionIndex = 0
                        viewModel.fetchQuestions()
                    }
                    .buttonStyle(.bordered)
                    .padding()
                }
            } else {
                Text("Loading questions...")
            }
        }
        .onAppear {
            viewModel.fetchQuestions()
        }
    }
}
