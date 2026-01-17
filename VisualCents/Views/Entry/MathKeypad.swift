//
//  MathKeypad.swift
//  VisualCents
//
//  Custom numeric keypad with math expression support (+, -)
//

import SwiftUI

/// Math-capable keypad for amount entry
struct MathKeypad: View {
    @Environment(\.appTheme) private var theme
    
    @Binding var expression: String
    var onDone: (Decimal) -> Void
    
    private let buttons: [[KeypadKey]] = [
        [.digit("7"), .digit("8"), .digit("9"), .backspace],
        [.digit("4"), .digit("5"), .digit("6"), .plus],
        [.digit("1"), .digit("2"), .digit("3"), .minus],
        [.date, .digit("0"), .decimal, .done]
    ]
    
    var body: some View {
        VStack(spacing: 10) {
            ForEach(0..<buttons.count, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(buttons[row], id: \.self) { key in
                        MathKeypadButton(key: key) {
                            handleKey(key)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, theme.padding)
    }
    
    // MARK: - Key Handling
    
    private func handleKey(_ key: KeypadKey) {
        switch key {
        case .digit(let d):
            appendDigit(d)
            theme.lightHaptic()
            
        case .decimal:
            appendDecimal()
            theme.lightHaptic()
            
        case .plus:
            appendOperator("+")
            theme.mediumHaptic()
            
        case .minus:
            appendOperator("-")
            theme.mediumHaptic()
            
        case .backspace:
            if !expression.isEmpty {
                expression.removeLast()
            }
            theme.lightHaptic()
            
        case .date:
            // TODO: Show date picker
            theme.lightHaptic()
            
        case .done:
            let result = evaluateExpression()
            theme.successHaptic()
            onDone(result)
        }
    }
    
    private func appendDigit(_ digit: String) {
        // Prevent leading zeros
        if expression == "0" {
            expression = digit
        } else if expression.count < 15 {
            expression += digit
        }
    }
    
    private func appendDecimal() {
        // Find the last number segment
        let lastSegment = getLastNumberSegment()
        if !lastSegment.contains(".") {
            if expression.isEmpty || expression.last == "+" || expression.last == "-" {
                expression += "0."
            } else {
                expression += "."
            }
        }
    }
    
    private func appendOperator(_ op: String) {
        // Don't start with operator (except minus for negative)
        if expression.isEmpty {
            if op == "-" {
                expression = "-"
            }
            return
        }
        
        // Replace last operator if exists
        if let last = expression.last, last == "+" || last == "-" {
            expression.removeLast()
        }
        
        expression += op
    }
    
    private func getLastNumberSegment() -> String {
        let operators = CharacterSet(charactersIn: "+-")
        let segments = expression.components(separatedBy: operators)
        return segments.last ?? ""
    }
    
    // MARK: - Expression Evaluation
    
    private func evaluateExpression() -> Decimal {
        // Clean expression
        var expr = expression
        
        // Remove trailing operator
        while let last = expr.last, last == "+" || last == "-" || last == "." {
            expr.removeLast()
        }
        
        if expr.isEmpty { return 0 }
        
        // Parse and evaluate
        // Simple tokenizer for + and -
        var result: Decimal = 0
        var currentNumber = ""
        var currentOp: Character = "+"
        
        for (index, char) in expr.enumerated() {
            if char == "+" || char == "-" {
                // Check if this is a negative sign at start or after operator
                if index == 0 || (index > 0 && (expr[expr.index(expr.startIndex, offsetBy: index - 1)] == "+" || expr[expr.index(expr.startIndex, offsetBy: index - 1)] == "-")) {
                    currentNumber.append(char)
                } else {
                    // Evaluate previous number
                    if let num = Decimal(string: currentNumber) {
                        if currentOp == "+" {
                            result += num
                        } else {
                            result -= num
                        }
                    }
                    currentNumber = ""
                    currentOp = char
                }
            } else {
                currentNumber.append(char)
            }
        }
        
        // Evaluate last number
        if let num = Decimal(string: currentNumber) {
            if currentOp == "+" {
                result += num
            } else {
                result -= num
            }
        }
        
        return result
    }
}

// MARK: - Keypad Key

enum KeypadKey: Hashable {
    case digit(String)
    case decimal
    case plus
    case minus
    case backspace
    case date
    case done
    
    var displayLabel: String {
        switch self {
        case .digit(let d): return d
        case .decimal: return "."
        case .plus: return "+"
        case .minus: return "-"
        case .backspace: return "⌫"
        case .date: return "📅"
        case .done: return "✓"
        }
    }
    
    var isOperator: Bool {
        switch self {
        case .plus, .minus: return true
        default: return false
        }
    }
    
    var isDone: Bool {
        if case .done = self { return true }
        return false
    }
}

// MARK: - Keypad Button

struct MathKeypadButton: View {
    @Environment(\.appTheme) private var theme
    
    let key: KeypadKey
    let action: () -> Void
    
    @State private var isPressed = false
    
    private var backgroundColor: Color {
        switch key {
        case .done:
            return theme.incomeGreen
        case .plus, .minus:
            return theme.primaryAccent.opacity(0.3)
        case .backspace:
            return theme.expenseRed.opacity(0.2)
        default:
            return theme.cardBackground
        }
    }
    
    private var foregroundColor: Color {
        switch key {
        case .done:
            return .white
        case .plus, .minus:
            return theme.primaryAccent
        case .backspace:
            return theme.expenseRed
        default:
            return theme.textPrimary
        }
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: theme.cornerRadius)
                    .fill(backgroundColor)
                
                Group {
                    if case .backspace = key {
                        Image(systemName: "delete.left.fill")
                            .font(.system(size: 20, weight: .medium))
                    } else if case .done = key {
                        Image(systemName: "checkmark")
                            .font(.system(size: 22, weight: .bold))
                    } else if case .date = key {
                        Image(systemName: "calendar")
                            .font(.system(size: 18, weight: .medium))
                    } else {
                        Text(key.displayLabel)
                            .font(theme.amountFont(size: key.isOperator ? 28 : 24))
                    }
                }
                .foregroundStyle(foregroundColor)
            }
            .frame(height: 56)
            .scaleEffect(isPressed ? 0.93 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Preview

#Preview {
    VStack {
        Text("¥ 25+12.5")
            .font(.system(size: 40, weight: .bold, design: .rounded))
            .padding()
        
        MathKeypad(expression: .constant("25+12.5")) { result in
            print("Result: \(result)")
        }
    }
    .padding()
    .background(Color(red: 0.08, green: 0.08, blue: 0.12))
    .environment(\.appTheme, SoftPopTheme())
}
