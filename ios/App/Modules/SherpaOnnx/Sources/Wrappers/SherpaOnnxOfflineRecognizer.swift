import Foundation

class SherpaOnnxOfflineRecognizer {
    let recognizer: OpaquePointer!

    init(
        config: UnsafePointer<SherpaOnnxOfflineRecognizerConfig>!
    ) {
        recognizer = SherpaOnnxCreateOfflineRecognizer(config)
    }

    deinit {
        if let recognizer {
            SherpaOnnxDestroyOfflineRecognizer(recognizer)
        }
    }

    func decode(samples: [Float], sampleRate: Int = 16000) -> SherpaOnnxOfflineRecongitionResult {
        let stream: OpaquePointer! = SherpaOnnxCreateOfflineStream(recognizer)

        samples.withUnsafeBufferPointer { samplesPtr in
            SherpaOnnxAcceptWaveformOffline(stream, Int32(sampleRate), samplesPtr.baseAddress, Int32(samples.count))
        }

        SherpaOnnxDecodeOfflineStream(recognizer, stream)

        let result: UnsafePointer<SherpaOnnxOfflineRecognizerResult>? =
            SherpaOnnxGetOfflineStreamResult(
                stream)

        SherpaOnnxDestroyOfflineStream(stream)

        return SherpaOnnxOfflineRecongitionResult(result: result)
    }
}

class SherpaOnnxOfflineRecongitionResult {
    let result: UnsafePointer<SherpaOnnxOfflineRecognizerResult>!

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
            let timestamps: [Float] = []
            return timestamps
        }
    }

    var lang: String {
        return String(cString: result.pointee.lang)
    }

    var emotion: String {
        return String(cString: result.pointee.emotion)
    }

    var event: String {
        return String(cString: result.pointee.event)
    }

    init(result: UnsafePointer<SherpaOnnxOfflineRecognizerResult>!) {
        self.result = result
    }

    deinit {
        if let result {
            SherpaOnnxDestroyOfflineRecognizerResult(result)
        }
    }
}
