
public struct GenerateLoginCodeRequest: Codable {
    public let contact: String
    public let password: String?
    public init(contact: String, password: String? = nil) {
        self.contact = contact
        self.password = password
    }
}

public struct ConfirmLoginCodeRequest: Codable {
    public let contact: String
    public let code: String
    public init(contact: String, code: String) {
        self.contact = contact
        self.code = code
    }
}

public struct ConfirmLoginCodeResponse: Codable {
    public let sessionKey: String
}
