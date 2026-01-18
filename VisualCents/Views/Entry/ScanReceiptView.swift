//
//  ScanReceiptView.swift
//  VisualCents
//
//  Camera view for scanning receipts with OCR
//

import SwiftUI
import SwiftData
import PhotosUI

/// Receipt scanning view with camera and photo picker
struct ScanReceiptView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.appTheme) private var theme
    @Environment(\.modelContext) private var modelContext
    
    @State private var ocrService = AliyunOCRService()
    @State private var selectedImage: UIImage?
    @State private var showPhotoPicker = false
    @State private var showCamera = false
    @State private var ocrResult: AliyunOCRService.OCRResult?
    @State private var showError = false
    @State private var errorMessage = ""
    
    // Editable fields from OCR
    @State private var merchantName = ""
    @State private var amountString = ""
    @State private var selectedDate = Date()
    @State private var notes = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if let image = selectedImage {
                    // Show scanned image and results
                    resultsView(image: image)
                } else {
                    // Show capture options
                    captureOptionsView
                }
            }
            .background(theme.background)
            .navigationTitle("扫描小票")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        theme.lightHaptic()
                        dismiss()
                    }
                    .foregroundStyle(theme.textSecondary)
                }
            }
            .photosPicker(
                isPresented: $showPhotoPicker,
                selection: Binding(
                    get: { nil },
                    set: { item in
                        if let item = item {
                            loadImage(from: item)
                        }
                    }
                ),
                matching: .images
            )
            .alert("错误", isPresented: $showError) {
                Button("确定") {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Capture Options
    
    private var captureOptionsView: some View {
        VStack(spacing: theme.paddingLarge) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(theme.primaryAccent.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "doc.text.viewfinder")
                    .font(.system(size: 48))
                    .foregroundStyle(theme.primaryAccent)
            }
            
            Text("扫描小票或截图")
                .font(theme.customFont(size: 20, weight: .semibold))
                .foregroundStyle(theme.textPrimary)
            
            Text("支持微信/支付宝账单截图")
                .font(theme.customFont(size: 14, weight: .regular))
                .foregroundStyle(theme.textSecondary)
            
            Spacer()
            
            // Action buttons
            VStack(spacing: 12) {
                // Photo Library
                Button {
                    theme.mediumHaptic()
                    showPhotoPicker = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 18))
                        Text("从相册选择")
                            .font(theme.customFont(size: 16, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(theme.primaryAccent)
                    .clipShape(RoundedRectangle(cornerRadius: theme.buttonCornerRadius))
                }
                
                // Camera (if available)
                Button {
                    theme.mediumHaptic()
                    showCamera = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "camera")
                            .font(.system(size: 18))
                        Text("拍照")
                            .font(theme.customFont(size: 16, weight: .semibold))
                    }
                    .foregroundStyle(theme.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(theme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: theme.buttonCornerRadius))
                }
            }
            .padding(.horizontal, theme.paddingLarge)
            .padding(.bottom, theme.paddingLarge)
        }
    }
    
    // MARK: - Results View
    
    private func resultsView(image: UIImage) -> some View {
        ScrollView {
            VStack(spacing: theme.padding) {
                // Image preview
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 200)
                    .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: theme.cornerRadius)
                            .stroke(theme.cardBackgroundElevated, lineWidth: 1)
                    )
                
                // Processing indicator with Shimmer effect
                if ocrService.isProcessing {
                    VStack(spacing: 16) {
                        Text("正在识别小票...")
                            .font(theme.customFont(size: 14, weight: .medium))
                            .foregroundStyle(theme.textSecondary)

                        // Shimmer 骨架屏
                        VStack(spacing: 12) {
                            ShimmerLoadingView(width: .infinity, height: 20)
                            ShimmerLoadingView(width: .infinity, height: 16)
                            ShimmerLoadingView(width: 120, height: 16)
                            ShimmerLoadingView(width: .infinity, height: 40, cornerRadius: 12)
                        }
                        .padding()
                    }
                    .padding()
                } else if ocrResult != nil {
                    // Editable fields
                    editableFields
                    
                    // Save button
                    Button {
                        saveTransaction()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                            Text("保存交易")
                        }
                        .font(theme.customFont(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(theme.incomeGreen)
                        .clipShape(RoundedRectangle(cornerRadius: theme.buttonCornerRadius))
                    }
                    .padding(.top, theme.padding)
                }
                
                // Retry button
                Button {
                    selectedImage = nil
                    ocrResult = nil
                } label: {
                    Text("重新选择")
                        .font(theme.customFont(size: 14, weight: .medium))
                        .foregroundStyle(theme.textSecondary)
                }
                .padding(.top, 8)
            }
            .padding(theme.padding)
        }
    }
    
    // MARK: - Editable Fields
    
    private var editableFields: some View {
        VStack(spacing: 16) {
            // Merchant
            VStack(alignment: .leading, spacing: 6) {
                Text("商家")
                    .font(theme.customFont(size: 12, weight: .medium))
                    .foregroundStyle(theme.textTertiary)
                
                TextField("商家名称", text: $merchantName)
                    .font(theme.customFont(size: 16, weight: .regular))
                    .foregroundStyle(theme.textPrimary)
                    .padding()
                    .background(theme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius))
            }
            
            // Amount
            VStack(alignment: .leading, spacing: 6) {
                Text("金额")
                    .font(theme.customFont(size: 12, weight: .medium))
                    .foregroundStyle(theme.textTertiary)
                
                HStack {
                    Text("¥")
                        .font(theme.amountFont(size: 20))
                        .foregroundStyle(theme.expenseRed)
                    
                    TextField("0.00", text: $amountString)
                        .font(theme.amountFont(size: 24))
                        .foregroundStyle(theme.textPrimary)
                        .keyboardType(.decimalPad)
                }
                .padding()
                .background(theme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius))
            }
            
            // Date
            VStack(alignment: .leading, spacing: 6) {
                Text("日期")
                    .font(theme.customFont(size: 12, weight: .medium))
                    .foregroundStyle(theme.textTertiary)
                
                DatePicker("", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .tint(theme.primaryAccent)
                    .padding()
                    .background(theme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius))
            }
        }
    }
    
    // MARK: - Actions
    
    private func loadImage(from item: PhotosPickerItem) {
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                await MainActor.run {
                    selectedImage = image
                    processImage(image)
                }
            }
        }
    }
    
    private func processImage(_ image: UIImage) {
        Task {
            do {
                let result = try await ocrService.analyzeImage(image)
                await MainActor.run {
                    ocrResult = result
                    merchantName = result.merchantName ?? ""
                    if let amount = result.amount {
                        amountString = "\(amount)"
                    }
                    if let date = result.date {
                        selectedDate = date
                    }
                    theme.successHaptic()
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                    theme.errorHaptic()
                }
            }
        }
    }
    
    private func saveTransaction() {
        guard let amount = Decimal(string: amountString), amount > 0 else {
            errorMessage = "请输入有效金额"
            showError = true
            return
        }

        let transaction = Transaction(
            amount: amount,
            merchantName: merchantName.isEmpty ? "OCR扫描" : merchantName,
            date: selectedDate,
            notes: notes.isEmpty ? nil : notes,
            isExpense: true,
            source: .ocr,
            category: nil
        )

        modelContext.insert(transaction)

        // 🎉 添加庆祝特效
        MicroInteractionService.shared.celebrateTransactionSaved()

        theme.successHaptic()
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    ScanReceiptView()
        .environment(\.appTheme, SoftPopTheme())
        .modelContainer(for: [Transaction.self, Category.self], inMemory: true)
}
