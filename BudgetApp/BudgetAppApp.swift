
import SwiftUI

@main
struct BudgetAppApp: App {
    
    let provider: CoreDataProvider
    let tagsSeeder: TagsSeeder
    
    init() {
        provider = CoreDataProvider()
        tagsSeeder = TagsSeeder(context: provider.context)
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                BudgetListScreen()
                    .onAppear {
                        let hasSeededData = UserDefaults.standard.bool(forKey: "hasSeedData")
                        if !hasSeededData {
                            
                            let commonTags = ["Food", "Dining", "Travel", "Entertainment", "Shopping", "Transportation", "Utilities", "Groceries", "Health", "Education"]
                            
                            do {
                                try tagsSeeder.seed(commonTags)
                                UserDefaults.standard.setValue(true, forKey: "hasSeedData")
                            } catch {
                                print(error)
                            }
                        }
                    }
            }.environment(\.managedObjectContext, provider.context)
        }
    }
}
