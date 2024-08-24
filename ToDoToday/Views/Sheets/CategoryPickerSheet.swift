//
//  CategoryPickerSheet.swift
//  LifeLog
//
//  Created by Douglas Inglis on 26/05/2023.
//

import SwiftUI
import PopupView

struct CategoryPickerSheet: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @State var categoryList: [Category] = ToDoDataController.shared.categoryList
    
    @Binding var categories: [Category]
    
    @State private var viewModel = ToDoViewModel.shared
    
    @State private var allTitle = "All"
    @State private var unCompletedTitle = "Uncompleted"
    @State private var completedTitle = "Completed"
    
    @State private var searchString: String = ""
    
    
    private var isSelected: Binding<[Bool]> {
        Binding(
            get: {
                
                /* Start off with an array of the correct length */
                var ret = Array(repeating: false, count: categoryList.count)
                
                /* For each currently selected category */
                for category in categories {
                    
                    /* Find the index of that category in the list of categories */
                    let index = categoryList.firstIndex(of: category)
                    if index != nil {
                        
                        /* Toggle that category to true */
                        ret[index!] = true
                    }
                }
                
                /* Return the array */
                return ret
            },
            set: { newValue in
                
                /* Setup the new category list */
                var newCategories: [Category] = []
                
                /* Foreach index in the new array */
                for i in newValue.indices {
                    
                    /* If the value is true */
                    if newValue[i] {
                        
                        /* Add it to the new category list */
                        newCategories.append(categoryList[i])
                    }
                }
                
                /* Set the new categories list */
                categories = newCategories
                
                /* Update the view model */
                ToDoViewModel.shared.update()
            }
        )
    }

    
    @State var isShowingExtras: Bool = true

    
    private var allCompleted: Binding<Bool> {
        Binding(
            get: {
                
                /* If all selected */
                return viewModel.all
            },
            set: {newValue in
                
                /* Passthrough the update to the view model */
                viewModel.all = newValue
                viewModel.update()
            }
        )
    }
    
    private var unCompleted: Binding<Bool> {
        Binding(
            get: {
                
                /* If not completed selected */
                return viewModel.showNotCompleted
            },
            set: {newValue in
                
                /* Passthrough the update to the view model */
                viewModel.showNotCompleted = newValue
                viewModel.update()
            }
        )
    }
    
    private var completed: Binding<Bool> {
        Binding(
            get: {
                
                /* If completed selected */
                return viewModel.showCompleted
            },
            set: {newValue in
                
                /* Passthrough the update to the view model */
                viewModel.showCompleted = newValue
                viewModel.update()
            }
        )
    }
    
    var body: some View {
        VStack {
                    
            /* Exit Button */
            ExitButtonView(dismiss: dismiss.callAsFunction)
            
            ScrollView {
                
                /* Search Field */
                TextField("Search", text: $searchString)
                    .padding()
                    .frame(height: 55)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.vertical)

                
                /* Button to add a new category */
                Button(action: {
                    categoryList.insert(Category(ctx: ToDoDataController.shared.viewContext), at: 0)
                }) {
                    HStack {
                        Text("Add new category")
                            .font(.headline)
                            .foregroundColor(Color(.label))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        PlusButton()
                        
                        
                    }
                    .padding(10)
                }
                .frame(height:55)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.top, 20)
                
                /* Add the extra items if requested */
                if isShowingExtras {
                    if searchString == "" || allTitle.lowercased().contains(searchString.lowercased()) {
                        CategoryView(title: $allTitle, selected: allCompleted, locked:true)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                    }
                    
                    if searchString == "" || unCompletedTitle.lowercased().contains(searchString.lowercased()) {
                        CategoryView(title: $unCompletedTitle, selected: unCompleted, locked:true)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                    }
                    
                    if searchString == "" || completedTitle.lowercased().contains(searchString.lowercased()) {
                        CategoryView(title: $completedTitle, selected: completed, locked:true)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                    }
                }
                
                /* For all the to do items */
                ForEach(categoryList) { category in
                    
                    /* Get the index of the category */
                    let index: Int = categoryList.firstIndex(of: category)!
                    
                    /* If we're searching for this item */
                    if searchString == "" || category.title.lowercased().contains(searchString.lowercased()) {
                        HStack {
                            
                            /* Show the to do item */
                            CategoryView(title: $categoryList[index].title, selected: isSelected[index])
                            
                            /* Show a delete button */
                            DeleteButton()
                                .onTapGesture {
                                    
                                    
                                    /* Get the index of the category, if it's in the showing categories */
                                    let selectedIndex = ToDoViewModel.shared.showingCategories.firstIndex(of: category)
                                    
                                    /* Delete the category */
                                    ToDoDataController.shared.viewContext.delete(categoryList[index])
                                    
                                    /* Remove the category if it's currently selected */
                                    if selectedIndex != nil {
                                        ToDoViewModel.shared.showingCategories.remove(at: selectedIndex!)
                                    }
                                    
                                    /* Remove the category locally */
                                    categoryList.remove(at: index)

                                    /* Save and update everything */
                                    ToDoViewModel.shared.update()
                                }
                        }
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                }
            }
            .onAppear {
                /* Update category list when reopened */
                ToDoDataController.shared.update()
                categoryList = ToDoDataController.shared.categoryList
            }
        }
        .padding(.horizontal)
    }
}

struct CategoryPickerSheet_Previews: PreviewProvider {
    @State static var categories:[Category] = []
    static var previews: some View {
        CategoryPickerSheet(categories: $categories)
    }
}
