import Foundation

nonisolated struct FoodEntry: Identifiable, Codable, Sendable {
    let id: UUID
    var name: String
    var nameThai: String
    var nameJapanese: String
    var calories: Int
    var protein: Double
    var carbs: Double
    var fat: Double
    var servingSize: String
    var imageData: Data?
    var date: Date

    init(
        id: UUID = UUID(),
        name: String,
        nameThai: String = "",
        nameJapanese: String = "",
        calories: Int,
        protein: Double,
        carbs: Double,
        fat: Double,
        servingSize: String = "1 serving",
        imageData: Data? = nil,
        date: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.nameThai = nameThai
        self.nameJapanese = nameJapanese
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.servingSize = servingSize
        self.imageData = imageData
        self.date = date
    }
}
