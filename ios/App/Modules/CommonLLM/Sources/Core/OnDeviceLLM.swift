import Foundation
import MediaPipeTasksGenAI

@MainActor
final class OnDeviceLLM: LLMProtocol {
    private let inference: LlmInference
    private let session: LlmInference.Session
    private let maxTokens: Int
    private let decodeTokenOffset: Int = 256
    
    init(
        model: LLMModel,
        temperature: Float,
        topK: Int,
        topP: Float,
        maxTokens: Int
    ) async throws {
        self.maxTokens = maxTokens
        let modelPath = try await Self.setupModel(model: model)
        
        let options = LlmInference.Options(modelPath: modelPath.path)
        options.maxTokens = maxTokens
        
        do {
            inference = try LlmInference(options: options)
        } catch {
            throw LLMError.initializationFailed(error.localizedDescription)
        }
        
        let sessionOptions = LlmInference.Session.Options()
        sessionOptions.temperature = temperature
        sessionOptions.topk = topK
        sessionOptions.topp = topP
        
        do {
            session = try LlmInference.Session(llmInference: inference, options: sessionOptions)
        } catch {
            throw LLMError.sessionCreationFailed
        }
    }
    
    nonisolated func completions(messages: [Message]) async throws -> String {
        let prompt = formatMessages(messages)
        
        try await MainActor.run {
            try validateContextWindow(prompt: prompt, messageCount: messages.count)
            try session.addQueryChunk(inputText: prompt)
        }
        return try await MainActor.run {
            try session.generateResponse()
        }
    }
    
    nonisolated func completionsStream(messages: [Message]) async throws -> AsyncThrowingStream<String, Error> {
        let prompt = formatMessages(messages)
        
        try await MainActor.run {
            try validateContextWindow(prompt: prompt, messageCount: messages.count)
            try session.addQueryChunk(inputText: prompt)
        }
        return await MainActor.run {
            session.generateResponseAsync()
        }
    }
    
    private func validateContextWindow(prompt: String, messageCount: Int) throws {
        guard let tokenCount = estimateTokenCount(text: prompt, messageCount: messageCount) else {
            throw LLMError.initializationFailed("Failed to estimate token count")
        }
        
        let availableTokens = maxTokens - decodeTokenOffset
        if tokenCount > availableTokens {
            throw LLMError.contextWindowExceeded(current: tokenCount, max: availableTokens)
        }
    }
    
    private func estimateTokenCount(text: String, messageCount: Int) -> Int? {
        guard !text.isEmpty else { return 0 }
        
        do {
            let textTokenCount = try session.sizeInTokens(text: text)
            let approximateControlTokensCount = messageCount * 3
            return textTokenCount + approximateControlTokensCount
        } catch {
            return nil
        }
    }
    
    func estimateTokensRemaining(messages: [Message]) -> Int? {
        let prompt = formatMessages(messages)
        guard let tokenCount = estimateTokenCount(text: prompt, messageCount: messages.count) else {
            return nil
        }
        
        return max(0, maxTokens - decodeTokenOffset - tokenCount)
    }
    
    private nonisolated func formatMessages(_ messages: [Message]) -> String {
        var formatted = ""
        var systemPrompt: String? = nil
        
        for message in messages {
            switch message.role {
            case .system:
                systemPrompt = message.text
            case .user:
                var userText = message.text
                if let system = systemPrompt {
                    userText = "\(system)\n\n\(userText)"
                    systemPrompt = nil
                }
                formatted += "<start_of_turn>user\n\(userText)<end_of_turn>\n"
            case .assistant:
                formatted += "<start_of_turn>model\n\(message.text)<end_of_turn>\n"
            }
        }
        
        formatted += "<start_of_turn>model\n"
        return formatted
    }
    
    private static func setupModel(model: LLMModel) async throws -> URL {
        guard let bundlePath = Bundle.main.path(
            forResource: model.rawValue,
            ofType: "task"
        ) else {
            throw LLMError.modelNotFound(model.fileName)
        }
        
        let cacheDir = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first!
        
        try FileManager.default.createDirectory(
            at: cacheDir,
            withIntermediateDirectories: true
        )
        
        let modelPath = cacheDir.appendingPathComponent(model.fileName)
        
        if !FileManager.default.fileExists(atPath: modelPath.path) {
            try FileManager.default.copyItem(
                atPath: bundlePath,
                toPath: modelPath.path
            )
        }
        
        return modelPath
    }
}
