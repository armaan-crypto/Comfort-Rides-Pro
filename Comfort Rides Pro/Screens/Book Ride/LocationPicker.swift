import SwiftUI
import UIKit

struct MyDatePicker: UIViewRepresentable {

    @Binding var selection: Date
    let minuteInterval: Int
    let displayedComponents: DatePickerComponents
    let onChange: (() -> Void)

    func makeCoordinator() -> Coordinator {
        return Coordinator(self, onChange)
    }

    func makeUIView(context: UIViewRepresentableContext<MyDatePicker>) -> UIDatePicker {
        let picker = UIDatePicker()
        // listen to changes coming from the date picker, and use them to update the state variable
        picker.addTarget(context.coordinator, action: #selector(Coordinator.dateChanged), for: .valueChanged)
        return picker
    }

    func updateUIView(_ picker: UIDatePicker, context: UIViewRepresentableContext<MyDatePicker>) {
        picker.minuteInterval = minuteInterval
        picker.date = selection
        picker.minimumDate = Date().addingTimeInterval(3600)

        switch displayedComponents {
        case .hourAndMinute:
            picker.datePickerMode = .time
        case .date:
            picker.datePickerMode = .date
        case [.hourAndMinute, .date]:
            picker.datePickerMode = .dateAndTime
        default:
            break
        }
        picker.preferredDatePickerStyle = .inline
    }

    class Coordinator {
        let datePicker: MyDatePicker
        let onChange: (() -> Void)
        init(_ datePicker: MyDatePicker, _ o: @escaping (() -> Void)) {
            self.datePicker = datePicker
            onChange = o
        }

        @objc func dateChanged(_ sender: UIDatePicker) {
            DispatchQueue.main.async { [self] in
                datePicker.selection = sender.date
                onChange()
            }
        }
    }
}

struct DatePickerDemo: View {
    @State var wakeUp: Date = Date()
    @State var minterval: Int = 30

    var body: some View {
        VStack {
            
            MyDatePicker(selection: $wakeUp, minuteInterval: minterval, displayedComponents: [.date, .hourAndMinute], onChange: changed)
            Text("\(wakeUp)")
        }
    }
    
    func changed() -> Void {
        print("hello")
    }
}

struct DatePickerDemo_Previews: PreviewProvider {
    static var previews: some View {
        DatePickerDemo()
    }
}
