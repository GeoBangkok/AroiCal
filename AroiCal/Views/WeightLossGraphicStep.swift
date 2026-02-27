import SwiftUI

struct WeightLossGraphicStep: View {
    @Environment(LanguageManager.self) private var lang
    let name: String
    @State private var animateChart: Bool = false
    @State private var showStats: Bool = false

    private let months = ["Jan", "Mar", "May", "Jul", "Sep", "Nov"]
    private let aroiData: [CGFloat] = [1.0, 0.88, 0.76, 0.65, 0.56, 0.48]
    private let othersData: [CGFloat] = [1.0, 0.96, 0.93, 0.91, 0.90, 0.89]

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                VStack(spacing: 8) {
                    AroiCalHeader()

                    Text(name.isEmpty
                         ? lang.t("The Aroi Cal Difference", thai: "ความแตกต่างของ Aroi Cal", japanese: "Aroi Calの違い")
                         : lang.t("\(name)'s Path to Success", thai: "เส้นทางสู่ความสำเร็จของ\(name)", japanese: "\(name)さんの成功への道"))
                        .font(.title.bold())
                        .multilineTextAlignment(.center)

                    Text(lang.t("Our users see real results over time", thai: "ผู้ใช้ของเราเห็นผลลัพธ์จริงเมื่อเวลาผ่านไป", japanese: "ユーザーは時間とともに確かな結果を得ています"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 24)

                VStack(spacing: 16) {
                    HStack(spacing: 20) {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(red: 1, green: 0.42, blue: 0.21), Color(red: 1, green: 0.72, blue: 0)],
                                        startPoint: .leading, endPoint: .trailing
                                    )
                                )
                                .frame(width: 10, height: 10)
                            Text(lang.t("Aroi Cal Users", thai: "ผู้ใช้ Aroi Cal", japanese: "Aroi Calユーザー"))
                                .font(.caption.weight(.medium))
                        }
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color(.systemGray3))
                                .frame(width: 10, height: 10)
                            Text(lang.t("Others", thai: "คนอื่นๆ", japanese: "その他"))
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.secondary)
                        }
                    }

                    GeometryReader { geo in
                        let w = geo.size.width
                        let h: CGFloat = 180
                        let padding: CGFloat = 30

                        ZStack(alignment: .bottomLeading) {
                            Path { path in
                                path.move(to: CGPoint(x: padding, y: 0))
                                path.addLine(to: CGPoint(x: padding, y: h))
                                path.addLine(to: CGPoint(x: w, y: h))
                            }
                            .stroke(Color(.systemGray4), lineWidth: 1)

                            ForEach(0..<6, id: \.self) { i in
                                let x = padding + (w - padding) * CGFloat(i) / 5
                                Text(months[i])
                                    .font(.system(size: 9))
                                    .foregroundStyle(.tertiary)
                                    .position(x: x, y: h + 14)
                            }

                            chartLine(data: othersData, width: w, height: h, padding: padding, color: Color(.systemGray3))

                            chartLine(data: aroiData, width: w, height: h, padding: padding, gradient: true)

                            if animateChart {
                                let lastAroiY = h * aroiData.last!
                                let lastX = padding + (w - padding)
                                Circle()
                                    .fill(Color(red: 1, green: 0.42, blue: 0.21))
                                    .frame(width: 8, height: 8)
                                    .position(x: lastX, y: lastAroiY)
                            }
                        }
                    }
                    .frame(height: 210)

                    Text(lang.t("Weight loss over 12 months", thai: "การลดน้ำหนักใน 12 เดือน", japanese: "12ヶ月間の体重減少"))
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .padding(20)
                .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 20))
                .padding(.horizontal, 24)

                if showStats {
                    VStack(spacing: 12) {
                        HStack(spacing: 16) {
                            statCard(
                                value: "3.2x",
                                label: lang.t("More weight lost", thai: "ลดน้ำหนักได้มากกว่า", japanese: "より多くの減量"),
                                icon: "arrow.down.right"
                            )
                            statCard(
                                value: "87%",
                                label: lang.t("Keep it off", thai: "รักษาน้ำหนักได้", japanese: "維持に成功"),
                                icon: "checkmark.shield"
                            )
                        }

                        HStack(spacing: 16) {
                            statCard(
                                value: "52%",
                                label: lang.t("Reach goal weight", thai: "ถึงน้ำหนักเป้าหมาย", japanese: "目標体重達成"),
                                icon: "star.fill"
                            )
                            statCard(
                                value: "4.9",
                                label: lang.t("User rating", thai: "คะแนนผู้ใช้", japanese: "ユーザー評価"),
                                icon: "heart.fill"
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                Spacer(minLength: 100)
            }
        }
        .task {
            withAnimation(.easeOut(duration: 1.0)) {
                animateChart = true
            }
            try? await Task.sleep(for: .milliseconds(600))
            withAnimation(.spring(duration: 0.6)) {
                showStats = true
            }
        }
    }

    private func chartLine(data: [CGFloat], width: CGFloat, height: CGFloat, padding: CGFloat, color: Color? = nil, gradient: Bool = false) -> some View {
        Path { path in
            for (i, value) in data.enumerated() {
                let x = padding + (width - padding) * CGFloat(i) / CGFloat(data.count - 1)
                let y = height * value
                if i == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    let prev = data[i - 1]
                    let prevX = padding + (width - padding) * CGFloat(i - 1) / CGFloat(data.count - 1)
                    let prevY = height * prev
                    let midX = (prevX + x) / 2
                    path.addCurve(to: CGPoint(x: x, y: y),
                                  control1: CGPoint(x: midX, y: prevY),
                                  control2: CGPoint(x: midX, y: y))
                }
            }
        }
        .trim(from: 0, to: animateChart ? 1 : 0)
        .stroke(
            gradient
                ? AnyShapeStyle(LinearGradient(
                    colors: [Color(red: 1, green: 0.42, blue: 0.21), Color(red: 1, green: 0.72, blue: 0)],
                    startPoint: .leading, endPoint: .trailing
                ))
                : AnyShapeStyle(color ?? .gray),
            style: StrokeStyle(lineWidth: 3, lineCap: .round)
        )
    }

    private func statCard(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color(red: 1, green: 0.42, blue: 0.21))

            Text(value)
                .font(.title2.weight(.bold))

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
    }
}
