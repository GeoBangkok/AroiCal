import SwiftUI

struct FoodResultSheet: View {
    @Environment(LanguageManager.self) private var lang
    @Environment(\.dismiss) private var dismiss
    let entry: FoodEntry
    let onAdd: () -> Void

    @State private var servings: Int = 1

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

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // Background image - takes exactly 40% of screen height
                if let data = entry.imageData, let uiImage = UIImage(data: data) {
                    VStack(spacing: 0) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: geometry.size.width, height: geometry.size.height * 0.4)
                            .clipped()
                            .overlay {
                                // Dark gradient overlay
                                LinearGradient(
                                    colors: [
                                        Color.black.opacity(0.3),
                                        Color.black.opacity(0.1),
                                        Color.clear
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            }

                        Spacer()
                    }
                }

                VStack(spacing: 0) {
                    // Top navigation bar
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(.white)
                                .frame(width: 44, height: 44)
                        }

                        Spacer()

                        Text(lang.t("Location", thai: "โลเคชัน", japanese: "ロケーション"))
                            .font(.headline)
                            .foregroundStyle(.white)

                        Spacer()

                        Button {
                            // More options
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(.white)
                                .frame(width: 44, height: 44)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)

                    Spacer()
                        .frame(height: geometry.size.height * 0.3)

                    // White card section
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            // Bookmark and time
                            HStack {
                                Image(systemName: "bookmark")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)

                                Text(currentTime)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)

                                Spacer()
                            }

                            // Food name and serving counter
                            HStack(alignment: .center) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(displayName)
                                        .font(.title2.weight(.bold))
                                        .lineLimit(2)

                                    HStack(spacing: 4) {
                                        Circle()
                                            .fill(.secondary)
                                            .frame(width: 4, height: 4)

                                        Text(entry.servingSize)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                }

                                Spacer()

                                // Serving counter
                                HStack(spacing: 12) {
                                    Button {
                                        if servings > 1 {
                                            withAnimation(.spring(duration: 0.3)) {
                                                servings -= 1
                                            }
                                        }
                                    } label: {
                                        Image(systemName: "minus")
                                            .font(.body.weight(.bold))
                                            .foregroundStyle(.primary)
                                            .frame(width: 32, height: 32)
                                    }

                                    Text("\(servings)")
                                        .font(.body.weight(.semibold))
                                        .frame(width: 24)

                                    Button {
                                        withAnimation(.spring(duration: 0.3)) {
                                            servings += 1
                                        }
                                    } label: {
                                        Image(systemName: "plus")
                                            .font(.body.weight(.bold))
                                            .foregroundStyle(.primary)
                                            .frame(width: 32, height: 32)
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color(.systemGray6))
                                .clipShape(Capsule())
                            }

                            // Calories card
                            HStack(spacing: 12) {
                                Image(systemName: "flame.fill")
                                    .font(.title)
                                    .foregroundStyle(Color(red: 1, green: 0.42, blue: 0.21))

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(lang.t("Calories", thai: "แคลอรี", japanese: "カロリー"))
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(.secondary)

                                    Text("\(entry.calories * servings)")
                                        .font(.system(size: 36, weight: .bold, design: .rounded))
                                        .foregroundStyle(.primary)
                                }

                                Spacer()
                            }
                            .padding(16)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16))

                            // Macros grid
                            HStack(spacing: 12) {
                                ModernMacroCard(
                                    icon: "🍖",
                                    name: lang.t("Protein", thai: "โปรตีน", japanese: "タンパク質"),
                                    grams: Int(entry.protein * Double(servings)),
                                    color: Color(red: 0.35, green: 0.67, blue: 1)
                                )
                                ModernMacroCard(
                                    icon: "🌾",
                                    name: lang.t("Carbs", thai: "คาร์บ", japanese: "炭水化物"),
                                    grams: Int(entry.carbs * Double(servings)),
                                    color: Color(red: 1, green: 0.42, blue: 0.21)
                                )
                                ModernMacroCard(
                                    icon: "🥑",
                                    name: lang.t("Fat", thai: "ไขมัน", japanese: "脂質"),
                                    grams: Int(entry.fat * Double(servings)),
                                    color: Color(red: 1, green: 0.72, blue: 0)
                                )
                            }

                            // Paging dots
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(.primary)
                                    .frame(width: 7, height: 7)
                                Circle()
                                    .fill(.secondary.opacity(0.3))
                                    .frame(width: 7, height: 7)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)

                            // Ingredients section
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text(lang.t("Ingredients", thai: "วัตถุดิบ", japanese: "材料"))
                                        .font(.headline)

                                    Spacer()

                                    Button {
                                        // Add ingredient
                                    } label: {
                                        Text("+ \(lang.t("Add", thai: "เพิ่ม", japanese: "追加"))")
                                            .font(.subheadline.weight(.medium))
                                            .foregroundStyle(Color(red: 1, green: 0.42, blue: 0.21))
                                    }
                                }

                                Text("Lettuce • 20 cal • 1.5 serving")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            // Action buttons
                            HStack(spacing: 12) {
                                Button {
                                    // Add ingredient
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: "plus")
                                            .font(.body.weight(.semibold))
                                        Text(lang.t("Add Data", thai: "แก้ไขข้อมูล", japanese: "データ追加"))
                                            .font(.body.weight(.semibold))
                                    }
                                    .foregroundStyle(.primary)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 54)
                                    .background(Color(.secondarySystemGroupedBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                }

                                Button {
                                    onAdd()
                                } label: {
                                    Text(lang.t("Complete", thai: "เสร็จสิ้น", japanese: "完了"))
                                        .font(.body.weight(.bold))
                                        .foregroundStyle(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 54)
                                        .background(
                                            LinearGradient(
                                                colors: [Color(red: 1, green: 0.42, blue: 0.21), Color(red: 1, green: 0.55, blue: 0.1)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                }
                            }

                            Spacer()
                                .frame(height: 20)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                }
            }
        }
        .ignoresSafeArea()
    }

    private var currentTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: Date())
    }
}

// Modern macro card
struct ModernMacroCard: View {
    let icon: String
    let name: String
    let grams: Int
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(icon)
                    .font(.title2)

                Spacer()
            }

            Text(name)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)

            Text("\(grams)g")
                .font(.body.weight(.bold))
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// Legacy card for compatibility
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
