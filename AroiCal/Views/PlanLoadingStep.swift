import SwiftUI

struct PlanLoadingStep: View {
    @Environment(LanguageManager.self) private var lang
    @State private var progress: Double = 0
    @State private var currentPhase: Int = 0
    let onComplete: () -> Void

    private var phases: [(icon: String, text: String)] {
        [
            ("person.text.rectangle", lang.t("Analyzing your profile...", thai: "กำลังวิเคราะห์โปรไฟล์...", japanese: "プロフィールを分析中...")),
            ("scalemass", lang.t("Calculating your TDEE...", thai: "กำลังคำนวณ TDEE...", japanese: "TDEEを計算中...")),
            ("chart.bar.doc.horizontal", lang.t("Setting macro targets...", thai: "กำลังตั้งเป้าหมายมาโคร...", japanese: "マクロ目標を設定中...")),
            ("sparkles", lang.t("Personalizing your plan...", thai: "กำลังปรับแต่งแผนของคุณ...", japanese: "プランをカスタマイズ中...")),
        ]
    }

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            AroiCalHeader()

            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 8)
                    .frame(width: 140, height: 140)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(
                            colors: [Color(red: 1, green: 0.42, blue: 0.21), Color(red: 1, green: 0.72, blue: 0)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 140, height: 140)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 4) {
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                    
                    Image(systemName: "bolt.fill")
                        .font(.caption)
                        .foregroundStyle(Color(red: 1, green: 0.42, blue: 0.21))
                }
            }

            VStack(spacing: 16) {
                Text(lang.t("Creating Your Plan", thai: "กำลังสร้างแผนของคุณ", japanese: "プランを作成中"))
                    .font(.title2.bold())

                VStack(spacing: 10) {
                    ForEach(Array(phases.enumerated()), id: \.offset) { index, phase in
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(index <= currentPhase
                                          ? Color(red: 1, green: 0.42, blue: 0.21)
                                          : Color(.systemGray5))
                                    .frame(width: 28, height: 28)

                                if index < currentPhase {
                                    Image(systemName: "checkmark")
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(.white)
                                } else if index == currentPhase {
                                    Image(systemName: phase.icon)
                                        .font(.caption2.weight(.bold))
                                        .foregroundStyle(.white)
                                } else {
                                    Image(systemName: phase.icon)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }

                            Text(phase.text)
                                .font(.subheadline)
                                .foregroundStyle(index <= currentPhase ? .primary : .secondary)

                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, 40)
            }

            Spacer()
            Spacer()
        }
        .task {
            await runAnimation()
        }
    }

    private func runAnimation() async {
        for i in 0..<phases.count {
            withAnimation(.spring(duration: 0.4)) {
                currentPhase = i
            }
            let target = Double(i + 1) / Double(phases.count)
            let steps = 20
            for step in 1...steps {
                try? await Task.sleep(for: .milliseconds(50))
                let newProgress = progress + (target - progress) * (Double(step) / Double(steps))
                withAnimation(.linear(duration: 0.05)) {
                    progress = newProgress
                }
            }
            try? await Task.sleep(for: .milliseconds(300))
        }
        try? await Task.sleep(for: .milliseconds(500))
        onComplete()
    }
}
