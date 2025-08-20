import Foundation

class SherpaOnnxOnlineRecognizer {
    private let recognizer: OpaquePointer!
    
    init(config: UnsafePointer<SherpaOnnxOnlineRecognizerConfig>!) {
        recognizer = SherpaOnnxCreateOnlineRecognizer(config)
    }
    
    deinit {
        if let recognizer {
            SherpaOnnxDestroyOnlineRecognizer(recognizer)
        }
    }
    
    func createStream() -> SherpaOnnxOnlineStream {
        let streamPtr = SherpaOnnxCreateOnlineStream(recognizer)
        return SherpaOnnxOnlineStream(stream: streamPtr!, recognizer: recognizer)
    }
}

class SherpaOnnxOnlineStream {
    private let stream: OpaquePointer!
    private let recognizer: OpaquePointer!
    
    init(stream: OpaquePointer, recognizer: OpaquePointer) {
        self.stream = stream
        self.recognizer = recognizer
    }
    
    deinit {
        if let stream {
            SherpaOnnxDestroyOnlineStream(stream)
        }
    }
    
    func acceptWaveform(samples: [Float], sampleRate: Int = 16000) {
        samples.withUnsafeBufferPointer { samplesPtr in
            SherpaOnnxOnlineStreamAcceptWaveform(stream, Int32(sampleRate), samplesPtr.baseAddress, Int32(samples.count))
        }
    }
    
    func inputFinished() {
        SherpaOnnxOnlineStreamInputFinished(stream)
    }
    
    var isReady: Bool {
        return SherpaOnnxIsOnlineStreamReady(recognizer, stream) != 0
    }
    
    var isEndpoint: Bool {
        return SherpaOnnxOnlineStreamIsEndpoint(recognizer, stream) != 0
    }
    
    func decode() {
        SherpaOnnxDecodeOnlineStream(recognizer, stream)
    }
    
    func reset() {
        SherpaOnnxOnlineStreamReset(recognizer, stream)
    }
    
    var result: SherpaOnnxOnlineRecognitionResult {
        let resultPtr = SherpaOnnxGetOnlineStreamResult(recognizer, stream)
        return SherpaOnnxOnlineRecognitionResult(result: resultPtr)
    }
}

class SherpaOnnxOnlineRecognitionResult {
    private let result: UnsafePointer<SherpaOnnxOnlineRecognizerResult>!
    
    var text: String {
        return String(cString: result.pointee.text)
    }
    
    var count: Int32 {
        return result.pointee.count
    }
    
    var timestamps: [Float] {
        if let p = result.pointee.timestamps {
            var timestamps: [Float] = []
            for index in 0..<count {
                timestamps.append(p[Int(index)])
            }
            return timestamps
        } else {
            return []
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
