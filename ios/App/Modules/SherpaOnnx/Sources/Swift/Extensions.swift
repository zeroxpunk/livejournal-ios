import AVFoundation

extension AudioBuffer {
    func array() -> [Float]? {
        guard let data = self.mData else { return nil }
        let count = Int(self.mDataByteSize) / MemoryLayout<Float>.size
        let bufferPointer = UnsafeBufferPointer<Float>(
            start: data.assumingMemoryBound(to: Float.self),
            count: count
        )
        return Array(bufferPointer)
    }
}

extension AVAudioPCMBuffer {
    func array() -> [Float]? {
        return self.audioBufferList.pointee.mBuffers.array()
    }
}
