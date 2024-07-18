
import SwiftUI

struct ExpenseCellView: View {
    
    @ObservedObject var expense: Expense
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("\(expense.title ?? "") (\(expense.quantity))")
                Spacer()
                Text(expense.total, format: .currency(code: Locale.currencyCode))
                    .allowsHitTesting(false)
            }//contentShape(Rectangle())
            ScrollView(.horizontal) {
                HStack {
                    ForEach(Array(expense.tags as? Set<Tag> ?? [])) { tag in
                        Text(tag.name ?? "")
                            .font(.caption)
                            .padding(6)
                            .foregroundStyle(.white)
                            .background(.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 16.0, style: .continuous))
                    }
                }
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ExpenseCellViewContainer: View {
    
    @FetchRequest(sortDescriptors: []) private var expenses: FetchedResults<Expense>
    
    var body: some View {
        ExpenseCellView(expense: expenses[1])
    }
}

#Preview {
    ExpenseCellViewContainer()
        .environment(\.managedObjectContext, CoreDataProvider.preview.context)
}
