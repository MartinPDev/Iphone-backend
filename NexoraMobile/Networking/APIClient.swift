import Foundation

enum APIError: LocalizedError {
    case invalidResponse
    case server(String)
    case decoding(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse: "The server returned an invalid response."
        case .server(let message): message
        case .decoding: "The server response could not be read."
        }
    }
}

private struct APIErrorBody: Decodable {
    let detail: String?
    let error: String?
}

actor APIClient {
    static let shared = APIClient()

    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    func send<Response: Decodable>(
        _ path: String,
        method: String = "GET",
        token: String? = nil
    ) async throws -> Response {
        try await send(path, method: method, body: Optional<String>.none, token: token)
    }

    func send<Body: Encodable, Response: Decodable>(
        _ path: String,
        method: String = "POST",
        body: Body?,
        token: String? = nil
    ) async throws -> Response {
        let cleanPath = path.hasPrefix("/") ? String(path.dropFirst()) : path
        var request = URLRequest(url: APIConfig.baseURL.appending(path: cleanPath))
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let body {
            request.httpBody = try encoder.encode(body)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            let message = (try? decoder.decode(APIErrorBody.self, from: data))
                .flatMap { $0.detail ?? $0.error }
                ?? "Request failed with status \(http.statusCode)."
            throw APIError.server(message)
        }

        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }
}

