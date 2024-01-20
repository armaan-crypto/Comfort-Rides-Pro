import SwiftUI

struct PaymentConfirmationView: View {
    
    @Binding var total: Int
    @Binding var isPresented: Bool
    @Binding var isDone: Bool
    @State private var selectedTipIndex = 0
    @State private var customTip: Double = 0.0
    @State var totalAmount: Double // Assuming you have a total amount to be paid
    @State var shouldShow = false

    @State var tipOptions = [0, 15, 20, 25]

    var body: some View {
        VStack {
            HStack {
                Text("Service Amount + Transaction Fees:")
                    .font(.headline)
                    .padding()
                Spacer()
                Text("$\(totalAmount, specifier: "%.2f")")
            }

            Divider()
            // Tip section
            HStack {
                Text("Select Tip:")
                    .padding()
                Spacer()
            }

            // Segmented control for tip options
            Picker(selection: $selectedTipIndex, label: Text("")) {
                Text("No Tip")
                    .tag(0)
                ForEach(1..<tipOptions.count) { index in
                    Text("\(self.tipOptions[index])%")
                        .tag(index)
                }
                Text("Custom")
                    .tag(tipOptions.count)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .onChange(of: selectedTipIndex) { oldValue in
                withAnimation {
                    shouldShow = (selectedTipIndex == tipOptions.count)
                }
            }

            // Custom tip input
            if shouldShow {
                HStack {
                    Text("Tip Amount: ")
                    Spacer()
                    TextField("Enter Custom Tip", value: $customTip, formatter: NumberFormatter())
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                }
                .padding()
            }

            // Total amount with tip
            HStack {
                Text("Your tip:")
                    .font(.headline)
                    .padding()
                Spacer()
                Text("$\((calculateTotalAmount() - totalAmount), specifier: "%.2f")")
            }
            Divider()
            HStack {
                Text("Total:")
                    .font(.headline)
                    .padding()
                Spacer()
                Text("$\((calculateTotalAmount()), specifier: "%.2f")")
            }
            Divider()
            Button(action: {
                total = Int(calculateTotalAmount() * 100)
                isPresented = false
                isDone = true
            }, label: {
                Text("Pay With Card")
                    .foregroundStyle(Color.white)
                    .bold()
                    .padding()
            })
            .background(K.darkBlue)
            .cornerRadius(30)
            .padding()
            Spacer()
        }
        .padding()
    }

    // Function to calculate total amount with tip
    private func calculateTotalAmount() -> Double {
        if shouldShow { return totalAmount + customTip }
        let selectedTip = selectedTipIndex == tipOptions.count ? customTip : Double(tipOptions[selectedTipIndex])
        let tipPercentage = selectedTip / 100
        let tipValue = totalAmount * tipPercentage
        return totalAmount + tipValue
    }
}

//#Preview {
//    PaymentConfirmationView(totalAmount: 50.0)
//}
