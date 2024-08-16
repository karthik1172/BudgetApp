
import Foundation
import CoreData

class CoreDataProvider {
    
    let persistentContainer: NSPersistentContainer
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    static var preview: CoreDataProvider = {
        
        let provider = CoreDataProvider(inMemory: true)
        let context = provider.context
        
        let entertainment = Budget(context: context)
        entertainment.title = "Entertainment"
        entertainment.limit = 500
        entertainment.dateCreated = Date()
        
        let groceries = Budget(context: context)
        groceries.title = "Groceries"
        groceries.limit = 200
        groceries.dateCreated = Date()
        
        let milk = Expense(context: context)
        milk.title = "Milk"
        milk.amount = 5.45
        milk.dateCreated = Date()
        
        let cookie = Expense(context: context)
        cookie.title = "Cookie"
        cookie.amount = 8.45
        cookie.dateCreated = Date()
        
        groceries.addToExpenses(milk)
        groceries.addToExpenses(cookie)
        
        // list of expenses
        let foodItems = ["Burger", "Fries", "Cookies", "Noodles", "Popcorn", "Tacos", "Sushi", "Pizza", "Frozen Yogurt"]
        
        for foodItem in foodItems {
            let expense = Expense(context: context)
            expense.title = foodItem
            expense.amount = Double.random(in: 8...100)
            expense.quantity = Int16(Int.random(in: 1...12))
            expense.dateCreated = Date()
            expense.budget = groceries 
        }
        
        // insert tags
        let commonTags = ["Food", "Dining", "Travel", "Entertainment", "Shopping", "Transportation", "Utilities", "Groceries", "Health", "Education"]
        
        for commonTag in commonTags {
            let tag = Tag(context: context)
            tag.name = commonTag
            if let tagName = tag.name, ["Food", "Groceries"].contains(tagName) {
                cookie.addToTags(tag)
            }
            
            if let tagName = tag.name, ["Health"].contains(tagName) {
                milk.addToTags(tag)
            }
        }
        
        do {
            try context.save()
        } catch {
            print(error)
        }
        
        return provider
        
    }()
    
    init(inMemory: Bool = false) {
        
        //persistentContainer = NSPersistentContainer(name: "BudgetAppModel")
        persistentContainer = NSPersistentCloudKitContainer(name: "BudgetAppModel")
        
        if inMemory {
            persistentContainer.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        persistentContainer.loadPersistentStores { _, error in
            if let error {
                fatalError("Core Data store failed to initialize \(error)")
            }
        }
        
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true 
    }
}
