public struct Signer: Codable {
    public let id: String
    public let address: String
    public let userId: String?
    public let acceptedOn: Date?
}

public struct MultisigWalletCore: Codable {
    public let address: String
    public let m: Int
    public let n: Int
    public let executorAddress: String?
    public let signers: [Signer]
    public let creationHash: String?
}

public struct BaseMultisigWallet: Codable {
    public let id: String
    public let name: String
    public let userId: String
    public let wallet: MultisigWalletCore
    public let createdOn: Date
}

public struct CreditCardMultisigWallet: Codable {
    public let id: String
    public let name: String
    public let userId: String
    public let wallet: MultisigWalletCore
    public let createdOn: Date

    public let panLastDigits: String
    public let panHash: String
    public let binHash: String
    public let binInfo: BinInfo?
    public let type: String // "credit-card"
}

public struct BinInfo: Codable {
    public let scheme: String?
    public let brand: String?
    public let type: String?
    public let country: String?
}


public struct GeneralMultisigWallet: Codable {
    public let id: String
    public let name: String
    public let userId: String
    public let wallet: MultisigWalletCore
    public let createdOn: Date

    public let creatorId: String
    public let type: String // "general"
    public let signerIds: [String?]
    public let signerAddresses: [String]
}

public struct CreateMultisigWalletRequest: Codable {
    public let name: String
    public let signers: [String]
    public let threshold: Int
    public init(name: String, signers: [String], threshold: Int) {
        self.name = name
        self.signers = signers
        self.threshold = threshold
    }
}

public struct CreateCCWalletRequest: Codable {
    public let pan: String
    public init(pan: String) {
        self.pan = pan
    }
}

