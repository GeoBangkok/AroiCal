import SwiftUI

struct ManualFoodEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(LanguageManager.self) private var lang
    let onSave: (FoodEntry) -> Void

    @State private var foodName: String = ""
    @State private var calories: String = ""
    @State private var protein: String = ""
    @State private var carbs: String = ""
    @State private var fat: String = ""
    @State private var servingSize: String = "1 serving"
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    @FocusState private var focusedField: Field?

    enum Field {
        case name, calories, protein, carbs, fat, serving
    }

    private var isValid: Bool {
        !foodName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !calories.isEmpty &&
        Int(calories) != nil
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection

                    VStack(spacing: 16) {
                        // Food Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text(lang.t("Food Name", thai: "ชื่ออาหาร", japanese: "食品名"))
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.secondary)

                            TextField(lang.t("e.g., Grilled Chicken", thai: "เช่น ไก่ย่าง", japanese: "例: グリルチキン"), text: $foodName)
                                .textFieldStyle(CustomTextFieldStyle())
                                .focused($focusedField, equals: .name)
                        }

                        // Calories (Required)
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(lang.t("Calories", thai: "แคลอรี่", japanese: "カロリー"))
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.secondary)

                                Text("*")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.red)
                            }

                            TextField(lang.t("e.g., 300", thai: "เช่น 300", japanese: "例: 300"), text: $calories)
                                .keyboardType(.numberPad)
                                .textFieldStyle(CustomTextFieldStyle())
                                .focused($focusedField, equals: .calories)
                        }

                        Divider()
                            .padding(.vertical, 4)

                        Text(lang.t("Macros (Optional)", thai: "สารอาหาร (ไม่บังคับ)", japanese: "マクロ（任意）"))
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        // Protein
                        VStack(alignment: .leading, spacing: 8) {
                            Text(lang.t("Protein (g)", thai: "โปรตีน (g)", japanese: "タンパク質 (g)"))
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.secondary)

                            TextField(lang.t("e.g., 25", thai: "เช่น 25", japanese: "例: 25"), text: $protein)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(CustomTextFieldStyle())
                                .focused($focusedField, equals: .protein)
                        }

                        // Carbs
                        VStack(alignment: .leading, spacing: 8) {
                            Text(lang.t("Carbs (g)", thai: "คาร์โบไฮเดรต (g)", japanese: "炭水化物 (g)"))
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.secondary)

                            TextField(lang.t("e.g., 10", thai: "เช่น 10", japanese: "例: 10"), text: $carbs)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(CustomTextFieldStyle())
                                .focused($focusedField, equals: .carbs)
                        }

                        // Fat
                        VStack(alignment: .leading, spacing: 8) {
                            Text(lang.t("Fat (g)", thai: "ไขมัน (g)", japanese: "脂質 (g)"))
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.secondary)

                            TextField(lang.t("e.g., 15", thai: "เช่น 15", japanese: "例: 15"), text: $fat)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(CustomTextFieldStyle())
                                .focused($focusedField, equals: .fat)
                        }

                        Divider()
                            .padding(.vertical, 4)

                        // Serving Size
                        VStack(alignment: .leading, spacing: 8) {
                            Text(lang.t("Serving Size", thai: "ขนาดหนึ่งหน่วยบริโภค", japanese: "サービングサイズ"))
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.secondary)

                            TextField(lang.t("e.g., 1 plate", thai: "เช่น 1 จาน", japanese: "例: 1皿"), text: $servingSize)
                                .textFieldStyle(CustomTextFieldStyle())
                                .focused($focusedField, equals: .serving)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 100)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(lang.t("Cancel", thai: "ยกเลิก", japanese: "キャンセル")) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button(lang.t("Save", thai: "บันทึก", japanese: "保存")) {
                        saveEntry()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isValid)
                }
            }
            .safeAreaInset(edge: .bottom) {
                if focusedField != nil {
                    HStack {
                        Spacer()
                        Button {
                            focusedField = nil
                        } label: {
                            Text(lang.t("Done", thai: "เสร็จ", japanese: "完了"))
                                .fontWeight(.semibold)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(Color(red: 1, green: 0.42, blue: 0.21))
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                }
            }
            .alert(lang.t("Error", thai: "ข้อผิดพลาด", japanese: "エラー"), isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 1, green: 0.42, blue: 0.21), Color(red: 1, green: 0.72, blue: 0)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 64, height: 64)

                Image(systemName: "pencil")
                    .font(.title2)
                    .foregroundStyle(.white)
            }

            Text(lang.t("Manual Food Entry", thai: "บันทึกอาหารด้วยตนเอง", japanese: "手動食事入力"))
                .font(.title2.weight(.bold))

            Text(lang.t("Enter food details manually", thai: "ป้อนรายละเอียดอาหารด้วยตนเอง", japanese: "食品の詳細を手動で入力"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 20)
        .padding(.bottom, 8)
    }

    private func saveEntry() {
        guard let caloriesInt = Int(calories) else {
            errorMessage = lang.t("Invalid calories value", thai: "ค่าแคลอรี่ไม่ถูกต้อง", japanese: "カロリー値が無効です")
            showError = true
            return
        }

        let proteinValue = Double(protein) ?? 0.0
        let carbsValue = Double(carbs) ?? 0.0
        let fatValue = Double(fat) ?? 0.0

        let entry = FoodEntry(
            name: foodName.trimmingCharacters(in: .whitespaces),
            calories: caloriesInt,
            protein: proteinValue,
            carbs: carbsValue,
            fat: fatValue,
            servingSize: servingSize.trimmingCharacters(in: .whitespaces).isEmpty ? "1 serving" : servingSize,
            imageData: nil,
            date: Date()
        )

        onSave(entry)
        dismiss()
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(14)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color(.separator).opacity(0.5), lineWidth: 0.5)
            )
    }
}

#Preview {
    ManualFoodEntryView { entry in
        print("Saved: \(entry.name)")
    }
    .environment(LanguageManager())
}
