public struct User: Codable {
    public let id: Int
    public let email: String
    public let phone: String?
    public let name: String?
    public let publicAddress: String?
    public let createdOn: String
    public let updatedOn: String
}
