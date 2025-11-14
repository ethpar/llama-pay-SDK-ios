public struct TokenInfo: Codable {
    public let tokenAddress: String?
    public let imageUrl: String
    public let token: TokenInfoToken

    public struct TokenInfoToken: Codable {
        public let name: String
        public let decimals: Int
        public let symbol: String
    }
}
