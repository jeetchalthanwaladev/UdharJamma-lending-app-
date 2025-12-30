import Foundation

extension TransactionEntity {

    /// Sorted payments array (newest first)
    var paymentsArray: [PaymentEntity] {
        let set = payments as? Set<PaymentEntity> ?? []
        return set.sorted {
            ($0.date ?? Date()) > ($1.date ?? Date())
        }
    }
}



