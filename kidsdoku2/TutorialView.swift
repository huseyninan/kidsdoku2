import SwiftUI

struct TutorialView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep = 0
    private let totalSteps = 4
    
    var body: some View {
        NavigationView {
            ZStack {
                // Match the fox background theme with a warm gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.95, green: 0.93, blue: 0.87),
                        Color(red: 0.92, green: 0.88, blue: 0.80)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerSection
                        
                        // Tutorial content based on current step
                        tutorialContent
                        
                        // Navigation buttons
                        navigationButtons
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("How to Play")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.headline)
                    .foregroundColor(Color(red: 0.7, green: 0.35, blue: 0.3))
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Text("🧩")
                .font(.system(size: 60))
            
            Text("Sudoku for Kids")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(Color(red: 0.4, green: 0.25, blue: 0.15))
                .multilineTextAlignment(.center)
            
            Text("Learn to play step by step!")
                .font(.title3)
                .foregroundColor(Color(red: 0.7, green: 0.35, blue: 0.3))
        }
        .padding(.bottom, 10)
    }
    
    @ViewBuilder
    private var tutorialContent: some View {
        switch currentStep {
        case 0:
            introductionStep
        case 1:
            rule1Step
        case 2:
            rule2Step
        case 3:
            rule3Step
        default:
            introductionStep
        }
    }
    
    private var introductionStep: some View {
        VStack(spacing: 20) {
            Text("What is Sudoku?")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Sudoku is a fun puzzle game where you fill empty boxes with emojis!")
                    .font(.body)
                
                Text("In our 4×4 game, you use 4 different emojis.")
                    .font(.body)
                
                Text("**The Goal:** Place each emoji exactly once in every row, column, and 2×2 box!")
                    .font(.body)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color(red: 0.7, green: 0.35, blue: 0.3).opacity(0.15))
                    .cornerRadius(12)
            }
            
            // Sample emoji display
            HStack(spacing: 16) {
                ForEach(["🐦", "🐱", "🐸", "🦋"], id: \.self) { emoji in
                    Text(emoji)
                        .font(.system(size: 40))
                        .frame(width: 60, height: 60)
                        .background(Color(red: 0.95, green: 0.93, blue: 0.87))
                        .cornerRadius(12)
                        .shadow(color: Color(red: 0.4, green: 0.25, blue: 0.15).opacity(0.1), radius: 2, x: 0, y: 1)
                }
            }
            .padding(.top, 8)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var rule1Step: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Rule 1: Rows")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("→")
                    .font(.title)
                    .foregroundColor(Color(red: 0.7, green: 0.35, blue: 0.3))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("Each **ROW** (→) must have all 4 different emojis")
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Example row
            VStack(spacing: 12) {
                Text("✅ Correct Row:")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(spacing: 4) {
                    ForEach(["🐦", "🐱", "🐸", "🦋"], id: \.self) { emoji in
                        Text(emoji)
                            .font(.system(size: 28))
                            .frame(width: 50, height: 50)
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.green, lineWidth: 2)
                            )
                    }
                    Text("→")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .padding(.leading, 8)
                }
                
                Text("❌ Wrong Row:")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)
                
                HStack(spacing: 4) {
                    ForEach(["🐦", "🐱", "🐦", "🦋"], id: \.self) { emoji in
                        Text(emoji)
                            .font(.system(size: 28))
                            .frame(width: 50, height: 50)
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.red, lineWidth: 2)
                            )
                    }
                    Text("→")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .padding(.leading, 8)
                }
                
                Text("Two 🐦 in the same row!")
                    .font(.caption)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var rule2Step: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Rule 2: Columns")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("↓")
                    .font(.title)
                    .foregroundColor(Color(red: 0.45, green: 0.28, blue: 0.15))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("Each **COLUMN** (↓) must have all 4 different emojis")
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Example columns
            HStack(spacing: 40) {
                VStack(spacing: 8) {
                    Text("✅ Correct")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                    
                    VStack(spacing: 4) {
                        ForEach(["🐦", "🐱", "🐸", "🦋"], id: \.self) { emoji in
                            Text(emoji)
                                .font(.system(size: 24))
                                .frame(width: 40, height: 40)
                                .background(Color.white)
                                .cornerRadius(6)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.green, lineWidth: 2)
                                )
                        }
                    }
                    
                    Text("↓")
                        .font(.title3)
                        .foregroundColor(.purple)
                }
                
                VStack(spacing: 8) {
                    Text("❌ Wrong")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                    
                    VStack(spacing: 4) {
                        ForEach(["🐦", "🐱", "🐱", "🦋"], id: \.self) { emoji in
                            Text(emoji)
                                .font(.system(size: 24))
                                .frame(width: 40, height: 40)
                                .background(Color.white)
                                .cornerRadius(6)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.red, lineWidth: 2)
                                )
                        }
                    }
                    
                    Text("↓")
                        .font(.title3)
                        .foregroundColor(.purple)
                }
            }
            
            Text("Two 🐱 in the same column!")
                .font(.caption)
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var rule3Step: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Rule 3: 2×2 Boxes")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("⬜")
                    .font(.title)
                    .foregroundColor(Color(red: 0.85, green: 0.75, blue: 0.6))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("Each **2×2 BOX** must have all 4 different emojis")
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Example 2x2 boxes
            HStack(spacing: 40) {
                VStack(spacing: 8) {
                    Text("✅ Correct Box")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                    
                    VStack(spacing: 2) {
                        HStack(spacing: 2) {
                            Text("🐦")
                                .font(.system(size: 20))
                                .frame(width: 35, height: 35)
                                .background(Color.white)
                                .cornerRadius(4)
                            Text("🐱")
                                .font(.system(size: 20))
                                .frame(width: 35, height: 35)
                                .background(Color.white)
                                .cornerRadius(4)
                        }
                        HStack(spacing: 2) {
                            Text("🐸")
                                .font(.system(size: 20))
                                .frame(width: 35, height: 35)
                                .background(Color.white)
                                .cornerRadius(4)
                            Text("🦋")
                                .font(.system(size: 20))
                                .frame(width: 35, height: 35)
                                .background(Color.white)
                                .cornerRadius(4)
                        }
                    }
                    .padding(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.green, lineWidth: 3)
                    )
                }
                
                VStack(spacing: 8) {
                    Text("❌ Wrong Box")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                    
                    VStack(spacing: 2) {
                        HStack(spacing: 2) {
                            Text("🐦")
                                .font(.system(size: 20))
                                .frame(width: 35, height: 35)
                                .background(Color.white)
                                .cornerRadius(4)
                            Text("🐱")
                                .font(.system(size: 20))
                                .frame(width: 35, height: 35)
                                .background(Color.white)
                                .cornerRadius(4)
                        }
                        HStack(spacing: 2) {
                            Text("🐦")
                                .font(.system(size: 20))
                                .frame(width: 35, height: 35)
                                .background(Color.white)
                                .cornerRadius(4)
                            Text("🦋")
                                .font(.system(size: 20))
                                .frame(width: 35, height: 35)
                                .background(Color.white)
                                .cornerRadius(4)
                        }
                    }
                    .padding(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.red, lineWidth: 3)
                    )
                }
            }
            
            Text("Two 🐦 in the same 2×2 box!")
                .font(.caption)
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 12) {
                Text("🎯 **Ready to Play?**")
                    .font(.headline)
                    .foregroundColor(Color(red: 0.7, green: 0.35, blue: 0.3))
                
                Text("Remember: Each emoji appears exactly once in every row, column, and 2×2 box!")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(red: 0.7, green: 0.35, blue: 0.3).opacity(0.15))
                    .cornerRadius(12)
            }
            .padding(.top, 8)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var navigationButtons: some View {
        HStack(spacing: 20) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentStep = max(0, currentStep - 1)
                }
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Previous")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(currentStep > 0 ? Color(red: 0.7, green: 0.35, blue: 0.3) : Color.gray)
                .cornerRadius(25)
            }
            .disabled(currentStep == 0)
            
            // Step indicator
            HStack(spacing: 8) {
                ForEach(0..<totalSteps, id: \.self) { step in
                    Circle()
                        .fill(step == currentStep ? Color(red: 0.7, green: 0.35, blue: 0.3) : Color.gray.opacity(0.3))
                        .frame(width: 10, height: 10)
                        .scaleEffect(step == currentStep ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: currentStep)
                }
            }
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    if currentStep < totalSteps - 1 {
                        currentStep += 1
                    } else {
                        dismiss()
                    }
                }
            }) {
                HStack {
                    Text(currentStep < totalSteps - 1 ? "Next" : "Start Playing!")
                    if currentStep < totalSteps - 1 {
                        Image(systemName: "chevron.right")
                    } else {
                        Image(systemName: "play.fill")
                    }
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(currentStep < totalSteps - 1 ? Color(red: 0.7, green: 0.35, blue: 0.3) : Color(red: 0.4, green: 0.7, blue: 0.4))
                .cornerRadius(25)
            }
        }
        .padding(.top, 20)
    }
}

#Preview {
    TutorialView()
}