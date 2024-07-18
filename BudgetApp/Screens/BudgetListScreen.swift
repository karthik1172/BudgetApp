
import SwiftUI

struct BudgetListScreen: View {
    
    @FetchRequest(sortDescriptors: []) private var budgets: FetchedResults<Budget>
    @State private var isPresented: Bool = false
    @State private var isFilterPresented: Bool = false
    
    private var total: Double {
        budgets.reduce(0) { limit, budget in
            budget.limit + limit
        }
    }
    
    var body: some View {
        VStack {
            
            if budgets.isEmpty {
                ContentUnavailableView("No budgets available.", systemImage: "list.clipboard")
            } else {
                List {
                    HStack {
                        Spacer()
                        Text("Total Limit")
                        Text(total, format: .currency(code: Locale.currencyCode))
                        Spacer()
                    }.font(.headline)
                    
                    ForEach(budgets) { budget in
                        NavigationLink {
                            BudgetDetailScreen(budget: budget)
                        } label: {
                            BudgetCellView(budget: budget)
                        }
                    }
                }
            }
        
        }
        .overlay(alignment: .bottom, content: {
            Button("Filter") {
                isFilterPresented = true
            }.buttonStyle(.borderedProminent)
                .tint(.gray)
        })
        .navigationTitle("Budget App")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Budget") {
                        isPresented = true
                    }
                }
            }
            .sheet(isPresented: $isPresented, content: {
                AddBudgetScreen()
            })
            .sheet(isPresented: $isFilterPresented, content: {
                NavigationStack {
                    FilterScreen()
                }
            })
    }
}

#Preview {
    NavigationStack {
        BudgetListScreen()
    }.environment(\.managedObjectContext, CoreDataProvider.preview.context)
}


