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
        ZStack {
            // Full screen image background
            if let data = entry.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()

                // Dark overlay for readability
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
            }

            VStack {
                // Top bar with back and menu buttons
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .background(.ultraThinMaterial, in: Circle())
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
                            .frame(width: 40, height: 40)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                }
                .padding()

                Spacer()

                // Bottom card
                VStack(spacing: 0) {
                    // Bookmark and time
                    HStack {
                        Image(systemName: "bookmark")
                            .foregroundStyle(.secondary)

                        Text(currentTime)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                    // Food name and serving selector
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(displayName)
                                .font(.title2.weight(.bold))
                                .foregroundStyle(.primary)

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
                        HStack(spacing: 16) {
                            Button {
                                if servings > 1 {
                                    servings -= 1
                                }
                            } label: {
                                Image(systemName: "minus")
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(.primary)
                            }

                            Text("\(servings)")
                                .font(.body.weight(.semibold))
                                .frame(width: 30)

                            Button {
                                servings += 1
                            } label: {
                                Image(systemName: "plus")
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(.primary)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6), in: Capsule())
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                    // Calories section
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "flame.fill")
                            .font(.title2)
                            .foregroundStyle(Color(red: 1, green: 0.42, blue: 0.21))

                        VStack(alignment: .leading, spacing: 0) {
                            Text(lang.t("Calories", thai: "แคลอรี", japanese: "カロリー"))
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.secondary)

                            Text("\(entry.calories * servings)")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundStyle(.primary)
                        }

                        Spacer()
                    }
                    .padding(20)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                    // Macros
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
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                    // Spacer for paging indicator
                    HStack(spacing: 8) {
                        Circle()
                            .fill(.primary)
                            .frame(width: 6, height: 6)
                        Circle()
                            .fill(.secondary.opacity(0.3))
                            .frame(width: 6, height: 6)
                    }
                    .padding(.top, 16)

                    // Ingredients section
                    VStack(alignment: .leading, spacing: 8) {
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

                        // Sample ingredient
                        Text("Lettuce • 20 cal • 1.5 serving")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                    // Action buttons
                    HStack(spacing: 12) {
                        Button {
                            // Add ingredient
                        } label: {
                            HStack {
                                Image(systemName: "plus")
                                Text(lang.t("Add Ingredient", thai: "แก้ไขข้อมูล", japanese: "材料を追加"))
                            }
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }

                        Button {
                            onAdd()
                        } label: {
                            Text(lang.t("Complete", thai: "เสร็จสิ้น", japanese: "完了"))
                                .font(.body.weight(.semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
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
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 16)
                }
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
    }

    private var currentTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: Date())
    }
}

// Modern macro card matching the screenshot design
struct ModernMacroCard: View {
    let icon: String
    let name: String
    let grams: Int
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(icon)
                    .font(.title3)

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
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
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
