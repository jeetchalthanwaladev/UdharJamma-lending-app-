import Foundation
import CoreData

extension PaymentEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PaymentEntity> {
        NSFetchRequest<PaymentEntity>(entityName: "Payment")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var amountPaid: Double
    @NSManaged public var date: Date?
    @NSManaged public var transaction: TransactionEntity?
}

extension PaymentEntity : Identifiable { }
