

import SwiftUI

struct AddBudgetScreen: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var context
    
    @State private var title: String = ""
    @State private var limit: Double?
    
    @State private var errorMessage: String = ""
    
    private var isFormValid: Bool {
        !title.isEmptyOrWhitespace && limit != nil && Double(limit!) > 0
    }
    
    private func saveBudget() {
        
        let budget = Budget(context: context)
        budget.title = title
        budget.limit = limit ?? 0.0
        budget.dateCreated = Date()
        
        do {
            try context.save()
            errorMessage = ""
            dismiss() 
        } catch {
            errorMessage = "Unable to save budget."
        }
    }
    
    var body: some View {
        Form {
            Text("New Budget")
                .font(.title)
                .font(.headline)
            
            TextField("Title", text: $title)
                .presentationDetents([.medium])
            TextField("Limit", value: $limit, format: .number)
                .keyboardType(.numberPad)
            Button {
                if !Budget.exists(context: context, title: title) {
                    saveBudget()
                } else {
                    // error Message
                    errorMessage = "Budget title already exists."
                }
            } label: {
                Text("Save")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!isFormValid)
            .presentationDetents([.medium])

            Text(errorMessage)
        }
    }
}

#Preview {
    AddBudgetScreen()
        .environment(\.managedObjectContext, CoreDataProvider(inMemory: true).context)
}
