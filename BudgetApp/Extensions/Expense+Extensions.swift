
import Foundation
import CoreData

extension Expense {
    
    var total: Double {
        amount * Double(quantity) 
    }
    
    static func exists(context: NSManagedObjectContext, title: String) -> Bool {
        
        let request = Expense.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        
        do {
            let results = try context.fetch(request)
            return !results.isEmpty
        } catch {
            return false
        }
    }
    
}
