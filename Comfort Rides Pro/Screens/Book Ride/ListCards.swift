//
//  ListCards.swift
//  Comfort Rides Pro
//
//  Created by Armaan Ahmed on 11/23/23.
//

import SwiftUI
import SquareInAppPaymentsSDK
import SquareBuyerVerificationSDK
import SquareInAppPaymentsSwiftUI

struct ListCards: View {
    
    @State var id: String
    @State var done = false
    @State var cards: [Card] = []
    @Binding var selected: Card?
    @State var shouldPop = false
    @State var inPreview = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
            ZStack {
                List(cards, id: \.self, selection: $selected) { card in
                    CardRow(card: card, selected: $selected, loadCards: loadCards)
                        .listRowBackground(Color(UIColor.secondarySystemGroupedBackground))
                }
                .onChange(of: selected, perform: { value in
                    if let selected = selected {
                        U.setDefaultCard(card: selected.id)
                        if shouldPop { self.presentationMode.wrappedValue.dismiss() } else { F.vibrate(.heavy) }
                    }
                })
                if !done {
                    VStack {
                        ProgressView()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.large)
            .navigationTitle("Payment Methods")
            .toolbar(content: bar)
            .onAppear(perform: viewDidAppear)
    }
    
    func viewDidAppear() {
        if inPreview && !shouldPop {
            loadCards()
        } else {
            cards = V.cards
            done = true
        }
    }
    
    func loadCards() {
        Task {
            do {
                done = false
                try await Task.sleep(nanoseconds: UInt64(0.5 * Double(NSEC_PER_SEC)))
                let customer = try await SquareManager().retrieveUser()
                withAnimation {
                    cards = customer.cards ?? []
                }
                V.cards = customer.cards ?? []
                if cards.count > 0 {
                    selected = U.getDefaultCard(in: cards)
                }
                withAnimation {
                    done = true
                }
            } catch {
                print(error)
                // TODO: Handle error
                done = true
            }
        }
    }
    
    func cardPayAction() {
        sqInit()
        let loc = K.locationId
        
        let contact = SQIPContact()
        let money = SQIPMoney(amount: 1, currency: .USD)
        
        let verifyBuyer = SQIPVerifyBuyerSwiftUI(loc, contact, money)
        
        let theme = SQIPTheme()
        theme.errorColor = .red
        theme.tintColor = .blue
        theme.keyboardAppearance = .light
        theme.messageColor = .black
        theme.saveButtonTitle = "Add Credit/Debit Card"
        
        let paymentHandler = SquarePayment(pCompletion: didAddCard)
        
        SQIP.cardPay.present(theme: theme, verifyBuyer: verifyBuyer, completion: paymentHandler.processCardToken)
     }
    
    func didAddCard(_ id: String) {
        U.setDefaultCard(card: id)
        loadCards()
    }
    
    func sqInit() {
        SQIPInAppPaymentsSDK.squareApplicationID = K.appId
    }
    
    @ToolbarContentBuilder
    func bar() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: cardPayAction, label: {
                HStack {
                    Spacer()
                    Text("Add Credit/Debit Card")
                        .foregroundColor(.white)
                        .bold()
                        .padding(5)
                    Spacer()
                }
                .background(Color.black)
                .cornerRadius(20)
            })
            .disabled(!done)
        }
    }
}

struct CardRow: View {
    
    @State var card: Card
    @Binding var selected: Card?
    @State var showNext = false
    @State var loadCards: (() -> Void)
    
    var body: some View {
        ZStack {
            HStack {
                if !showNext {
                    Menu {
                        Button(role: .destructive, action: disable, label: {
                            HStack {
                                Image(systemName: "trash")
                                Spacer()
                                Text("Disable Card")
                            }
                            .foregroundStyle(Color.red)
                            .foregroundColor(.red)
                        })
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .imageScale(.large)
                    }
                    
                    Spacer().frame(width: 20)

                }
                if card.cardBrand == "OTHER_BRAND" {
                    Image(systemName: "creditcard")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 50)
                        .cornerRadius(10)
                } else {
                    Image(card.cardBrand)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 50)
                        .cornerRadius(shouldRound() ? 10 : 0)
                }
                Spacer()
                Text("•••• \(card.last4)")
                Spacer()
            }
            HStack {
                Spacer()
                if card == selected {
                    Image(systemName: "checkmark.circle.fill")
                        .imageScale(.large)
                        .foregroundStyle(K.darkBlue)
                        .bold()
                }
                if showNext {
                    Image(systemName: "chevron.right")
                        .imageScale(.large)
                        .foregroundStyle(K.darkBlue)
                        .bold()
                }
            }
        }
    }
    
    func shouldRound() -> Bool {
        if card.cardBrand == "DISCOVER_DINERS" { return false }
        return true
    }
    
    func filler(s: String) {}
    
    func disable() {
        if card == selected { selected = nil }
        Task {
            do {
                try await SquarePayment(pCompletion: filler).disableCard(id: card.id)
                loadCards()
            } catch {
                print(error)
                fatalError(error.localizedDescription)
            }
        }
    }
}

#Preview {
    NavigationView {
        ListCards(id: "ZPK8ZKSBMNA2SAD7VTDT8DETK4", selected: Overview_Previews.$ca, inPreview: true)
    }
}
