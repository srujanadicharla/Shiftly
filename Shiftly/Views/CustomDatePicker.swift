import SwiftUI

struct CustomStyledDatePicker: View {
    @State private var selectedDate = Date()
    private let markedDates: [Date] = [
        Calendar.current.date(byAdding: .day, value: 2, to: Date())!,
        Calendar.current.date(byAdding: .day, value: 5, to: Date())!,
        Calendar.current.date(byAdding: .day, value: 7, to: Date())!
    ]
    
    var body: some View {
        VStack {
            Text("Selected Date: \(formattedDate(selectedDate))")
                .font(.headline)
                .padding(.bottom, 10)
            
            CustomCalendarView(selectedDate: $selectedDate, markedDates: markedDates)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding()
        }
        .padding()
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct CustomCalendarView: View {
    @Binding var selectedDate: Date
    let markedDates: [Date]
    
    var body: some View {
        VStack(spacing: 10) {
            headerView
            daysOfWeek
            datesGrid
        }
        .padding()
    }
    
    private var headerView: some View {
        HStack {
            Button(action: {
                changeMonth(by: -1)
            }) {
                Image(systemName: "chevron.left")
            }
            
            Spacer()
            
            Text(currentMonthAndYear())
                .font(.headline)
            
            Spacer()
            
            Button(action: {
                changeMonth(by: 1)
            }) {
                Image(systemName: "chevron.right")
            }
        }
    }
    
    private var daysOfWeek: some View {
        let days = Calendar.current.shortWeekdaySymbols
        return HStack {
            ForEach(days, id: \.self) { day in
                Text(day)
                    .font(.subheadline)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    private var datesGrid: some View {
        let days = generateDatesForCurrentMonth()
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
            ForEach(days, id: \.self) { date in
                VStack(spacing: 4) {
                    Text("\(Calendar.current.component(.day, from: date))")
                        .font(.body)
                        .foregroundColor(isSameDay(date1: date, date2: selectedDate) ? .white : .primary)
                        .frame(width: 32, height: 32)
                        .background(isSameDay(date1: date, date2: selectedDate) ? Color.blue : Color.clear)
                        .clipShape(Circle())
                    
                    if markedDates.contains(where: { isSameDay(date1: $0, date2: date) }) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 6, height: 6)
                    }
                }
                .onTapGesture {
                    selectedDate = date
                }
            }
        }
    }
    
    private func generateDatesForCurrentMonth() -> [Date] {
        let calendar = Calendar.current
        guard let monthRange = calendar.range(of: .day, in: .month, for: selectedDate) else { return [] }
        var days = [Date]()
        
        for day in monthRange {
            var components = calendar.dateComponents([.year, .month], from: selectedDate)
            components.day = day
            if let date = calendar.date(from: components) {
                days.append(date)
            }
        }
        
        return days
    }
    
    private func changeMonth(by value: Int) {
        guard let newDate = Calendar.current.date(byAdding: .month, value: value, to: selectedDate) else { return }
        selectedDate = newDate
    }
    
    private func currentMonthAndYear() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedDate)
    }
    
    private func isSameDay(date1: Date, date2: Date) -> Bool {
        Calendar.current.isDate(date1, inSameDayAs: date2)
    }
}

struct CustomStyledDatePicker_Previews: PreviewProvider {
    static var previews: some View {
        CustomStyledDatePicker()
    }
}
