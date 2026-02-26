import SwiftUI

struct MenuRecommendationView: View {
    let recommendations: MenuRecommendations
    @State private var selectedTab = 0
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Custom Tab Picker
                Picker("Recommendation Type", selection: $selectedTab) {
                    Label("Healthiest", systemImage: "leaf.fill")
                        .tag(0)
                    Label("Tastiest", systemImage: "star.fill")
                        .tag(1)
                    Label("Balanced", systemImage: "scale.3d")
                        .tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .background(Color(UIColor.systemBackground))

                ScrollView {
                    VStack(spacing: 16) {
                        // Analysis Overview
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(.yellow)
                                Text("Menu Analysis")
                                    .font(.headline)
                                Spacer()
                            }

                            Text(recommendations.analysis)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding()
                        .background(Color.yellow.opacity(0.1))
                        .cornerRadius(12)

                        // Content based on selected tab
                        if selectedTab == 0 {
                            // Healthiest Options
                            VStack(spacing: 16) {
                                ForEach(recommendations.healthiest) { item in
                                    MenuItemCard(item: item, cardColor: .green)
                                }
                            }
                        } else if selectedTab == 1 {
                            // Tastiest Options
                            VStack(spacing: 16) {
                                ForEach(recommendations.tastiest) { item in
                                    MenuItemCard(item: item, cardColor: .orange)
                                }
                            }
                        } else {
                            // Balanced Choice
                            if let balancedChoice = recommendations.balancedChoice {
                                MenuItemCard(item: balancedChoice, cardColor: .purple, isFeature: true)
                            }
                        }

                        // Tips Section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(.blue)
                                Text("Pro Tips")
                                    .font(.headline)
                                Spacer()
                            }

                            ForEach(recommendations.tips, id: \.self) { tip in
                                HStack(alignment: .top) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.caption)
                                    Text(tip)
                                        .font(.subheadline)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .padding()
                }
            }
            .navigationTitle("AI Recommendations")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct MenuItemCard: View {
    let item: MenuItem
    let cardColor: Color
    var isFeature: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with scores
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(isFeature ? .title2 : .headline)
                        .fontWeight(.bold)

                    Text(item.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(spacing: 8) {
                    // Health Score
                    ScoreBadge(
                        score: item.healthScore,
                        label: "Health",
                        color: .green,
                        icon: "leaf.fill"
                    )

                    // Taste Score
                    ScoreBadge(
                        score: item.tasteScore,
                        label: "Taste",
                        color: .orange,
                        icon: "star.fill"
                    )
                }
            }

            Divider()

            // Calories
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(.red)
                    .font(.caption)
                Text("\(item.estimatedCalories) calories")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Nutrients if available
            if let nutrients = item.nutrients {
                HStack(spacing: 16) {
                    if let protein = nutrients.protein {
                        NutrientTag(label: "Protein", value: protein)
                    }
                    if let carbs = nutrients.carbs {
                        NutrientTag(label: "Carbs", value: carbs)
                    }
                    if let fat = nutrients.fat {
                        NutrientTag(label: "Fat", value: fat)
                    }
                }
                .font(.caption)
            }

            // Reasoning
            Text(item.reasoning)
                .font(.caption)
                .foregroundColor(.secondary)
                .italic()
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(cardColor.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(cardColor.opacity(0.3), lineWidth: isFeature ? 2 : 1)
                )
        )
    }
}

struct ScoreBadge: View {
    let score: Int
    let label: String
    let color: Color
    let icon: String

    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundColor(color)

            Text("\(score)/10")
                .font(.caption2)
                .fontWeight(.bold)

            Text(label)
                .font(.system(size: 9))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.15))
        )
    }
}

struct NutrientTag: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .fontWeight(.semibold)
            Text(label)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    // Preview with sample data - actual data comes from OpenAI API
    MenuRecommendationView(
        recommendations: MenuRecommendations(
            healthiest: [],
            tastiest: [],
            balancedChoice: nil,
            analysis: "Menu analysis will appear here",
            tips: []
        )
    )
}