import Foundation

class SherpaOnnxRecognizer {
    let recognizer: OpaquePointer!
    var stream: OpaquePointer!

    init(
        config: UnsafePointer<SherpaOnnxOnlineRecognizerConfig>!
    ) {
        recognizer = SherpaOnnxCreateOnlineRecognizer(config)
        stream = SherpaOnnxCreateOnlineStream(recognizer)
    }

    deinit {
        if let stream {
            SherpaOnnxDestroyOnlineStream(stream)
        }

        if let recognizer {
            SherpaOnnxDestroyOnlineRecognizer(recognizer)
        }
    }

    func acceptWaveform(samples: [Float], sampleRate: Int = 16000) {
        samples.withUnsafeBufferPointer { samplesPtr in
            SherpaOnnxOnlineStreamAcceptWaveform(stream, Int32(sampleRate), samplesPtr.baseAddress, Int32(samples.count))
        }
    }

    func isReady() -> Bool {
        return SherpaOnnxIsOnlineStreamReady(recognizer, stream) == 1 ? true : false
    }

    func decode() {
        SherpaOnnxDecodeOnlineStream(recognizer, stream)
    }

    func getResult() -> SherpaOnnxOnlineRecongitionResult {
        let result: UnsafePointer<SherpaOnnxOnlineRecognizerResult>? = SherpaOnnxGetOnlineStreamResult(
            recognizer, stream)
        return SherpaOnnxOnlineRecongitionResult(result: result)
    }

    func reset(hotwords: String? = nil) {
        guard let words = hotwords, !words.isEmpty else {
            SherpaOnnxOnlineStreamReset(recognizer, stream)
            return
        }

        words.withCString { cString in
            let newStream = SherpaOnnxCreateOnlineStreamWithHotwords(recognizer, cString)
            objc_sync_enter(self)
            SherpaOnnxDestroyOnlineStream(stream)
            stream = newStream
            objc_sync_exit(self)
        }
    }

    func inputFinished() {
        SherpaOnnxOnlineStreamInputFinished(stream)
    }

    func isEndpoint() -> Bool {
        return SherpaOnnxOnlineStreamIsEndpoint(recognizer, stream) == 1 ? true : false
    }
}

class SherpaOnnxOnlineRecongitionResult {
    let result: UnsafePointer<SherpaOnnxOnlineRecognizerResult>!

    var text: String {
        return String(cString: result.pointee.text)
    }

    var count: Int32 {
        return result.pointee.count
    }

    var tokens: [String] {
        if let tokensPointer = result.pointee.tokens_arr {
            var tokens: [String] = []
            for index in 0..<count {
                if let tokenPointer = tokensPointer[Int(index)] {
                    let token = String(cString: tokenPointer)
                    tokens.append(token)
                }
            }
            return tokens
        } else {
            let tokens: [String] = []
            return tokens
        }
    }

    var timestamps: [Float] {
        if let p = result.pointee.timestamps {
            var timestamps: [Float] = []
            for index in 0..<count {
                timestamps.append(p[Int(index)])
            }
            return timestamps
        } else {
            let timestamps: [Float] = []
            return timestamps
        }
    }

    init(result: UnsafePointer<SherpaOnnxOnlineRecognizerResult>!) {
        self.result = result
    }

    deinit {
        if let result {
            SherpaOnnxDestroyOnlineRecognizerResult(result)
        }
    }
}
