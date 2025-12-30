import Foundation
import CoreData

extension TransactionEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TransactionEntity> {
        NSFetchRequest<TransactionEntity>(entityName: "Transaction")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var amount: Double
    @NSManaged public var type: String?
    @NSManaged public var date: Date?
    @NSManaged public var returnDate: Date?
    @NSManaged public var interestRate: Double
    @NSManaged public var interestType: String?
    @NSManaged public var termMonths: Int16
    @NSManaged public var interestAmount: Double
    @NSManaged public var totalWithInterest: Double
    @NSManaged public var notes: String?
    @NSManaged public var isClosed: Bool

    // Phase-3
    @NSManaged public var paidAmount: Double
    @NSManaged public var remainingAmount: Double

    // Relationship (MATCHES MODEL)
    @NSManaged public var payment: NSSet?
}

extension TransactionEntity : Identifiable { }
