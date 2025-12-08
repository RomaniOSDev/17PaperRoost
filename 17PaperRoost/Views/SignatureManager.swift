import SwiftUI
import UIKit
import Combine

class SignatureManager: ObservableObject {
    static let shared = SignatureManager()
    
    // Стандартные размеры для подписей
    let signatureCanvasSize = CGSize(width: 1000, height: 600)
    let signaturePreviewSize = CGSize(width: 800, height: 500)
    let signatureThumbnailSize = CGSize(width: 200, height: 120)
    
    private init() {}
    
    // Создание подписи из линий
    func createSignatureImage(from lines: [Line], size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // Белый фон
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // Рисуем линии подписи
            UIColor.black.setStroke()
            context.cgContext.setLineWidth(4)
            context.cgContext.setLineCap(.round)
            context.cgContext.setLineJoin(.round)
            
            for line in lines {
                guard let firstPoint = line.points.first else { continue }
                
                // Масштабируем точки под размер канваса
                let scaledPoints = line.points.map { point in
                    CGPoint(
                        x: point.x * size.width / 1000,
                        y: point.y * size.height / 600
                    )
                }
                
                context.cgContext.move(to: scaledPoints[0])
                for point in scaledPoints.dropFirst() {
                    context.cgContext.addLine(to: point)
                }
            }
            
            context.cgContext.strokePath()
        }
    }
    
    // Создание подписи для сохранения (высокое качество)
    func createHighQualitySignature(from lines: [Line]) -> Data? {
        guard let image = createSignatureImage(from: lines, size: signatureCanvasSize) else { return nil }
        return image.pngData()
    }
    
    // Создание подписи для предпросмотра
    func createPreviewSignature(from lines: [Line]) -> Data? {
        guard let image = createSignatureImage(from: lines, size: signaturePreviewSize) else { return nil }
        return image.pngData()
    }
    
    // Создание миниатюры подписи
    func createThumbnailSignature(from lines: [Line]) -> Data? {
        guard let image = createSignatureImage(from: lines, size: signatureThumbnailSize) else { return nil }
        return image.pngData()
    }
    
    // Получение подписи для отображения с нужным размером
    func getSignatureImage(for signatureData: Data?, targetSize: CGSize) -> UIImage? {
        guard let signatureData = signatureData,
              let originalImage = UIImage(data: signatureData) else { return nil }
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        
        return renderer.image { context in
            // Белый фон
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: targetSize))
            
            // Рисуем подпись по центру
            let imageRect = self.makeRect(aspectRatio: originalImage.size, insideRect: CGRect(origin: .zero, size: targetSize))
            originalImage.draw(in: imageRect)
        }
    }
    
    // Вспомогательная функция для создания прямоугольника с сохранением пропорций
    private func makeRect(aspectRatio: CGSize, insideRect: CGRect) -> CGRect {
        let widthRatio = insideRect.width / aspectRatio.width
        let heightRatio = insideRect.height / aspectRatio.height
        let scale = min(widthRatio, heightRatio)
        
        let newWidth = aspectRatio.width * scale
        let newHeight = aspectRatio.height * scale
        let newX = insideRect.midX - newWidth / 2
        let newY = insideRect.midY - newHeight / 2
        
        return CGRect(x: newX, y: newY, width: newWidth, height: newHeight)
    }
}

// Модель линии для подписи
struct Line: Codable {
    var points: [CGPoint]
    
    init(points: [CGPoint]) {
        self.points = points
    }
}

// Расширение для CGPoint чтобы сделать его Codable

