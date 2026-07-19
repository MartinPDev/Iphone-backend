import Foundation

struct LoginRequest: Encodable {
    let usernameOrEmail: String
    let password: String

    enum CodingKeys: String, CodingKey {
        case usernameOrEmail = "username_or_email"
        case password
    }
}

struct RegistrationRequest: Encodable {
    let email: String
    let username: String
    let password: String
}

struct TokenResponse: Decodable {
    let accessToken: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}

struct User: Decodable {
    let id: String
    let email: String
    let username: String
    let isActive: Bool?

    enum CodingKeys: String, CodingKey {
        case id, email, username
        case isActive = "is_active"
    }
}

struct Strategy: Codable, Identifiable {
    let id: String
    let name: String
    let symbol: String
    let timeframe: String
    let riskPercent: Double
    let takeProfitPercent: Double?
    let stopLossPercent: Double?
    let isAIEnabled: Bool

    enum CodingKeys: String, CodingKey {
        case id, name, symbol, timeframe
        case riskPercent = "risk_percent"
        case takeProfitPercent = "take_profit_percent"
        case stopLossPercent = "stop_loss_percent"
        case isAIEnabled = "is_ai_enabled"
    }
}

struct StrategyCreate: Encodable {
    let name: String
    let symbol: String
    let timeframe: String
    let riskPercent: Double
    let takeProfitPercent: Double?
    let stopLossPercent: Double?
    let isAIEnabled: Bool
    let configJSON: [String: String] = [:]

    enum CodingKeys: String, CodingKey {
        case name, symbol, timeframe
        case riskPercent = "risk_percent"
        case takeProfitPercent = "take_profit_percent"
        case stopLossPercent = "stop_loss_percent"
        case isAIEnabled = "is_ai_enabled"
        case configJSON = "config_json"
    }
}

struct ExchangeKey: Decodable, Identifiable {
    let id: String
    let exchangeName: String
    let isTestnet: Bool
    let label: String?

    enum CodingKeys: String, CodingKey {
        case id, label
        case exchangeName = "exchange_name"
        case isTestnet = "is_testnet"
    }
}

struct ExchangeKeyCreate: Encodable {
    let exchangeName: String
    let apiKey: String
    let apiSecret: String
    let apiPassphrase: String?
    let isTestnet: Bool
    let label: String?

    enum CodingKeys: String, CodingKey {
        case label
        case exchangeName = "exchange_name"
        case apiKey = "api_key"
        case apiSecret = "api_secret"
        case apiPassphrase = "api_passphrase"
        case isTestnet = "is_testnet"
    }
}

struct TradingBot: Decodable, Identifiable {
    let id: String
    let name: String
    let strategyID: String
    let exchangeKeyID: String
    let status: String
    let isEnabled: Bool
    let lastRunAt: String?
    let lastError: String?

    enum CodingKeys: String, CodingKey {
        case id, name, status
        case strategyID = "strategy_id"
        case exchangeKeyID = "exchange_key_id"
        case isEnabled = "is_enabled"
        case lastRunAt = "last_run_at"
        case lastError = "last_error"
    }
}

struct BotCreate: Encodable {
    let name: String
    let strategyID: String
    let exchangeKeyID: String

    enum CodingKeys: String, CodingKey {
        case name
        case strategyID = "strategy_id"
        case exchangeKeyID = "exchange_key_id"
    }
}

struct BotToggle: Encodable {
    let isEnabled: Bool

    enum CodingKeys: String, CodingKey {
        case isEnabled = "is_enabled"
    }
}

