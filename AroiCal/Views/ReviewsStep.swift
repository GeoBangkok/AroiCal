import SwiftUI
import StoreKit

struct ReviewsStep: View {
    @Environment(LanguageManager.self) private var lang
    @Environment(\.requestReview) private var requestReview

    private var reviews: [(name: String, stars: Int, text: String, textThai: String, textJP: String)] {
        // Japanese-native reviews shown first for Japanese users
        let allReviews: [(name: String, stars: Int, text: String, textThai: String, textJP: String)] = [
            ("田中 陽菜", 5,
             "Finally an app that accurately tracks Japanese food! 定食, ラーメン, コンビニ弁当 — it gets them all right.",
             "ในที่สุดก็มีแอพที่ติดตามอาหารญี่ปุ่นได้อย่างแม่นยำ！",
             "ついに日本食を正確に記録できるアプリが見つかった！定食、ラーメン、コンビニ弁当も全部ちゃんと認識してくれる。"),
            ("鈴木 健太", 5,
             "Lost 6kg in 3 months just by scanning my meals. Works perfectly for Japanese food.",
             "ลดน้ำหนักได้ 6 กก. ใน 3 เดือนแค่สแกนอาหาร",
             "食事をスキャンするだけで3ヶ月で6kg減量できました。日本食にも完璧に対応しています。"),
            ("Sarah M.", 5,
             "Lost 8kg in 2 months! The Thai food database is incredibly accurate.",
             "ลดน้ำหนักได้ 8 กก. ใน 2 เดือน! ฐานข้อมูลอาหารไทยแม่นยำมาก",
             "2ヶ月で8kg減量！タイ料理のデータベースが非常に正確です。"),
            ("พี่ต้น", 5,
             "Best calorie tracker for Thai food. So easy to use!",
             "แอพนับแคลอรีอาหารไทยที่ดีที่สุด ใช้ง่ายมาก!",
             "タイ料理のカロリー計算に最適。とても使いやすい！"),
            ("James K.", 5,
             "The AI food scanner is amazing. Just point and shoot!",
             "AI สแกนอาหารเยี่ยมมาก แค่ถ่ายรูปก็รู้แคลอรี!",
             "AIフードスキャナーが素晴らしい。撮るだけ！"),
            ("ゆき", 5,
             "Finally an app that recognizes Asian foods properly!",
             "ในที่สุดก็มีแอพที่จำอาหารเอเชียได้ถูกต้อง!",
             "アジア料理をちゃんと認識してくれるアプリ！"),
        ]
        // For Japanese users, surface the two Japanese-native reviews first
        if lang.current == .japanese {
            return [allReviews[0], allReviews[1], allReviews[4], allReviews[5]]
        }
        // For Thai users, show Thai-relevant reviews first
        return [allReviews[2], allReviews[3], allReviews[4], allReviews[5]]
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    AroiCalHeader()
                    Text(lang.t("People Love Aroi Cal", thai: "ผู้คนรัก Aroi Cal", japanese: "みんなAroi Calが大好き"))
                        .font(.title.bold())
                        .multilineTextAlignment(.center)

                    HStack(spacing: 4) {
                        ForEach(0..<5, id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .foregroundStyle(Color(red: 1, green: 0.72, blue: 0))
                        }
                    }
                    .font(.title3)

                    Text(lang.t("4.9 on the App Store", thai: "4.9 บน App Store", japanese: "App Storeで4.9評価"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 24)

                VStack(spacing: 12) {
                    ForEach(Array(reviews.enumerated()), id: \.offset) { _, review in
                        ReviewCard(
                            name: review.name,
                            stars: review.stars,
                            text: lang.t(review.text, thai: review.textThai, japanese: review.textJP)
                        )
                    }
                }
                .padding(.horizontal, 24)

                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "person.3.fill")
                            .foregroundStyle(Color(red: 1, green: 0.42, blue: 0.21))

                        Text(lang.t("Join 50,000+ happy users", thai: "เข้าร่วมผู้ใช้มากกว่า 50,000 คน", japanese: "5万人以上のユーザーが利用中"))
                            .font(.subheadline.weight(.semibold))
                    }

                    Text(lang.t("Aroi Cal users lose 2x more weight on average", thai: "ผู้ใช้ Aroi Cal ลดน้ำหนักได้มากกว่า 2 เท่า", japanese: "Aroi Calユーザーは平均2倍のダイエット効果を実感"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 24)
                .frame(maxWidth: .infinity)
                .background(Color(red: 1, green: 0.42, blue: 0.21).opacity(0.08), in: .rect(cornerRadius: 16))
                .padding(.horizontal, 24)

                Spacer(minLength: 100)
            }
        }
        .task {
            requestReview()
        }
    }
}

struct ReviewCard: View {
    let name: String
    let stars: Int
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 1, green: 0.42, blue: 0.21).opacity(0.3), Color(red: 1, green: 0.72, blue: 0).opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 36, height: 36)

                    Text(String(name.prefix(1)))
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color(red: 1, green: 0.42, blue: 0.21))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(.subheadline.weight(.semibold))

                    HStack(spacing: 2) {
                        ForEach(0..<stars, id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundStyle(Color(red: 1, green: 0.72, blue: 0))
                        }
                    }
                }

                Spacer()
            }

            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(3)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
    }
}
