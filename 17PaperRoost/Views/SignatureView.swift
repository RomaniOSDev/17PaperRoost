import SwiftUI
import UIKit

struct SignatureView: View {
    @Binding var signatureData: Data?
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var signatureManager: SignatureManager
    @State private var lines: [Line] = []
    @State private var currentLine: Line?
    @FocusState private var isCanvasFocused: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor")
                    .ignoresSafeArea()
                    .onTapGesture {
                        // Скрываем клавиатуру при клике на фон
                        hideKeyboard()
                        isCanvasFocused = false
                    }
                
                VStack(spacing: 16) {
                    // Заголовок
                    VStack(spacing: 8) {
                        Text("Draw Your Signature")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("PrimaryTextColor"))
                            .scaleEffect(isCanvasFocused ? 1.05 : 1.0)
                            .animation(.easeInOut(duration: 0.3), value: isCanvasFocused)
                        
                        Text("Use your finger to draw your signature")
                            .font(.caption)
                            .foregroundColor(Color("SecondaryTextColor"))
                            .opacity(isCanvasFocused ? 0.8 : 1.0)
                            .animation(.easeInOut(duration: 0.3), value: isCanvasFocused)
                    }
                    .padding(.top, 10)
                    
                    // Канвас для подписи
                    signatureCanvas
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isCanvasFocused ? Color("AccentColor") : Color("SecondaryColor"), 
                                       lineWidth: isCanvasFocused ? 3 : 2)
                        )
                        .scaleEffect(isCanvasFocused ? 1.02 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: isCanvasFocused)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    isCanvasFocused = true
                                    let point = value.location
                                    if currentLine == nil {
                                        currentLine = Line(points: [point])
                                    } else {
                                        currentLine?.points.append(point)
                                    }
                                }
                                .onEnded { _ in
                                    if let line = currentLine {
                                        lines.append(line)
                                        currentLine = nil
                                    }
                                    // Не сбрасываем фокус сразу, чтобы пользователь видел эффект
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                        isCanvasFocused = false
                                    }
                                }
                        )
                        .onTapGesture {
                            isCanvasFocused = true
                        }

                    
                    Spacer(minLength: 20)
                    
                    // Кнопки управления
                    HStack(spacing: 16) {
                        Button("Clear") {
                            lines.removeAll()
                            currentLine = nil
                        }
                        .foregroundColor(.red)
                        .font(.title3)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color("CardColor"))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.red, lineWidth: 2)
                        )
                        .scaleEffect(1.0)
                        .animation(.easeInOut(duration: 0.1), value: true)
                        
                        Button("Save Signature") {
                            saveSignature()
                        }
                        .foregroundColor(.white)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color("AccentColor"))
                        .cornerRadius(16)
                        .disabled(lines.isEmpty)
                        .opacity(lines.isEmpty ? 0.6 : 1.0)
                        .scaleEffect(1.0)
                        .animation(.easeInOut(duration: 0.1), value: true)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                }
            }
            .navigationTitle("Signature")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color("AccentColor"))
                }
            })
        }
    }
    
    private func saveSignature() {
        // Создаем подпись высокого качества
        signatureData = signatureManager.createHighQualitySignature(from: lines)
        
        if signatureData != nil {
            print("✅ Signature saved successfully")
        } else {
            print("❌ Failed to save signature")
        }
        
        dismiss()
    }
    
    private func hideKeyboard() {
        // Надежный способ скрыть клавиатуру
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        // Дополнительно - скрываем все текстовые поля
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        window?.endEditing(true)
    }
    
    private var signatureCanvas: some View {
        ZStack {
            // Белый фон канваса
            Rectangle()
                .fill(.white)
                .cornerRadius(12)
            
            // Рисуем сохраненные линии
            ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                Path { path in
                    if let firstPoint = line.points.first {
                        path.move(to: firstPoint)
                        for point in line.points.dropFirst() {
                            path.addLine(to: point)
                        }
                    }
                }
                .stroke(.black, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
            }
            
            // Рисуем текущую линию
            if let currentLine = currentLine {
                Path { path in
                    if let firstPoint = currentLine.points.first {
                        path.move(to: firstPoint)
                        for point in currentLine.points.dropFirst() {
                            path.addLine(to: point)
                        }
                    }
                }
                .stroke(.black, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
            }
        }
        .frame(width: min(signatureManager.signatureCanvasSize.width, UIScreen.main.bounds.width - 40), 
               height: min(signatureManager.signatureCanvasSize.height, UIScreen.main.bounds.height * 0.4))
        .cornerRadius(12)
    }
}




