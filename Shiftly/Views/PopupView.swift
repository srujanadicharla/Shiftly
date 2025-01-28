//
//  PopupView.swift
//  Shiftly
//
//  Created by Srujan Simha Adicharla on 1/25/25.
//

import SwiftUI

struct PopupView: View {
    @Binding var isVisible: Bool
    @Binding var enteredValue: String

    var body: some View {
        VStack(spacing: 20) {
            Text("Enter Hourly Rate")
                .font(.headline)
            
            TextField("Type here...", text: $enteredValue)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            HStack {
                Button(action: {
                    isVisible = false
                    PersistentStore.shared.save(Int(enteredValue), forKey: StoreKeys.hourlyRate.rawValue)
                }) {
                    Text("Save")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.black)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    isVisible = false
                }) {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.black)
                        .background(Color.gray.opacity(0.5))
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 10)
        .padding(40)
    }
}
