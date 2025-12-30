import SwiftUI
import CoreData

struct AddPaymentView: View {

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode

    var tx: TransactionEntity

    // Payment
    @State private var amount: String = ""

    // Currency
    @State private var selectedCurrency: Currency = .INR

    // Alert
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            Form {

                // Remaining (Always INR)
                Section(header: Text("Remaining Amount (INR)")) {
                    Text("₹\(tx.remainingAmount, specifier: "%.2f")")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.red)
                }

                // Currency selection
                Section(header: Text("Currency")) {
                    Picker("Currency", selection: $selectedCurrency) {
                        ForEach(Currency.allCases, id: \.self) { currency in
                            Text("\(currency.symbol) \(currency.rawValue)")
                                .tag(currency)
                        }
                    }
                }

                // Payment amount
                Section(header: Text("Pay Amount")) {
                    TextField(
                        "Enter amount in \(selectedCurrency.rawValue)",
                        text: $amount
                    )
                    .keyboardType(.decimalPad)

                    Text("Converted to INR: ₹\(convertedAmountINR, specifier: "%.2f")")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("Pay Amount")
            .toolbar {

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: savePayment)
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .alert(alertMessage, isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            }
        }
    }

    // MARK: - CONVERSION
    private var convertedAmountINR: Double {
        guard let value = Double(amount) else { return 0 }
        return value * selectedCurrency.rateToINR
    }

    // MARK: - SAVE PAYMENT
    private func savePayment() {

        let inrAmount = convertedAmountINR

        guard inrAmount > 0 else {
            showError("Invalid amount")
            return
        }

        guard inrAmount <= tx.remainingAmount else {
            showError("Amount exceeds remaining balance")
            return
        }

        let payment = PaymentEntity(context: viewContext)
        payment.id = UUID()
        payment.amountPaid = inrAmount
        payment.date = Date()
        payment.transaction = tx

        tx.paidAmount += inrAmount
        tx.remainingAmount -= inrAmount

        if tx.remainingAmount == 0 {
            tx.isClosed = true
            if let id = tx.id {
                NotificationManager.shared.cancelAllReminders(for: id)
            }
        }

        do {
            try viewContext.save()

            // 🔔 Test notification
            NotificationManager.shared.testPaymentReminder(
                name: tx.name ?? "Person",
                amount: inrAmount
            )

            presentationMode.wrappedValue.dismiss()

        } catch {
            showError("Failed to save payment")
        }
    }

    // MARK: - ALERT
    private func showError(_ message: String) {
        alertMessage = message
        showAlert = true
    }
}
