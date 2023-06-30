//
//  AddFoodView.swift
//  iCalories
//
//  Created by Esad Dursun on 23.06.23.
//

import SwiftUI

struct AddFoodView: View {
    @Environment(\.managedObjectContext) var managedObjContext
    @Environment(\.dismiss) var dismiss
    
    var optName: String?
    var optGrams: Double?
    var optCalories: Double?
    var optRatio: Double?
    
    @State private var name: String
    @State private var date = Date()
    @State private var calories: Double
    @State private var grams: Double
    @State private var isAutoCalculateChecked: Bool
    @State private var isNameEmptyAlertPresented = false
    
    init(optName: String?, optGrams: Double?, optCalories: Double?, optRatio: Double?) {
        self.optName = optName
        self.optGrams = optGrams
        self.optCalories = optCalories
        self.optRatio = optRatio
        
        _name = State(initialValue: optName ?? "")
        _calories = State(initialValue: optCalories ?? 0)
        _grams = State(initialValue: optGrams ?? 0)
        _isAutoCalculateChecked = State(initialValue: (optGrams != nil && optCalories != nil))
    }
    
    var isNameEmpty: Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Food name", text: $name)
                        .font(.system(size: 20))
                        .padding(.vertical)
                    
                    VStack(alignment: .leading) {
                        Text("Grams: \(Int(grams))")
                        Slider(value: $grams, in: 0...1000, step: 5)
                            .accentColor(.teal)
                    }
                    .padding()
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Calories: \(Int(calories))")
                            
                            if optRatio != nil && !isAutoCalculateChecked {
                                Spacer()
                                Text("(Manual)")
                            }
                        }
                        
                        Slider(value: $calories, in: 0...2000, step: 5)
                            .accentColor(.teal)
                            .disabled(isAutoCalculateChecked)
                    }
                    .padding()
                    
                    if optRatio != nil {
                        Toggle("Auto Calculate", isOn: $isAutoCalculateChecked)
                            .tint(.teal)
                    }
                    
                    DatePicker(selection: $date, in: ...Date.now, displayedComponents: .date) {
                        Text("Select a date")
                    }
                    .datePickerStyle(CompactDatePickerStyle())
                    .accentColor(.teal)
                    
                    HStack {
                        Spacer()
                        Button("Submit") {
                            if isNameEmpty {
                                isNameEmptyAlertPresented = true
                            } else {
                                DataController().addFood(date: date, name: name, grams: grams, calories: calories, context: managedObjContext)
                                dismiss()
                            }
                        }
                        .tint(.teal)
                        .disabled(calories == 0 || grams == 0)
                        .alert(isPresented: $isNameEmptyAlertPresented) {
                            Alert(title: Text("Error"), message: Text("Please enter a food name"), dismissButton: .default(Text("OK")))
                        }
                        Spacer()
                    }
                }
            }
            .navigationTitle("Add Food")
            .onChange(of: grams) { newValue in
                if isAutoCalculateChecked {
                    calculateCaloriesFromGrams()
                }
            }
        }
    }
    
    private func calculateCaloriesFromGrams() {
        if let ratio = optRatio {
            calories = grams * ratio
        }
    }
}

struct AddFoodView_Previews: PreviewProvider {
    static var previews: some View {
        AddFoodView(optName: nil, optGrams: nil, optCalories: nil, optRatio: nil)
    }
}
