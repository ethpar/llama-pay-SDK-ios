public struct BalanceResponse: Codable {
    public let amount: String
    public let tokenAddress: String?
    public let currentPrice: Double
    public let priceChangePercentange24h: Double
}

public struct TokenQuery: Codable {
    public let tokenAddress: String?
    public init(tokenAddress: String?) {
        self.tokenAddress = tokenAddress
    }
}

public struct GetBalancesRequest: Codable {
    public let tokens: [TokenQuery]
    public init(tokens: [TokenQuery]) {
        self.tokens = tokens
    }
}
