import Foundation

public struct LLMFactory {
    private init() {}
    
    public static func gemma3(
        model: LLMModel = .gemma2B,
        temperature: Float = 0.9,
        topK: Int = 40,
        topP: Float = 0.95,
        maxTokens: Int = 1000
    ) async throws -> LLMProtocol {
        try await OnDeviceLLM(
            model: model,
            temperature: temperature,
            topK: topK,
            topP: topP,
            maxTokens: maxTokens
        )
    }
    
    public static var availableModels: [LLMModel] {
        LLMModel.allCases.filter {
            Bundle.main.path(forResource: $0.rawValue, ofType: "task") != nil
        }
    }
}
