//
//  AliyunOCRService.swift
//  VisualCents
//
//  Aliyun OCR service for receipt text extraction
//

import Foundation
import CryptoKit
import UIKit

/// Aliyun OCR service for scanning receipts
@Observable
final class AliyunOCRService {
    
    // MARK: - Configuration
    
    /// OCR API endpoint
    private let endpoint = "https://ocrapi-advanced.taobao.com"
    private let apiPath = "/ocrservice/advanced"
    
    /// Your Aliyun AccessKey (store securely in production!)
    private var accessKeyId: String {
        // TODO: Store in Keychain or environment
        UserDefaults.standard.string(forKey: "aliyun_access_key_id") ?? ""
    }
    
    private var accessKeySecret: String {
        // TODO: Store in Keychain or environment
        UserDefaults.standard.string(forKey: "aliyun_access_key_secret") ?? ""
    }
    
    // MARK: - State
    
    var isProcessing = false
    var lastError: String?
    
    // MARK: - Types
    
    struct OCRResult {
        let merchantName: String?
        let amount: Decimal?
        let date: Date?
        let rawText: String
    }
    
    struct OCRResponse: Codable {
        let success: Bool?
        let content: String?
        let prism_wordsInfo: [WordInfo]?
        
        struct WordInfo: Codable {
            let word: String?
        }
    }
    
    // MARK: - Public Methods
    
    /// Analyze image using Aliyun OCR
    func analyzeImage(_ image: UIImage) async throws -> OCRResult {
        guard !accessKeyId.isEmpty, !accessKeySecret.isEmpty else {
            throw OCRError.missingCredentials
        }
        
        isProcessing = true
        lastError = nil
        
        defer { isProcessing = false }
        
        // Convert image to base64
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw OCRError.invalidImage
        }
        let base64Image = imageData.base64EncodedString()
        
        // Build request
        let request = try buildRequest(imageBase64: base64Image)
        
        // Execute request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OCRError.networkError("Invalid response")
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw OCRError.apiError(httpResponse.statusCode, errorMessage)
        }
        
        // Parse response
        return try parseResponse(data)
    }
    
    /// Configure API credentials
    func configure(accessKeyId: String, accessKeySecret: String) {
        UserDefaults.standard.set(accessKeyId, forKey: "aliyun_access_key_id")
        UserDefaults.standard.set(accessKeySecret, forKey: "aliyun_access_key_secret")
    }
    
    /// Check if credentials are configured
    var isConfigured: Bool {
        !accessKeyId.isEmpty && !accessKeySecret.isEmpty
    }
    
    // MARK: - Private Methods
    
    private func buildRequest(imageBase64: String) throws -> URLRequest {
        guard let url = URL(string: endpoint + apiPath) else {
            throw OCRError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Headers
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let nonce = UUID().uuidString
        
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(timestamp, forHTTPHeaderField: "X-Ca-Timestamp")
        request.setValue(nonce, forHTTPHeaderField: "X-Ca-Nonce")
        request.setValue(accessKeyId, forHTTPHeaderField: "X-Ca-Key")
        
        // Body
        let body: [String: Any] = [
            "img": imageBase64,
            "prob": false,
            "charInfo": false
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        // Sign request
        let signature = try signRequest(request)
        request.setValue(signature, forHTTPHeaderField: "X-Ca-Signature")
        
        return request
    }
    
    private func signRequest(_ request: URLRequest) throws -> String {
        // Build string to sign
        var stringToSign = request.httpMethod ?? "POST"
        stringToSign += "\n"
        stringToSign += request.value(forHTTPHeaderField: "Accept") ?? ""
        stringToSign += "\n"
        stringToSign += request.value(forHTTPHeaderField: "Content-Type") ?? ""
        stringToSign += "\n"
        stringToSign += request.value(forHTTPHeaderField: "X-Ca-Timestamp") ?? ""
        stringToSign += "\n"
        stringToSign += "x-ca-key:" + (request.value(forHTTPHeaderField: "X-Ca-Key") ?? "")
        stringToSign += "\n"
        stringToSign += "x-ca-nonce:" + (request.value(forHTTPHeaderField: "X-Ca-Nonce") ?? "")
        stringToSign += "\n"
        stringToSign += request.url?.path ?? ""
        
        // HMAC-SHA256 signature
        let key = SymmetricKey(data: Data(accessKeySecret.utf8))
        let signature = HMAC<SHA256>.authenticationCode(
            for: Data(stringToSign.utf8),
            using: key
        )
        
        return Data(signature).base64EncodedString()
    }
    
    private func parseResponse(_ data: Data) throws -> OCRResult {
        let decoder = JSONDecoder()
        
        // Try to decode response
        guard let response = try? decoder.decode(OCRResponse.self, from: data) else {
            // Fallback: try to extract raw text
            if let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let content = jsonObject["content"] as? String {
                return parseRawText(content)
            }
            throw OCRError.parseError
        }
        
        // Extract text from word info or content
        var rawText = ""
        if let words = response.prism_wordsInfo {
            rawText = words.compactMap { $0.word }.joined(separator: " ")
        } else if let content = response.content {
            rawText = content
        }
        
        return parseRawText(rawText)
    }
    
    private func parseRawText(_ text: String) -> OCRResult {
        // Extract merchant name (first line often contains it)
        let lines = text.components(separatedBy: .newlines).filter { !$0.isEmpty }
        let merchantName = lines.first
        
        // Extract amount (look for patterns like ¥123.45 or 金额:123.45)
        var amount: Decimal?
        let amountPatterns = [
            "¥([0-9]+\\.?[0-9]*)",
            "￥([0-9]+\\.?[0-9]*)",
            "金额[：:]?\\s*([0-9]+\\.?[0-9]*)",
            "合计[：:]?\\s*([0-9]+\\.?[0-9]*)",
            "总计[：:]?\\s*([0-9]+\\.?[0-9]*)",
            "实付[：:]?\\s*([0-9]+\\.?[0-9]*)"
        ]
        
        for pattern in amountPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
               let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
               let range = Range(match.range(at: 1), in: text) {
                let amountStr = String(text[range])
                amount = Decimal(string: amountStr)
                break
            }
        }
        
        // Extract date (look for patterns like 2024-01-15 or 2024/01/15)
        var date: Date?
        let datePatterns = [
            "([0-9]{4}[-/][0-9]{1,2}[-/][0-9]{1,2})",
            "([0-9]{1,2}月[0-9]{1,2}日)"
        ]
        
        for pattern in datePatterns {
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
               let range = Range(match.range(at: 1), in: text) {
                let dateStr = String(text[range])
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "zh_CN")
                
                for format in ["yyyy-MM-dd", "yyyy/MM/dd", "MM月dd日"] {
                    formatter.dateFormat = format
                    if let parsedDate = formatter.date(from: dateStr) {
                        date = parsedDate
                        break
                    }
                }
                if date != nil { break }
            }
        }
        
        return OCRResult(
            merchantName: merchantName,
            amount: amount,
            date: date,
            rawText: text
        )
    }
}

// MARK: - Errors

enum OCRError: LocalizedError {
    case missingCredentials
    case invalidImage
    case invalidURL
    case networkError(String)
    case apiError(Int, String)
    case parseError
    
    var errorDescription: String? {
        switch self {
        case .missingCredentials:
            return "请先配置阿里云 API 凭证"
        case .invalidImage:
            return "无法处理图片"
        case .invalidURL:
            return "无效的 API 地址"
        case .networkError(let message):
            return "网络错误: \(message)"
        case .apiError(let code, let message):
            return "API 错误 (\(code)): \(message)"
        case .parseError:
            return "无法解析响应"
        }
    }
}
