import AVFoundation
import Foundation

public struct DefaultAudioProcessor: AudioProcessorProtocol {
    public init() {}
    
    public func loadAudio(from url: URL) async throws -> AudioData {
        let audioFile = try AVAudioFile(forReading: url)
        let format = audioFile.processingFormat
        let frameCount = AVAudioFrameCount(audioFile.length)
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            throw SherpaError.invalidAudioFormat
        }
        
        try audioFile.read(into: buffer)
        
        let samples = await extractMonoSamples(from: buffer)
        return AudioData(samples: samples, sampleRate: Int(format.sampleRate))
    }
    
    public func resample(_ audio: AudioData, to targetSampleRate: Int) async -> AudioData {
        if audio.sampleRate == targetSampleRate {
            return audio
        }
        
        let ratio = Double(targetSampleRate) / Double(audio.sampleRate)
        let outputLength = Int(Double(audio.samples.count) * ratio)
        var resampled = [Float](repeating: 0, count: outputLength)
        
        for i in 0..<outputLength {
            let sourceIndex = Double(i) / ratio
            let index = Int(sourceIndex)
            let fraction = Float(sourceIndex - Double(index))
            
            if index < audio.samples.count - 1 {
                resampled[i] = audio.samples[index] * (1 - fraction) + audio.samples[index + 1] * fraction
            } else if index < audio.samples.count {
                resampled[i] = audio.samples[index]
            }
        }
        
        return AudioData(samples: resampled, sampleRate: targetSampleRate)
    }
    
    private func extractMonoSamples(from buffer: AVAudioPCMBuffer) async -> [Float] {
        let format = buffer.format
        let frameLength = Int(buffer.frameLength)
        
        guard let floatChannelData = buffer.floatChannelData else {
            return []
        }
        
        var samples: [Float] = []
        
        if format.channelCount == 1 {
            for i in 0..<frameLength {
                samples.append(floatChannelData[0][i])
            }
        } else {
            for i in 0..<frameLength {
                var sum: Float = 0
                for channel in 0..<Int(format.channelCount) {
                    sum += floatChannelData[channel][i]
                }
                samples.append(sum / Float(format.channelCount))
            }
        }
        
        return samples
    }
}
