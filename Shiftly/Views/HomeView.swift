//
//  ContentView.swift
//  Shiftly
//
//  Created by Srujan Simha Adicharla on 1/24/25.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @State private var selectedDate = Date()
    @State private var startHour = 12
    @State private var startMinute = 30
    @State private var startPeriod = "AM"
    @State private var endHour = 12
    @State private var endMinute = 30
    @State private var endPeriod = "AM"
    @State private var perHrRate: Int = 0
    @State private var currentMonthHours: Int = 0
    @State private var totalHours: Int = 0
    @State private var currentDateShiftEntry: ShiftEntryItem?
    @State private var showHourlyRatePopup = false
    @State private var enteredHourlyRate = ""
    @State private var startTime = Date()
    @State private var endTime = Date()
    @State private var showPopup = false
    
    var body: some View {
        ScrollView {
            ZStack {
                VStack {
                    hourlyRateButton
                    
                    datePicker
                    
                    Spacer().frame(height: 20)
                    
                    HStack(spacing: 10) {
                        startTimeView
                        
                        endTimeView
                        
                        saveEntryButton
                            .padding(.top, 30)
                            .padding(.leading, 25)
                    }
                    
                    Spacer().frame(height: 10)
                    
                    hoursView
                    
                    Spacer().frame(height: 10)
                    
                    settleButton
                        .padding(.horizontal, 20)
                    
                    Spacer()
                }
                .padding()
                .blur(radius: showHourlyRatePopup ? 3 : 0)
                
                if showHourlyRatePopup {
                    Color.black.opacity(0.5)
                        .edgesIgnoringSafeArea(.all)
                    
                    PopupView(isVisible: $showHourlyRatePopup, enteredValue: $enteredHourlyRate)
                }
            }
            .animation(.easeInOut, value: showHourlyRatePopup)
        }
        .onAppear {
            perHrRate = PersistentStore.shared.retrieve(Int.self, forKey: StoreKeys.hourlyRate.rawValue) ?? 0
            recalculateMonthTotals(for: selectedDate)
        }
        .onChange(of: selectedDate) { _, newValue in
            recalculateMonthTotals(for: newValue)
            
            if let shiftEntry = PersistentStore.shared.retrieve(ShiftEntryItem.self, forKey: formattedDate(newValue)) {
                self.currentDateShiftEntry = shiftEntry
                updateTimePickers(from: shiftEntry)
            } else {
                resetTimePickers()
            }
        }
        .onChange(of: enteredHourlyRate) { _, newValue in
            perHrRate = Int(newValue) ?? 0
        }
        .alert(isPresented: $showPopup) {
            Alert(
                title: Text("Settle this month pay"),
                message: Text("Do you want to proceed?"),
                primaryButton: .default(Text("Yes")) {
                    settleThisMonth()
                },
                secondaryButton: .cancel(Text("No")) {}
            )
        }
    }
}

extension HomeView {
    var hourlyRateButton: some View {
        HStack {
            Spacer()
            Button {
                showHourlyRatePopup = true
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "dollarsign.circle.fill")
                        .tint(.gray)
                    Text(" \(perHrRate)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    Text("/hr")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.black)
                .cornerRadius(8)
            }
        }
    }
    
    var datePicker: some View {
        DatePicker("",
                   selection: $selectedDate,
                   displayedComponents: [.date])
        .datePickerStyle(GraphicalDatePickerStyle())
        .accentColor(.orange)
        .padding(.bottom, 10)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
    
    var startTimeView: some View {
        VStack {
            Text("Start time")
                .font(.system(size: 16, weight: .bold))
            TimePickerButton(selectedTime: $startTime)
                .padding(.top, 8)
        }
    }
    
    var endTimeView: some View {
        VStack {
            Text("End time")
                .font(.system(size: 16, weight: .bold))
            TimePickerButton(selectedTime: $endTime)
                .padding(.top, 8)
        }
    }
    
    var saveEntryButton: some View {
        Button(action: {
            saveEntry()
        }, label: {
            Text("Save")
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .padding(.horizontal, 10)
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .bold))
                .background(Color.black)
                .cornerRadius(8)
        })
    }
    
    var hoursView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 20) {
                Text("Current Month Hours")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.system(size: 16, weight: .bold))
                Text("\(currentMonthHours) hrs")
                    .font(.system(size: 16, weight: .bold))
                    .frame(alignment: .trailing)
            }
            HStack(spacing: 20) {
                Text("Total Amount")
                    .font(.system(size: 16, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(CurrencyFormatter.convertToCurrency(currentMonthHours * perHrRate))
                    .font(.system(size: 16, weight: .bold))
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(uiColor: UIColor.lightGray), lineWidth: 1)
        )
        .padding()
    }
    
    var settleButton: some View {
        Button(action: {
            showPopup = true
        }, label: {
            Text("Settle this month")
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .padding(.horizontal, 10)
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .bold))
                .background(Color.black)
                .cornerRadius(10)
        })
    }
}


extension HomeView {
    func settleThisMonth() {
        // Reset current month hours and total entries
        currentMonthHours = 0
        PersistentStore.shared.removeAllShiftEntries(forMonth: selectedDate)
    }
    
    func saveEntry() {
        // Calculate hours worked
        let hoursWorked = calculateHoursBetweenDates()
        guard hoursWorked > 0 else { return }

        // Create a shift entry
        let shiftEntry = ShiftEntryItem(
            date: formattedDate(selectedDate),
            startHour: Calendar.current.component(.hour, from: startTime),
            startMinute: Calendar.current.component(.minute, from: startTime),
            startPeriod: startTimePeriod(),
            endHour: Calendar.current.component(.hour, from: endTime),
            endMinute: Calendar.current.component(.minute, from: endTime),
            endPeriod: endTimePeriod(),
            hoursWorked: hoursWorked
        )

        // Save to persistent store
        PersistentStore.shared.save(shiftEntry, forKey: formattedDate(selectedDate))

        // Update monthly hours
        updateMonthlyHours()
    }
    
    func calculateHoursBetweenDates() -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour], from: startTime, to: endTime)
        return max(0, components.hour ?? 0)
    }
    
    func updateMonthlyHours() {
        currentMonthHours = PersistentStore.shared
            .getAllShiftEntries(forMonth: selectedDate)
            .reduce(0) { $0 + $1.hoursWorked }
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    func formattedDateToDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.date(from: dateString)
    }

    func startTimePeriod() -> String {
        Calendar.current.component(.hour, from: startTime) < 12 ? "AM" : "PM"
    }

    func endTimePeriod() -> String {
        Calendar.current.component(.hour, from: endTime) < 12 ? "AM" : "PM"
    }
    
    func updateTimePickers(from shiftEntry: ShiftEntryItem) {
        // Update start time
        startTime = createTime(hour: shiftEntry.startHour, minute: shiftEntry.startMinute, period: shiftEntry.startPeriod)
        
        // Update end time
        endTime = createTime(hour: shiftEntry.endHour, minute: shiftEntry.endMinute, period: shiftEntry.endPeriod)
    }
    
    func resetTimePickers() {
        startTime = Date() // Default to the current time
        endTime = Date()   // Default to the current time
    }

    func createTime(hour: Int, minute: Int, period: String) -> Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.hour = (period == "PM" && hour < 12) ? hour + 12 : (period == "AM" && hour == 12) ? 0 : hour
        components.minute = minute
        return calendar.date(from: components) ?? Date()
    }
}

extension HomeView {
    /// Called when the date is changed in the calendar.
    func recalculateMonthTotals(for date: Date) {
        let savedKeys = PersistentStore.shared.getAllKeys()
        let calendar = Calendar.current
        let selectedMonth = calendar.component(.month, from: date)
        let selectedYear = calendar.component(.year, from: date)
        
        var totalHoursForMonth = 0

        for key in savedKeys {
            if let savedShift = PersistentStore.shared.retrieve(ShiftEntryItem.self, forKey: key),
               let shiftDate = formattedDateToDate(key) {
                let month = calendar.component(.month, from: shiftDate)
                let year = calendar.component(.year, from: shiftDate)
                
                if month == selectedMonth && year == selectedYear {
                    totalHoursForMonth += savedShift.hoursWorked
                }
            }
        }
        
        // Update state for current month hours and total amount
        self.currentMonthHours = totalHoursForMonth
        self.totalHours = totalHoursForMonth
    }
}

#Preview {
    HomeView()
}


struct TimePickerButton: View {
    @Binding var selectedTime: Date
    @State private var showPicker = false
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }
    
    var body: some View {
        Button(action: { showPicker = true }) {
            HStack {
                Text(timeFormatter.string(from: selectedTime))
                Image(systemName: "clock")
            }
            .padding(10)
            .background(Color(.systemGray5))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showPicker) {
            TimeSelectionView(selectedTime: $selectedTime, isPresented: $showPicker)
        }
    }
}

struct TimeSelectionView: View {
    @Binding var selectedTime: Date
    @Binding var isPresented: Bool
    @State private var tempSelectedTime: Date
    
    init(selectedTime: Binding<Date>, isPresented: Binding<Bool>) {
        _selectedTime = selectedTime
        _isPresented = isPresented
        
        // Initialize with nearest 15-minute interval
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: selectedTime.wrappedValue)
        let minute = components.minute ?? 0
        let remainder = minute % 15
        let adjustedMinutes = minute - remainder + (remainder < 8 ? 0 : 15)
        let adjustedDate = calendar.date(bySettingHour: components.hour ?? 0,
                                       minute: adjustedMinutes,
                                       second: 0,
                                       of: selectedTime.wrappedValue) ?? selectedTime.wrappedValue
        
        _tempSelectedTime = State(initialValue: adjustedDate)
    }
    
    var body: some View {
        VStack {
            // Header with Done button
            HStack {
                Spacer()
                Button("Done") {
                    selectedTime = tempSelectedTime
                    isPresented = false
                }
                .font(.headline)
                .padding()
            }
            
            // Time picker
            CustomTimePicker(selectedTime: $tempSelectedTime)
                .pickerStyle(.wheel)
                .labelsHidden()
                .frame(height: 200)
        }
        .presentationDetents([.height(300)])
    }
}

struct CustomTimePicker: View {
    @Binding var selectedTime: Date
    private let times: [Date]
    
    init(selectedTime: Binding<Date>) {
        self._selectedTime = selectedTime
        
        // Generate times array with 15-minute intervals for current date
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: selectedTime.wrappedValue)
        var times = [Date]()
        
        for i in 0..<96 { // 24 hours * 4 intervals per hour
            if let date = calendar.date(byAdding: .minute, value: i * 15, to: startDate) {
                times.append(date)
            }
        }
        self.times = times
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }
    
    var body: some View {
        Picker("Select Time", selection: $selectedTime) {
            ForEach(times, id: \.self) { time in
                Text(timeFormatter.string(from: time))
                    .tag(time)
            }
        }
    }
}
