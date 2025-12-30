import SwiftUI
import CoreData

struct TransactionDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var tx: TransactionEntity


    @State private var showPay = false

    var payments: [PaymentEntity] {
        let set = tx.payment as? Set<PaymentEntity> ?? []
        return set.sorted { ($0.date ?? Date()) > ($1.date ?? Date()) }
    }

    var body: some View {
        Form {

            Section("Summary") {
                Text("Total: ₹\(tx.totalWithInterest, specifier: "%.2f")")
                Text("Paid: ₹\(tx.paidAmount, specifier: "%.2f")")
                Text("Remaining: ₹\(tx.remainingAmount, specifier: "%.2f")")
                    .foregroundColor(.red)
            }

            if !payments.isEmpty {
                Section("Payment History") {
                    ForEach(payments) { p in
                        HStack {
                            Text(p.date ?? Date(), style: .date)
                            Spacer()
                            Text("₹\(p.amountPaid, specifier: "%.2f")")
                        }
                    }
                }
            }
        }
        .navigationTitle("Details")
        .toolbar {
            Button("Pay") {
                showPay = true
            }
        }
        .sheet(isPresented: $showPay) {
            AddPaymentView(tx: tx)
                .environment(\.managedObjectContext, viewContext)
        }
    }
}
