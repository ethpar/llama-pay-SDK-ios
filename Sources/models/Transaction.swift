import Foundation
public struct TransactionAsset: Codable {
    public let tokenAddress: String?
    public let symbol: String
    public let decimals: Int
    public let image: String?
}

public struct FeeQuote: Codable {
    public let gasLimit: String
    public let maxFeePerGas: String?
    public let maxPriorityFeePerGas: String?
    public let gasPrice: String?
    public let totalWei: String?
}

public struct Signature: Codable {
    public let address: String
    public let signature: String
}

public struct Transaction: Codable {
    public let id: String
    public let assetType: String // "native" | "erc20"
    public let asset: TransactionAsset
    public let amount: String
    public let to: String
    public let walletId: String
    public let initiatorUserId: String?
    public let executorAddress: String?
    public let signatures: [Signature]
    public let status: String // "pending" | "completed" | "failed"
    public let hash: String?
    public let fee: FeeQuote
    public let createdOn: Date
    public let updatedOn: Date
    public let remark: String?
    public let type: String // "normal" | "merchant"

    public let merchant: String?
}

public struct CreateMultisigTransactionRequest: Codable {
    public let walletId: String
    public let assetType: String // "native" | "erc20"
    public let to: String
    public let amount: String
    public let tokenAddress: String?
    public let remark: String?
    public init(walletId: String, assetType: String, to: String, amount: String, tokenAddress: String?, remark: String?) {
        self.walletId = walletId
        self.assetType = assetType
        self.to = to
        self.amount = amount
        self.tokenAddress = tokenAddress
        self.remark = remark
    }
}

public struct AddMultisigTxSignatureRequest: Codable {
    public let txid: String
    public let address: String
    public let signature: String
    public init(txid: String, address: String, signature: String) {
        self.txid = txid
        self.address = address
        self.signature = signature
    }
}

public struct ExecuteTransactionRequest: Codable {
    public let txid: String
    public init(txid: String) {
        self.txid = txid
    }
}
