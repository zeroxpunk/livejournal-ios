import Foundation

struct SherpaOnnxOfflineSpeakerDiarizationSegmentWrapper {
    var start: Float = 0
    var end: Float = 0
    var speaker: Int = 0
}

class SherpaOnnxOfflineSpeakerDiarizationWrapper {
    let impl: OpaquePointer!

    init(
        config: UnsafePointer<SherpaOnnxOfflineSpeakerDiarizationConfig>!
    ) {
        impl = SherpaOnnxCreateOfflineSpeakerDiarization(config)
    }

    deinit {
        if let impl {
            SherpaOnnxDestroyOfflineSpeakerDiarization(impl)
        }
    }

    var sampleRate: Int {
        return Int(SherpaOnnxOfflineSpeakerDiarizationGetSampleRate(impl))
    }

    func setConfig(config: UnsafePointer<SherpaOnnxOfflineSpeakerDiarizationConfig>!) {
        SherpaOnnxOfflineSpeakerDiarizationSetConfig(impl, config)
    }

    func process(samples: [Float]) -> [SherpaOnnxOfflineSpeakerDiarizationSegmentWrapper] {
        guard impl != nil else {
            return []
        }
        
        guard !samples.isEmpty else {
            return []
        }
        
        let result: OpaquePointer? = samples.withUnsafeBufferPointer { samplesPtr in
            guard let baseAddress = samplesPtr.baseAddress else {
                let tempArray = Array(samples)
                return tempArray.withUnsafeBufferPointer { tempPtr in
                    guard let tempBase = tempPtr.baseAddress else {
                        return nil
                    }
                    return SherpaOnnxOfflineSpeakerDiarizationProcess(
                        impl, tempBase, Int32(samples.count))
                }
            }
            
            return SherpaOnnxOfflineSpeakerDiarizationProcess(
                impl, baseAddress, Int32(samples.count))
        }

        if result == nil {
            return []
        }

        let numSegments = Int(SherpaOnnxOfflineSpeakerDiarizationResultGetNumSegments(result))

        let p: UnsafePointer<SherpaOnnxOfflineSpeakerDiarizationSegment>? =
            SherpaOnnxOfflineSpeakerDiarizationResultSortByStartTime(result)

        if p == nil {
            return []
        }

        var ans: [SherpaOnnxOfflineSpeakerDiarizationSegmentWrapper] = []
        for i in 0..<numSegments {
            ans.append(
                SherpaOnnxOfflineSpeakerDiarizationSegmentWrapper(
                    start: p![i].start, end: p![i].end, speaker: Int(p![i].speaker)))
        }

        SherpaOnnxOfflineSpeakerDiarizationDestroySegment(p)
        SherpaOnnxOfflineSpeakerDiarizationDestroyResult(result)

        return ans
    }
}
