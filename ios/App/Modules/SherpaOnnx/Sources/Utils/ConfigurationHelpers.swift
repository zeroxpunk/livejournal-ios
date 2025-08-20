import Foundation

func toCPointer(_ s: String) -> UnsafePointer<Int8>! {
    let cs = (s as NSString).utf8String
    return UnsafePointer<Int8>(cs)
}

func sherpaOnnxOnlineTransducerModelConfig(
    encoder: String = "",
    decoder: String = "",
    joiner: String = ""
) -> SherpaOnnxOnlineTransducerModelConfig {
    return SherpaOnnxOnlineTransducerModelConfig(
        encoder: toCPointer(encoder),
        decoder: toCPointer(decoder),
        joiner: toCPointer(joiner)
    )
}

func sherpaOnnxOnlineParaformerModelConfig(
    encoder: String = "",
    decoder: String = ""
) -> SherpaOnnxOnlineParaformerModelConfig {
    return SherpaOnnxOnlineParaformerModelConfig(
        encoder: toCPointer(encoder),
        decoder: toCPointer(decoder)
    )
}

func sherpaOnnxOnlineZipformer2CtcModelConfig(
    model: String = ""
) -> SherpaOnnxOnlineZipformer2CtcModelConfig {
    return SherpaOnnxOnlineZipformer2CtcModelConfig(
        model: toCPointer(model)
    )
}

func sherpaOnnxOnlineModelConfig(
    tokens: String,
    transducer: SherpaOnnxOnlineTransducerModelConfig = sherpaOnnxOnlineTransducerModelConfig(),
    paraformer: SherpaOnnxOnlineParaformerModelConfig = sherpaOnnxOnlineParaformerModelConfig(),
    zipformer2Ctc: SherpaOnnxOnlineZipformer2CtcModelConfig =
        sherpaOnnxOnlineZipformer2CtcModelConfig(),
    numThreads: Int = 1,
    provider: String = "cpu",
    debug: Int = 0,
    modelType: String = "",
    modelingUnit: String = "cjkchar",
    bpeVocab: String = "",
    tokensBuf: String = "",
    tokensBufSize: Int = 0
) -> SherpaOnnxOnlineModelConfig {
    return SherpaOnnxOnlineModelConfig(
        transducer: transducer,
        paraformer: paraformer,
        zipformer2_ctc: zipformer2Ctc,
        tokens: toCPointer(tokens),
        num_threads: Int32(numThreads),
        provider: toCPointer(provider),
        debug: Int32(debug),
        model_type: toCPointer(modelType),
        modeling_unit: toCPointer(modelingUnit),
        bpe_vocab: toCPointer(bpeVocab),
        tokens_buf: toCPointer(tokensBuf),
        tokens_buf_size: Int32(tokensBufSize)
    )
}

func sherpaOnnxFeatureConfig(
    sampleRate: Int = 16000,
    featureDim: Int = 80
) -> SherpaOnnxFeatureConfig {
    return SherpaOnnxFeatureConfig(
        sample_rate: Int32(sampleRate),
        feature_dim: Int32(featureDim))
}

func sherpaOnnxOnlineCtcFstDecoderConfig(
    graph: String = "",
    maxActive: Int = 3000
) -> SherpaOnnxOnlineCtcFstDecoderConfig {
    return SherpaOnnxOnlineCtcFstDecoderConfig(
        graph: toCPointer(graph),
        max_active: Int32(maxActive))
}

func sherpaOnnxOnlineRecognizerConfig(
    featConfig: SherpaOnnxFeatureConfig,
    modelConfig: SherpaOnnxOnlineModelConfig,
    enableEndpoint: Bool = false,
    rule1MinTrailingSilence: Float = 2.4,
    rule2MinTrailingSilence: Float = 1.2,
    rule3MinUtteranceLength: Float = 30,
    decodingMethod: String = "greedy_search",
    maxActivePaths: Int = 4,
    hotwordsFile: String = "",
    hotwordsScore: Float = 1.5,
    ctcFstDecoderConfig: SherpaOnnxOnlineCtcFstDecoderConfig = sherpaOnnxOnlineCtcFstDecoderConfig(),
    ruleFsts: String = "",
    ruleFars: String = "",
    blankPenalty: Float = 0.0,
    hotwordsBuf: String = "",
    hotwordsBufSize: Int = 0
) -> SherpaOnnxOnlineRecognizerConfig {
    return SherpaOnnxOnlineRecognizerConfig(
        feat_config: featConfig,
        model_config: modelConfig,
        decoding_method: toCPointer(decodingMethod),
        max_active_paths: Int32(maxActivePaths),
        enable_endpoint: enableEndpoint ? 1 : 0,
        rule1_min_trailing_silence: rule1MinTrailingSilence,
        rule2_min_trailing_silence: rule2MinTrailingSilence,
        rule3_min_utterance_length: rule3MinUtteranceLength,
        hotwords_file: toCPointer(hotwordsFile),
        hotwords_score: hotwordsScore,
        ctc_fst_decoder_config: ctcFstDecoderConfig,
        rule_fsts: toCPointer(ruleFsts),
        rule_fars: toCPointer(ruleFars),
        blank_penalty: blankPenalty,
        hotwords_buf: toCPointer(hotwordsBuf),
        hotwords_buf_size: Int32(hotwordsBufSize)
    )
}

func sherpaOnnxSpokenLanguageIdentificationConfig(
  whisper: SherpaOnnxSpokenLanguageIdentificationWhisperConfig,
  numThreads: Int = 1,
  debug: Int = 0,
  provider: String = "cpu"
) -> SherpaOnnxSpokenLanguageIdentificationConfig {
  return SherpaOnnxSpokenLanguageIdentificationConfig(
    whisper: whisper,
    num_threads: Int32(numThreads),
    debug: Int32(debug),
    provider: toCPointer(provider))
}

func sherpaOnnxSpokenLanguageIdentificationWhisperConfig(
  encoder: String,
  decoder: String,
  tailPaddings: Int = -1
) -> SherpaOnnxSpokenLanguageIdentificationWhisperConfig {
  return SherpaOnnxSpokenLanguageIdentificationWhisperConfig(
    encoder: toCPointer(encoder),
    decoder: toCPointer(decoder),
    tail_paddings: Int32(tailPaddings))
}
