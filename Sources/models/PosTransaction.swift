import Foundation
import SwiftUI

public struct PosTransaction: Codable {
    public let amount: String
    public let destination: String
    public let merchant: String
    public let remark: String
    public let panHash: String
    public let confirmations: Int
    public let assetType: String?
    public let tokenAddress: String?

    public init(
        amount: String,
        destination: String,
        merchant: String,
        remark: String,
        panHash: String,
        confirmations: Int,
        assetType: String? = nil,
        tokenAddress: String? = nil
    ) {
        self.amount = amount
        self.destination = destination
        self.merchant = merchant
        self.remark = remark
        self.panHash = panHash
        self.confirmations = confirmations
        self.assetType = assetType
        self.tokenAddress = tokenAddress
    }

    public func toJSON() throws -> Data {
        let dict: [String: Any?] = [
            "amount": amount,
            "destination": destination,
            "merchant": merchant,
            "remark": remark,
            "panHash": panHash,
            "confirmations": confirmations,
            "assetType": assetType ?? NSNull(),
            "tokenAddress": tokenAddress ?? NSNull()
        ]
        return try JSONSerialization.data(withJSONObject: dict, options: [])
    }
}

public struct ExecutePosTransactionRequest: Codable {
    public let destination: String
    public let panHash: String
    public let amount: String
    public let remark: String?
    public let merchant: String
    public let confirmations: Int?
    public init(destination: String, panHash: String, amount: String, remark: String?, merchant: String, confirmations: Int?) {
        self.destination = destination
        self.panHash = panHash
        self.amount = amount
        self.remark = remark
        self.merchant = merchant
        self.confirmations = confirmations
    }
}
