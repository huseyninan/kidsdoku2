//
//  ParentalGateView.swift
//  kidsdoku2
//
//  A parental gate that requires solving a math problem before accessing
//  subscription/purchase screens. Designed to prevent accidental purchases by children.
//

import SwiftUI

struct ParentalGateView: View {
    @Environment(\.dismiss) var dismiss
    let onSuccess: () -> Void
    
    @State private var firstNumber: Int
    @State private var secondNumber: Int
    @State private var userAnswer: String = ""
    @State private var showError = false
    @FocusState private var isInputFocused: Bool
    
    private var correctAnswer: Int {
        firstNumber + secondNumber
    }
    
    init(onSuccess: @escaping () -> Void) {
        self.onSuccess = onSuccess
        // Generate random numbers between 10 and 50 for a challenge suitable for adults
        let first = Int.random(in: 10...50)
        let second = Int.random(in: 10...50)
        _firstNumber = State(initialValue: first)
        _secondNumber = State(initialValue: second)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        Color(red: 0.95, green: 0.93, blue: 0.87),
                        Color(red: 0.90, green: 0.88, blue: 0.82)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Icon
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(Color(red: 0.7, green: 0.35, blue: 0.3))
                        .padding(.top, 20)
                    
                    // Title
                    Text(String(localized: "Parental Gate"))
                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color(red: 0.4, green: 0.25, blue: 0.15))
                    
                    // Description
                    Text(String(localized: "Please solve this math problem to continue. This helps ensure a parent is present."))
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.gray)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 32)
                    
                    // Math problem card
                    VStack(spacing: 20) {
                        Text(String(localized: "What is"))
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundStyle(Color(red: 0.4, green: 0.25, blue: 0.15))
                        
                        Text("\(firstNumber) + \(secondNumber) = ?")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(red: 0.7, green: 0.35, blue: 0.3))
                        
                        TextField("", text: $userAnswer)
                            .keyboardType(.numberPad)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(red: 0.4, green: 0.25, blue: 0.15))
                            .multilineTextAlignment(.center)
                            .frame(width: 120, height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color.white)
                                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(showError ? Color.red : Color.clear, lineWidth: 2)
                            )
                            .focused($isInputFocused)
                        
                        if showError {
                            Text(String(localized: "Incorrect answer. Please try again."))
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(Color.red)
                        }
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.white.opacity(0.7))
                            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                    )
                    .padding(.horizontal, 32)
                    
                    // Submit button
                    Button(action: checkAnswer) {
                        Text(String(localized: "Continue"))
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color(red: 0.7, green: 0.35, blue: 0.3))
                            )
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(String(localized: "Cancel")) {
                        dismiss()
                    }
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(red: 0.7, green: 0.35, blue: 0.3))
                }
            }
            .onAppear {
                isInputFocused = true
            }
        }
    }
    
    private func checkAnswer() {
        if let answer = Int(userAnswer), answer == correctAnswer {
            dismiss()
            // Small delay to allow dismiss animation to complete
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onSuccess()
            }
        } else {
            showError = true
            userAnswer = ""
            // Generate new numbers for next attempt
            firstNumber = Int.random(in: 10...50)
            secondNumber = Int.random(in: 10...50)
            HapticManager.shared.trigger(.error)
        }
    }
}

#Preview {
    ParentalGateView {
        print("Success!")
    }
}
