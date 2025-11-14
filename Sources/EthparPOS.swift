import Foundation


public struct ApiErrorEnvelope: Codable {
    public let code: String
    public let server_message: String
}

public struct ApiResponse<T: Codable>: Codable {
    public let result: String // "ok" | "error"
    public let error: ApiErrorEnvelope?
    public let data: T
}


public struct SetUserPublicAddressRequest: Codable {
    public let address: String
    public init(address: String) {
        self.address = address
    }
}

public class EthparPOS {
    let baseUrl = "https://api.dev.rampatm.net/ramp"

    public init() {}

    private func makeRequest(path: String, method: String = "GET", body: Data? = nil) throws -> URLRequest {
        guard let url = URL(string: baseUrl + path) else { fatalError("Invalid URL: \(baseUrl + path)") }
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.httpBody = body
        return req
    }

    private func decodeResponse<T: Decodable>(_ data: Data, as type: T.Type) throws -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(T.self, from: data)
    }

    private func perform<T: Decodable>(_ path: String, method: String = "GET", body: Encodable? = nil, responseType: T.Type) async throws -> T {
        let requestBody: Data?
        if let body = body {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            requestBody = try encoder.encode(AnyEncodable(body))
        } else {
            requestBody = nil
        }

        let request = try makeRequest(path: path, method: method, body: requestBody)
        let (data, response) = try await URLSession.shared.data(for: request)
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            if let apiError = try? decodeResponse(data, as: ApiResponse<String>.self),
               apiError.result == "error",
               let err = apiError.error {
                throw NSError(domain: "EthparPOS", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: err.server_message])
            }
            let message = String(data: data, encoding: .utf8) ?? "HTTP \(http.statusCode)"
            throw NSError(domain: "EthparPOS", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: message])
        }
        return try decodeResponse(data, as: T.self)
    }

    private func performVoid(_ path: String, method: String = "POST", body: Encodable? = nil) async throws {
        let requestBody: Data?
        if let body = body {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            requestBody = try encoder.encode(AnyEncodable(body))
        } else {
            requestBody = nil
        }
        let request = try makeRequest(path: path, method: method, body: requestBody)
        let (_, response) = try await URLSession.shared.data(for: request)
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw NSError(domain: "EthparPOS", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: http.description])
        }
    }

    public func generateLoginCode(params: GenerateLoginCodeRequest) async throws {
        try await performVoid("/wallet/login/code", method: "POST", body: params)
    }

    public func confirmLoginCode(params: ConfirmLoginCodeRequest) async throws -> ConfirmLoginCodeResponse {
        // Wrapped response: { result, error, data: { sessionKey } }
        let wrapped: ApiResponse<ConfirmLoginCodeResponse> = try await perform("/wallet/login/confirm", method: "POST", body: params, responseType: ApiResponse<ConfirmLoginCodeResponse>.self)
        return wrapped.data
    }

    public func getCurrentUser() async throws -> User {
        try await perform("/wallet/users/me", responseType: User.self)
    }

    public func setUserPublicAddress(params: SetUserPublicAddressRequest) async throws {
        try await performVoid("/wallet/users/set-address", method: "POST", body: params)
    }

    public func getBalances(address: String, tokens: [TokenQuery]) async throws -> [BalanceResponse] {
        let body = GetBalancesRequest(tokens: tokens)
        return try await perform("/wallet/blockchain/\(address)/get-balance", method: "POST", body: body, responseType: [BalanceResponse].self)
    }

    public func getDefaultTokens() async throws -> [TokenInfo] {
        try await perform("/wallet/blockchain/tokens", responseType: [TokenInfo].self)
    }

    public func getTokenInfo(tokenAddress: String) async throws -> TokenInfo? {
        do {
            let info: TokenInfo = try await perform("/wallet/blockchain/\(tokenAddress)/token-info", responseType: TokenInfo.self)
            return info
        } catch {
            return nil
        }
    }

    public func createMultisigWallet(params: CreateMultisigWalletRequest) async throws -> GeneralMultisigWallet {
        try await perform("/wallet/wallets", method: "POST", body: params, responseType: GeneralMultisigWallet.self)
    }

    public func acceptMultisigWallet(walletId: String) async throws {
        struct AcceptBody: Codable { let walletId: String }
        try await performVoid("/wallet/wallets/\(walletId)/accept", method: "POST", body: AcceptBody(walletId: walletId))
    }

    public func getMultisigWallets() async throws -> [GeneralMultisigWallet] {
        try await perform("/wallet/wallets", responseType: [GeneralMultisigWallet].self)
    }

    public func createMultisigTransaction(params: CreateMultisigTransactionRequest) async throws -> Transaction {
        try await perform("/wallet/tx", method: "POST", body: params, responseType: Transaction.self)
    }

    public func getMultisigWalletTransactions(walletId: String) async throws -> [Transaction] {
        try await perform("/wallet/wallets/\(walletId)/tx", responseType: [Transaction].self)
    }

    public func getMultisigWalletTransaction(txId: String) async throws -> Transaction {
        try await perform("/wallet/tx/\(txId)", responseType: Transaction.self)
    }

    public func addMultisigTxSignature(txId: String, data: AddMultisigTxSignatureRequest) async throws -> Transaction {
        try await perform("/wallet/tx/\(txId)/signature", method: "POST", body: data, responseType: Transaction.self)
    }

    public func executeTransaction(txId: String) async throws -> Transaction {
        let body = ExecuteTransactionRequest(txid: txId)
        return try await perform("/wallet/tx/\(txId)/execute", method: "POST", body: body, responseType: Transaction.self)
    }

    public func getCCWallet() async throws -> CreditCardMultisigWallet? {
        let wallet: CreditCardMultisigWallet = try await perform("/wallet/ccwallet", responseType: CreditCardMultisigWallet.self)
        return wallet
    }

    public func getCCWalletTransactions(walletId: String) async throws -> [Transaction] {
        try await perform("/wallet/ccwallet/\(walletId)/tx", responseType: [Transaction].self)
    }

    public func createCCWallet(params: CreateCCWalletRequest) async throws -> CreditCardMultisigWallet {
        try await perform("/wallet/ccwallet", method: "POST", body: params, responseType: CreditCardMultisigWallet.self)
    }

    public func executePosTransaction(params: ExecutePosTransactionRequest) async throws -> Transaction {
        try await perform("/wallet/tx/pos", method: "POST", body: params, responseType: Transaction.self)
    }

    public func createPosTransaction(data tx: PosTransaction) async throws -> String {
        guard let url = URL(string: "\(baseUrl)/wallet/tx/pos") else {
            fatalError("Invalid URL")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try tx.toJSON()

        let (responseData, response) = try await URLSession.shared.data(for: request)
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            let body = String(data: responseData, encoding: .utf8) ?? "HTTP \(http.statusCode)"
            throw NSError(domain: "EthparPOS", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: body])
        }
        let jsonString = String(data: responseData, encoding: .utf8) ?? "<Invalid UTF-8 data>"
        return jsonString
    }

}

private struct AnyEncodable: Encodable {
    private let encodeFunc: (Encoder) throws -> Void
    init<T: Encodable>(_ value: T) {
        self.encodeFunc = value.encode
    }
    func encode(to encoder: Encoder) throws {
        try encodeFunc(encoder)
    }
}
