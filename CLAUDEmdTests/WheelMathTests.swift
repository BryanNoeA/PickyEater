import Testing
@testable import pickyeater

struct WheelMathTests {

    @Test(arguments: [
        (0.0, 0),
        (15.0, 11),
        (45.0, 10),
        (200.0, 5),
        (359.0, 0),
    ])
    func categoryForRotation(rotation: Double, expectedIndex: Int) {
        #expect(FoodCategory.category(forRotation: rotation) == FoodCategory.allCases[expectedIndex])
    }

    @Test
    func normalizesRotationsGreaterThan360() {
        #expect(FoodCategory.category(forRotation: 725) == FoodCategory.category(forRotation: 5))
    }

    @Test
    func normalizesNegativeRotations() {
        // Must not crash and must return a valid category.
        let category = FoodCategory.category(forRotation: -15)
        #expect(FoodCategory.allCases.contains(category))
    }
}
