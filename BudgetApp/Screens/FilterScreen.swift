
import SwiftUI

struct FilterScreen: View {
    
    @Environment(\.managedObjectContext) private var context
    @State private var selectedTags: Set<Tag> = []
    
    @FetchRequest(sortDescriptors: []) private var expenses: FetchedResults<Expense>
    @State private var filteredExpenses: [Expense] = []
    
    @State private var startPrice: Double?
    @State private var endPrice: Double?
    
    @State private var title: String = ""
    
    @State private var startDate = Date()
    @State private var endDate = Date()
    
    @State private var selectedSortOption: SortOptions? = nil
    @State private var selectedSortDirection: SortDirection = .asc
    
    @State private var selectedFilterOption: FilterOption? = nil
    
    private enum FilterOption: Identifiable, Equatable {
        
        case none
        case byTags(Set<Tag>)
        case byPriceRange(minPrice: Double, maxPrice: Double)
        case byTitle(String)
        case byDate(startDate: Date, endDate: Date)
        
        var id: String {
            switch self {
                case .byTags:
                    return "tags"
                case .byPriceRange:
                    return "priceRange"
                case .byTitle:
                    return "title"
                case .byDate:
                    return "date"
                case .none:
                    return "none"
            }
        }
        
    }
    
    
    private enum SortDirection: CaseIterable, Identifiable {
        
        case asc
        case desc
        
        var id: SortDirection {
            return self
        }
        
        var title: String {
            switch self {
                case .asc:
                    return "Ascending"
                case .desc:
                    return "Descending"
            }
        }
    }
    
    private enum SortOptions: String, CaseIterable, Identifiable {
        case title = "title"
        case date = "dateCreated"
        
        var id: SortOptions {
            return self
        }
        
        var title: String {
            switch self {
                case .title:
                    return "Title"
                case .date:
                    return "Date"
            }
        }
        
        var key: String {
           rawValue
        }
    }
    
    private func performFilter() {
        
        guard let selectedFilterOption = selectedFilterOption else { return }
        
        let request = Expense.fetchRequest()
        
        switch selectedFilterOption {
            case .none:
                request.predicate = NSPredicate(value: true)
            case .byTags(let tags):
                let tagNames = tags.map { $0.name }
                request.predicate = NSPredicate(format: "ANY tags.name IN %@", tagNames)
            case .byPriceRange(let minPrice, let maxPrice):
                request.predicate = NSPredicate(format: "amount >= %@ AND amount <= %@", NSNumber(value: minPrice), NSNumber(value: maxPrice))
            case .byTitle(let title):
                request.predicate = NSPredicate(format: "title BEGINSWITH %@", title)
            case .byDate(let startDate, let endDate):
                request.predicate = NSPredicate(format: "dateCreated >= %@ AND dateCreated <= %@", startDate as NSDate, endDate as NSDate)
        }
        
        do {
            filteredExpenses = try context.fetch(request)
        } catch {
            print(error)
        }
        
    }
    
    private func performSort() {
        
        guard let sortOption = selectedSortOption else { return }
        
        let request = Expense.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: sortOption.key, ascending: selectedSortDirection == .asc ? true: false)]
        
        do {
             filteredExpenses = try context.fetch(request)
        } catch {
            print(error)
        }
    }
    
    var body: some View {
        List {
            
            Section("Sort") {
                Picker("Sort Options", selection: $selectedSortOption) {
                    Text("Select").tag(Optional<SortOptions>(nil))
                    ForEach(SortOptions.allCases) { option in
                        Text(option.title)
                            .tag(Optional(option))
                    }
                }
                
                Picker("Sort Direction", selection: $selectedSortDirection) {
                    ForEach(SortDirection.allCases) { option in
                        Text(option.title)
                            .tag(option)
                    }
                }
                
                Button("Sort") {
                    performSort()
                }.buttonStyle(.borderless)
            }
            
            Section("Filter by Tags") {
                TagsView(selectedTags: $selectedTags)
                    .onChange(of: selectedTags, {
                        selectedFilterOption = .byTags(selectedTags)
                    })
            }
            
            Section("Filter by Price") {
                TextField("Start price", value: $startPrice, format: .number)
                TextField("End price", value: $endPrice, format: .number)
                Button("Search") {
                    guard let startPrice = startPrice,
                          let endPrice = endPrice else { return }
                    selectedFilterOption = .byPriceRange(minPrice: startPrice, maxPrice: endPrice)
                }
            }
            
            Section("Filter by title") {
                TextField("Title", text: $title)
                Button("Search") {
                    selectedFilterOption = .byTitle(title)
                }
            }
            
            Section("Filter by date") {
                DatePicker("Start date", selection: $startDate, displayedComponents: .date)
                DatePicker("End date", selection: $endDate, displayedComponents: .date)
                
                Button("Search") {
                    selectedFilterOption = .byDate(startDate: startDate, endDate: endDate)
                }
            }
        
            Section("Expenses") {
                ForEach(filteredExpenses) { expense in
                    ExpenseCellView(expense: expense)
                }
            }
            
            HStack {
                Spacer()
                Button("Show All") {
                    selectedFilterOption = FilterOption.none
                }
                Spacer()
            }
            
        }
        .onChange(of: selectedFilterOption, performFilter)
        .padding()
        .navigationTitle("Filter")
    }
}

#Preview {
    NavigationStack {
        FilterScreen()
            .environment(\.managedObjectContext, CoreDataProvider.preview.context)
    }
}
