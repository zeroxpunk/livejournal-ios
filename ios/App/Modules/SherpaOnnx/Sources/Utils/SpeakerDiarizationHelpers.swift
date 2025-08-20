import Foundation

func sherpaOnnxOfflineSpeakerSegmentationPyannoteModelConfig(model: String)
    -> SherpaOnnxOfflineSpeakerSegmentationPyannoteModelConfig
{
    return SherpaOnnxOfflineSpeakerSegmentationPyannoteModelConfig(model: toCPointer(model))
}

func sherpaOnnxOfflineSpeakerSegmentationModelConfig(
    pyannote: SherpaOnnxOfflineSpeakerSegmentationPyannoteModelConfig,
    numThreads: Int = 1,
    debug: Int = 0,
    provider: String = "cpu"
) -> SherpaOnnxOfflineSpeakerSegmentationModelConfig {
    return SherpaOnnxOfflineSpeakerSegmentationModelConfig(
        pyannote: pyannote,
        num_threads: Int32(numThreads),
        debug: Int32(debug),
        provider: toCPointer(provider)
    )
}

func sherpaOnnxFastClusteringConfig(numClusters: Int = -1, threshold: Float = 0.5)
    -> SherpaOnnxFastClusteringConfig
{
    return SherpaOnnxFastClusteringConfig(num_clusters: Int32(numClusters), threshold: threshold)
}

func sherpaOnnxSpeakerEmbeddingExtractorConfig(
    model: String,
    numThreads: Int = 1,
    debug: Int = 0,
    provider: String = "cpu"
) -> SherpaOnnxSpeakerEmbeddingExtractorConfig {
    return SherpaOnnxSpeakerEmbeddingExtractorConfig(
        model: toCPointer(model),
        num_threads: Int32(numThreads),
        debug: Int32(debug),
        provider: toCPointer(provider)
    )
}

func sherpaOnnxOfflineSpeakerDiarizationConfig(
    segmentation: SherpaOnnxOfflineSpeakerSegmentationModelConfig,
    embedding: SherpaOnnxSpeakerEmbeddingExtractorConfig,
    clustering: SherpaOnnxFastClusteringConfig,
    minDurationOn: Float = 0.3,
    minDurationOff: Float = 0.5
) -> SherpaOnnxOfflineSpeakerDiarizationConfig {
    return SherpaOnnxOfflineSpeakerDiarizationConfig(
        segmentation: segmentation,
        embedding: embedding,
        clustering: clustering,
        min_duration_on: minDurationOn,
        min_duration_off: minDurationOff
    )
}
