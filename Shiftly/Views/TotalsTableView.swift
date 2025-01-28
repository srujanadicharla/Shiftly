////
////  TotalsTableView.swift
////  Shiftly
////
////  Created by Srujan Simha Adicharla on 1/25/25.
////
//
//import SwiftUI
//
//struct TableView: View {
//    
//    @Binding var thisMonthHours: Int
//    @Binding var totalHours: Int
//    @State private var perHrRate: Int
//    
//    init(thisMonthHours: Binding<Int>, totalHours: Binding<Int>, perHrRate: Int) {
//        _thisMonthHours = thisMonthHours
//        _totalHours = totalHours
//        self.perHrRate = perHrRate
//    }
//    
//    var body: some View {
//        VStack(spacing: 20) {
//            VStack(spacing: 5) {
//                // Row 1
//                HStack(spacing: 5) {
//                    Text("This Month")
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(Color.blue.opacity(0.1))
//                        .cornerRadius(5)
//                    
//                    Text("Total")
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(Color.blue.opacity(0.1))
//                        .cornerRadius(5)
//                }
//
//                // Row 2
//                HStack(spacing: 5) {
//                    Text("\(thisMonthHours)")
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(Color.gray.opacity(0.1))
//                        .cornerRadius(5)
//                    
//                    Text("\(totalHours)")
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(Color.gray.opacity(0.1))
//                        .cornerRadius(5)
//                }
//                
//                // Row 3
//                HStack(spacing: 5) {
//                    Text(CurrencyFormatter.convertToCurrency(cents: thisMonthHours * perHrRate))
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(Color.gray.opacity(0.1))
//                        .cornerRadius(5)
//                    
//                    Text(CurrencyFormatter.convertToCurrency(cents: totalHours * perHrRate))
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(Color.gray.opacity(0.1))
//                        .cornerRadius(5)
//                }
//            }
//            .padding()
//        }
//    }
//}
//
//struct TableView_Previews: PreviewProvider {
//    static var previews: some View {
//        TableView(thisMonthHours: .constant(0), totalHours: .constant(0), perHrRate: 0)
//    }
//}
//
