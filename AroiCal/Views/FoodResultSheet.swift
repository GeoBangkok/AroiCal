import SwiftUI

struct FoodResultSheet: View {
    @Environment(LanguageManager.self) private var lang
    let entry: FoodEntry
    let onAdd: () -> Void

    private var displayName: String {
        switch lang.current {
        case .thai:
            return entry.nameThai.isEmpty ? entry.name : entry.nameThai
        case .japanese:
            return entry.nameJapanese.isEmpty ? entry.name : entry.nameJapanese
        case .english:
            return entry.name
        }
    }

    private var secondaryName: String? {
        switch lang.current {
        case .thai:
            return entry.nameThai.isEmpty ? nil : entry.name
        case .japanese:
            return entry.nameJapanese.isEmpty ? nil : entry.name
        case .english:
            if !entry.nameThai.isEmpty { return entry.nameThai }
            if !entry.nameJapanese.isEmpty { return entry.nameJapanese }
            return nil
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if let data = entry.imageData, let uiImage = UIImage(data: data) {
                        Color(.secondarySystemBackground)
                            .frame(height: 200)
                            .overlay {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .allowsHitTesting(false)
                            }
                            .clipShape(.rect(cornerRadius: 16))
                    }

                    VStack(spacing: 6) {
                        Text(displayName)
                            .font(.title2.bold())

                        if let secondary = secondaryName {
                            Text(secondary)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Text(entry.servingSize)
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }

                    VStack(spacing: 4) {
                        Text("\(entry.calories)")
                            .font(.system(size: 52, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(red: 1, green: 0.42, blue: 0.21), Color(red: 1, green: 0.72, blue: 0)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )

                        Text(lang.t("calories", thai: "แคลอรี", japanese: "カロリー"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    HStack(spacing: 12) {
                        MacroResultCard(
                            name: lang.t("Protein", thai: "โปรตีน", japanese: "タンパク質"),
                            grams: entry.protein,
                            color: Color(red: 0.35, green: 0.67, blue: 1)
                        )
                        MacroResultCard(
                            name: lang.t("Carbs", thai: "คาร์บ", japanese: "炭水化物"),
                            grams: entry.carbs,
                            color: Color(red: 1, green: 0.42, blue: 0.21)
                        )
                        MacroResultCard(
                            name: lang.t("Fat", thai: "ไขมัน", japanese: "脂質"),
                            grams: entry.fat,
                            color: Color(red: 1, green: 0.72, blue: 0)
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    AroiCalHeader()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                Button {
                    onAdd()
                } label: {
                    Text(lang.t("Add to Today", thai: "เพิ่มในวันนี้", japanese: "今日に追加"))
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 1, green: 0.42, blue: 0.21), Color(red: 1, green: 0.72, blue: 0)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            in: .rect(cornerRadius: 16)
                        )
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                .background(.bar)
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}

struct MacroResultCard: View {
    let name: String
    let grams: Double
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(color.opacity(0.15))
                .frame(width: 44, height: 44)
                .overlay {
                    Text(String(format: "%.0f", grams))
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                        .foregroundStyle(color)
                }

            Text("g")
                .font(.caption2)
                .foregroundStyle(.secondary)

            Text(name)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
    }
}
