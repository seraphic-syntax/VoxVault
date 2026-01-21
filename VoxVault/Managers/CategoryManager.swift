import Foundation

// MARK: - Category Manager
class CategoryManager {
    static let shared = CategoryManager()
    
    static let defaultCategories = [
        "Personal",
        "Work",
        "Meeting",
        "Notes",
        "Ideas",
        "Interview",
        "Lecture",
        "Podcast"
    ]
    
    private let userDefaults = UserDefaults.standard
    private let customCategoriesKey = "customCategories"
    
    var customCategories: [String] {
        get {
            return userDefaults.stringArray(forKey: customCategoriesKey) ?? []
        }
        set {
            userDefaults.set(newValue, forKey: customCategoriesKey)
        }
    }
    
    var allCategories: [String] {
        return (CategoryManager.defaultCategories + customCategories).sorted()
    }
    
    func addCustomCategory(_ category: String) {
        guard !category.isEmpty,
              !CategoryManager.defaultCategories.contains(category),
              !customCategories.contains(category) else {
            return
        }
        customCategories.append(category)
    }
    
    func deleteCustomCategory(_ category: String) {
        customCategories.removeAll { $0 == category }
    }
}
