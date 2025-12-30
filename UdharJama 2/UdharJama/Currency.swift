import Foundation

enum Currency: String, CaseIterable {

    case INR
    case USD
    case EUR
    case GBP
    case AED

    var symbol: String {
        switch self {
        case .INR: return "₹"
        case .USD: return "$"
        case .EUR: return "€"
        case .GBP: return "£"
        case .AED: return "د.إ"
        }
    }

    var rateToINR: Double {
        switch self {
        case .INR: return 1.0
        case .USD: return 83.0
        case .EUR: return 90.0
        case .GBP: return 105.0
        case .AED: return 22.6
        }
    }
}
