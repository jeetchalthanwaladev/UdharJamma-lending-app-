import SwiftUI

struct TransactionRow: View {
    var tx: TransactionEntity

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(tx.name ?? "Unknown")
                    .font(.headline)
                if let d = tx.date {
                    Text(d, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text("₹\(tx.remainingAmount, specifier: "%.2f")")
                    .bold()
                Text("Remaining")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
}
