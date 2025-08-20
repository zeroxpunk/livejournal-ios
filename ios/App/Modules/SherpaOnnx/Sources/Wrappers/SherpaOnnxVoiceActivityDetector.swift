import Foundation

class SherpaOnnxSpeechSegmentWrapper {
    let p: UnsafePointer<SherpaOnnxSpeechSegment>!

    init(p: UnsafePointer<SherpaOnnxSpeechSegment>!) {
        self.p = p
    }

    deinit {
        if let p {
            SherpaOnnxDestroySpeechSegment(p)
        }
    }

    var start: Int {
        return Int(p.pointee.start)
    }

    var n: Int {
        return Int(p.pointee.n)
    }

    var samples: [Float] {
        var samples: [Float] = []
        for index in 0..<n {
            samples.append(p.pointee.samples[Int(index)])
        }
        return samples
    }
}

class SherpaOnnxVoiceActivityDetectorWrapper {
    let vad: OpaquePointer!

    init(config: UnsafePointer<SherpaOnnxVadModelConfig>!, buffer_size_in_seconds: Float) {
        vad = SherpaOnnxCreateVoiceActivityDetector(config, buffer_size_in_seconds)
    }

    deinit {
        if let vad {
            SherpaOnnxDestroyVoiceActivityDetector(vad)
        }
    }

    func acceptWaveform(samples: [Float]) {
        samples.withUnsafeBufferPointer { samplesPtr in
            SherpaOnnxVoiceActivityDetectorAcceptWaveform(vad, samplesPtr.baseAddress, Int32(samples.count))
        }
    }

    func isEmpty() -> Bool {
        return SherpaOnnxVoiceActivityDetectorEmpty(vad) == 1
    }

    func isSpeechDetected() -> Bool {
        return SherpaOnnxVoiceActivityDetectorDetected(vad) == 1
    }

    func pop() {
        SherpaOnnxVoiceActivityDetectorPop(vad)
    }

    func clear() {
        SherpaOnnxVoiceActivityDetectorClear(vad)
    }

    func front() -> SherpaOnnxSpeechSegmentWrapper {
        let p: UnsafePointer<SherpaOnnxSpeechSegment>? = SherpaOnnxVoiceActivityDetectorFront(vad)
        return SherpaOnnxSpeechSegmentWrapper(p: p)
    }

    func reset() {
        SherpaOnnxVoiceActivityDetectorReset(vad)
    }

    func flush() {
        SherpaOnnxVoiceActivityDetectorFlush(vad)
    }
}
