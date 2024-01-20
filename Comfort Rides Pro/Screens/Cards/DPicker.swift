//
//  DPicker.swift
//  Comfort Rides Pro
//
//  Created by Armaan Ahmed on 1/20/24.
//

import SwiftUI

struct DPicker: View {
    
    @State var c = #colorLiteral(red: 0.9372547865, green: 0.9372549653, blue: 0.9415605664, alpha: 1)
    @State var selectedDate = Date()
    @State var time = ""
    @Binding var ovrDate: Date
    
    var body: some View {
        VStack {
            DatePicker("", selection: $selectedDate, in: addHourRoundUp()..., displayedComponents: [.date])
                .labelsHidden()
                .datePickerStyle(.graphical)
                .onChange(of: selectedDate) { oldValue, newValue in
                    let d = dc([.hour], from: ovrDate)
                    var selected = Calendar.current.dateComponents(in: TimeZone.current, from: selectedDate)
                    selected.hour = d.hour!
                    selected.minute = 0
                    selected.second = 0
                    selected.nanosecond = 0
                    ovrDate = Calendar.current.date(from: selected)!
                }
            HStack {
                Spacer()
                ZStack {
                    Picker("Time", selection: $time) {
                        ForEach(times(), id: \.self) { t in
                            Text(t)
                        }
                    }
                    .onChange(of: time) { oldValue, newValue in
                        var selected = Calendar.current.dateComponents(in: TimeZone.current, from: ovrDate)
                        selected.hour = getHourFromString(s: newValue)
                        selected.minute = 0
                        selected.second = 0
                        selected.nanosecond = 0
                        ovrDate = Calendar.current.date(from: selected)!
                    }
                }
                .background(Color(uiColor: c))
                .cornerRadius(20)
            }
        }
        .onAppear(perform: {
            if times().count > 0 {
                time = times()[0]
            }
        })
    }
    
    func getHourFromString(s: String) -> Int {
        if s == "12am" { return 0 }
        if s == "12pm" { return 12 }
        if s.contains("am") {
            return Int(s.split(separator: "am")[0])!
        } else {
            return Int(s.split(separator: "pm")[0])! + 12
        }
    }
    
    func addHourRoundUp() -> Date {
        // hours: 0-5am, 4pm-11am
        var date = Calendar.current.date(byAdding: .hour, value: 1, to: Date())
        let toAdd = 60 - dc([.minute], from: date ?? Date()).minute!
        date = Calendar.current.date(byAdding: .minute, value: toAdd, to: date ?? Date())
        return date ?? Date()
    }
    
    func times() -> [String] {
        let hoursInts = [0, 1, 2, 3, 4, 5, 16, 17, 18, 19, 20, 21, 22, 23]
        var hours: [String] = []
        for h in hoursInts {
            if h == 0 { hours.append("12am") }
            else if h == 12 { hours.append("12pm") }
            else {
                if floor(Double(h / 12)) == 1 {
                    hours.append(String(h % 12) + "pm")
                } else {
                    hours.append(String(h) + "am")
                }
            }
        }
        let d = addHourRoundUp()
        if !isSameDay(one: d, two: selectedDate) { return hours }
        
        let h = dc([.hour], from: d).hour!
        if hoursInts.contains(h) {
            let i = hoursInts.firstIndex(of: h)!
            let hs = Array(hours[i..<hours.count])
            return hs
        } else { return Array(hours[6..<hours.count]) }
    }
    
    func isSameDay(one: Date, two: Date) -> Bool {
        let oneComps = dc([.day, .month, .year], from: one)
        let twoComps = dc([.day, .month, .year], from: two)
        guard oneComps.year! == twoComps.year! else { return false }
        guard oneComps.month! == twoComps.month! else { return false }
        guard oneComps.day! == twoComps.day! else { return false }
        return true
    }
    
    func dc(_ comps: Set<Calendar.Component>, from: Date) -> DateComponents {
        return Calendar.current.dateComponents(comps, from: from)
    }
}
