import Foundation

class SherpaOnnxSpokenLanguageIdentification {
    private let identifier: OpaquePointer!
    
    init(config: UnsafePointer<SherpaOnnxSpokenLanguageIdentificationConfig>!) {
        identifier = SherpaOnnxCreateSpokenLanguageIdentification(config)
    }
    
    deinit {
        if let identifier {
            SherpaOnnxDestroySpokenLanguageIdentification(identifier)
        }
    }
    
    func identify(samples: [Float], sampleRate: Int = 16000) -> SpokenLanguageIdentificationResult {
        let stream: OpaquePointer! = SherpaOnnxSpokenLanguageIdentificationCreateOfflineStream(identifier)
        
        samples.withUnsafeBufferPointer { samplesPtr in
            SherpaOnnxAcceptWaveformOffline(stream, Int32(sampleRate), samplesPtr.baseAddress, Int32(samples.count))
        }
        
        let result: UnsafePointer<SherpaOnnxSpokenLanguageIdentificationResult>? =
            SherpaOnnxSpokenLanguageIdentificationCompute(identifier, stream)
        
        SherpaOnnxDestroyOfflineStream(stream)
        
        return SpokenLanguageIdentificationResult(result: result)
    }
}

class SpokenLanguageIdentificationResult {
    private let result: UnsafePointer<SherpaOnnxSpokenLanguageIdentificationResult>!
    
    var language: String {
        return String(cString: result.pointee.lang)
    }
    
    init(result: UnsafePointer<SherpaOnnxSpokenLanguageIdentificationResult>!) {
        self.result = result
    }
    
    deinit {
        if let result {
            SherpaOnnxDestroySpokenLanguageIdentificationResult(result)
        }
    }
}
