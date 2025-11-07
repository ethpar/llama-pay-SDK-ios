import Foundation

public class EthparPOS {
    let baseUrl = "https://api.dev.rampatm.net/ramp"
    
    public init() {}
        
    public func createPosTransaction(data tx: PosTransaction) async throws -> String {
        guard let url = URL(string: "\(baseUrl)/wallet/tx/pos") else {
            fatalError("Invalid URL")
        }
        let encoder = JSONEncoder()
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try tx.toJSON()
        
        
        let (responseData, response) = try await URLSession.shared.data(for: request)
        
//        let decoded = try JSONDecoder().decode(PosTransaction.self, from: responseData)
        let jsonString = String(data: responseData, encoding: .utf8) ?? "<Invalid UTF-8 data>"
        
        return jsonString
    }
}
