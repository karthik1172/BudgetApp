
import Foundation
import CoreData

extension Budget {
    
    static func exists(context: NSManagedObjectContext, title: String) -> Bool {
        
        let request = Budget.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        
        do {
            let results = try context.fetch(request)
            return !results.isEmpty
        } catch {
            return false
        }
    }
    
    var spent: Double {
        
        guard let expenses = expenses as? Set<Expense> else { return 0 }
        return expenses.reduce(0) { total, expense in
            return total + expense.amount
        }
    }
    
    var remaining: Double {
        limit - spent
    }
    
}
