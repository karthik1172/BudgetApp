

import SwiftUI

struct EditExpenseScreen: View {
    
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss
   
    @ObservedObject var expense: Expense
    let onUpdate: () -> Void
    
    private func updateExpense() {
        
        do {
            try context.save()
            onUpdate()
        } catch {
            print(error)
        }
        
    }
    
    var body: some View {
        Form {
            TextField("Title", text: Binding(get: {
                expense.title ?? ""
            }, set: { newValue in
                expense.title = newValue
            }))
            TextField("Amount", value: $expense.amount, format: .number)
            TextField("Quantity", value: $expense.quantity, format: .number)
            TagsView(selectedTags: Binding(get: {
                Set(expense.tags?.compactMap { $0 as? Tag } ?? [])
            }, set: { newValue in
                expense.tags = NSSet(array: Array(newValue))
            }))
        }
        
        .toolbar(content: {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Update") {
                    updateExpense()
                }
            }
        })
        .navigationTitle(expense.title ?? "")
    }
}

struct EditExpenseContainerView: View {
    
    @FetchRequest(sortDescriptors: []) private var expenses: FetchedResults<Expense>
    
    var body: some View {
        NavigationStack {
            EditExpenseScreen(expense: expenses[0], onUpdate: { })
        }
    }
}

#Preview {
    EditExpenseContainerView()
        .environment(\.managedObjectContext, CoreDataProvider.preview.context)
}
