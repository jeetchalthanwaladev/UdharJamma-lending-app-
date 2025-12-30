import SwiftUI
import CoreData

struct AddTransactionView: View {

    @Environment(\.managedObjectContext) private var viewContext
    @Binding var isPresented: Bool

    var existingTransaction: TransactionEntity?

    @State private var name = ""
    @State private var amount = ""
    @State private var type = "given"
    @State private var date = Date()          // Start Date
    @State private var notes = ""

    // Duration
    @State private var durationType = "days"  // days / months / years
    @State private var durationValue = ""

    // Interest
    @State private var useInterest = false
    @State private var interestRate = ""
    @State private var interestType = "simple"

    // Alert
    @State private var showAlert = false
    @State private var alertMessage = ""

    init(isPresented: Binding<Bool>, existingTransaction: TransactionEntity?) {
        self._isPresented = isPresented
        self.existingTransaction = existingTransaction
    }

    var body: some View {
        NavigationView {
            Form {

                // MARK: - Who
                Section("Who") {
                    TextField("Name", text: $name)
                }

                // MARK: - Amount
                Section("Amount") {
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)

                    Picker("Type", selection: $type) {
                        Text("Given").tag("given")
                        Text("Taken").tag("taken")
                    }
                    .pickerStyle(.segmented)

                    DatePicker("Start Date", selection: $date, displayedComponents: .date)
                }

                // MARK: - Duration
                Section("Duration") {

                    Picker("Duration Type", selection: $durationType) {
                        Text("Days").tag("days")
                        Text("Months").tag("months")
                        Text("Years").tag("years")
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: durationType) { _ in
                        if durationType == "days" {
                            useInterest = false
                        }
                        durationValue = ""
                    }

                    TextField("Enter duration", text: $durationValue)
                        .keyboardType(.numberPad)
                        .onChange(of: durationValue) { _ in
                            validateDuration()
                        }

                    // 🔥 AUTO END DATE DISPLAY
                    if let end = calculatedEndDate {
                        HStack {
                            Text("End Date")
                            Spacer()
                            Text(formattedDate(end))
                                .foregroundColor(.blue)
                        }
                    }
                }

                // MARK: - Interest
                Section("Interest") {

                    Toggle("Apply Interest", isOn: $useInterest)
                        .disabled(durationType == "days")

                    if durationType == "days" {
                        Text("Interest not allowed for Days")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }

                    if useInterest {
                        TextField("Rate (%)", text: $interestRate)
                            .keyboardType(.decimalPad)

                        Picker("Interest Type", selection: $interestType) {
                            Text("Simple").tag("simple")
                            Text("Compound").tag("compound")
                        }
                        .pickerStyle(.segmented)

                        if let preview = calculateInterestPreview() {
                            HStack {
                                Text("Interest / Month")
                                Spacer()
                                Text("₹\(preview.perMonth, specifier: "%.2f")")
                            }

                            HStack {
                                Text("Total Interest")
                                Spacer()
                                Text("₹\(preview.totalInterest, specifier: "%.2f")")
                            }

                            HStack {
                                Text("Final Amount")
                                Spacer()
                                Text("₹\(preview.totalAmount, specifier: "%.2f")")
                                    .bold()
                            }
                        }
                    }
                }

                // MARK: - Notes
                Section("Notes") {
                    TextField("Notes", text: $notes)
                }
            }
            .navigationTitle(existingTransaction == nil ? "Add Transaction" : "Edit Transaction")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: saveTransaction)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                }
            }
            .alert(alertMessage, isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            }
        }
    }

    // MARK: - END DATE CALCULATION
    private var calculatedEndDate: Date? {

        guard let value = Int(durationValue), value > 0 else { return nil }

        let calendar = Calendar.current

        switch durationType {
        case "days":
            return calendar.date(byAdding: .day, value: value, to: date)

        case "months":
            return calendar.date(byAdding: .month, value: value, to: date)

        case "years":
            return calendar.date(byAdding: .year, value: value, to: date)

        default:
            return nil
        }
    }

    // MARK: - VALIDATION
    private func validateDuration() {

        guard let value = Int(durationValue), value > 0 else { return }

        switch durationType {
        case "days":
            if value > 20 {
                showError("Days cannot exceed 20. Select Months.")
                durationValue = ""
            }

        case "months":
            if value > 11 {
                showError("Months cannot exceed 11. Select Years.")
                durationValue = ""
            }

        default:
            break
        }
    }

    // MARK: - INTEREST PREVIEW
    private func calculateInterestPreview()
    -> (perMonth: Double, totalInterest: Double, totalAmount: Double)? {

        guard useInterest,
              durationType != "days",
              let principal = Double(amount),
              let rate = Double(interestRate),
              let months = interestMonths(),
              months > 0 else { return nil }

        let years = Double(months) / 12.0
        let totalInterest: Double

        if interestType == "simple" {
            totalInterest = principal * rate * years / 100
        } else {
            let r = rate / 100
            totalInterest = principal * (pow(1 + r, years) - 1)
        }

        let perMonth = totalInterest / Double(months)
        let finalAmount = principal + totalInterest

        return (perMonth, totalInterest, finalAmount)
    }

    private func interestMonths() -> Int? {
        guard let value = Int(durationValue) else { return nil }

        switch durationType {
        case "months": return value
        case "years": return value * 12
        default: return nil
        }
    }

    // MARK: - SAVE
    private func saveTransaction() {

        guard !name.isEmpty else {
            showError("Please enter name")
            return
        }

        guard let amt = Double(amount), amt > 0 else {
            showError("Invalid amount")
            return
        }

        let tx = existingTransaction ?? TransactionEntity(context: viewContext)

        tx.id = tx.id ?? UUID()
        tx.name = name
        tx.amount = amt
        tx.type = type
        tx.date = date
        tx.notes = notes

        if let preview = calculateInterestPreview(),
           let months = interestMonths() {

            tx.interestRate = Double(interestRate) ?? 0
            tx.interestAmount = preview.totalInterest
            tx.totalWithInterest = preview.totalAmount
            tx.termMonths = Int16(months)
            tx.interestType = interestType

        } else {
            tx.interestRate = 0
            tx.interestAmount = 0
            tx.totalWithInterest = amt
            tx.termMonths = 0
            tx.interestType = nil
        }

        if existingTransaction == nil {
            tx.paidAmount = 0
            tx.remainingAmount = tx.totalWithInterest
        }

        do {
            try viewContext.save()
            isPresented = false
        } catch {
            showError("Failed to save transaction")
        }
    }

    // MARK: - FORMATTER
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    // MARK: - ALERT
    private func showError(_ msg: String) {
        alertMessage = msg
        showAlert = true
    }
}
