//
// ContentView.swift
//  UdharJama
//
//  Created by BMIIT on 08/11/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        entity: TransactionEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \TransactionEntity.date, ascending: false)],
        animation: .default)
    private var transactions: FetchedResults<TransactionEntity>

    @State private var showAdd = false

    var totalGiven: Double {
        transactions.filter { $0.type == "given" }.reduce(0) { $0 + $1.amount }
    }

    var totalTaken: Double {
        transactions.filter { $0.type == "taken" }.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    VStack {
                        Text("Given")
                            .font(.subheadline)
                        Text("\(totalGiven, specifier: "%.2f")")
                            .font(.title2).bold()
                    }
                    .padding()
                    Spacer()
                    VStack {
                        Text("Taken")
                            .font(.subheadline)
                        Text("\(totalTaken, specifier: "%.2f")")
                            .font(.title2).bold()
                    }
                    .padding()
                }

                List {
                    ForEach(transactions, id: \.objectID) { tx in
                        NavigationLink(destination: TransactionDetailView(tx: tx)) {
                            TransactionRow(tx: tx)
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Udhar Jama")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAdd = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAdd) {
                AddTransactionView(isPresented: $showAdd, existingTransaction: nil)
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { transactions[$0] }.forEach { tx in
                // cancel notifications for deleted items
                if let id = tx.id {
                    NotificationManager.shared.cancelAllReminders(for: id)
                }

                viewContext.delete(tx)
            }
            do {
                try viewContext.save()
            } catch {
                print("Delete failed: \(error)")
            }
        }
    }
}
