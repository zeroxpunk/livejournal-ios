import Foundation

func sherpaOnnxOfflineTransducerModelConfig(
    encoder: String = "",
    decoder: String = "",
    joiner: String = ""
) -> SherpaOnnxOfflineTransducerModelConfig {
    return SherpaOnnxOfflineTransducerModelConfig(
        encoder: toCPointer(encoder),
        decoder: toCPointer(decoder),
        joiner: toCPointer(joiner)
    )
}

func sherpaOnnxOfflineParaformerModelConfig(
    model: String = ""
) -> SherpaOnnxOfflineParaformerModelConfig {
    return SherpaOnnxOfflineParaformerModelConfig(
        model: toCPointer(model)
    )
}

func sherpaOnnxOfflineNemoEncDecCtcModelConfig(
    model: String = ""
) -> SherpaOnnxOfflineNemoEncDecCtcModelConfig {
    return SherpaOnnxOfflineNemoEncDecCtcModelConfig(
        model: toCPointer(model)
    )
}

func sherpaOnnxOfflineWhisperModelConfig(
    encoder: String = "",
    decoder: String = "",
    language: String = "",
    task: String = "transcribe",
    tailPaddings: Int = -1
) -> SherpaOnnxOfflineWhisperModelConfig {
    return SherpaOnnxOfflineWhisperModelConfig(
        encoder: toCPointer(encoder),
        decoder: toCPointer(decoder),
        language: toCPointer(language),
        task: toCPointer(task),
        tail_paddings: Int32(tailPaddings)
    )
}

func sherpaOnnxOfflineFireRedAsrModelConfig(
    encoder: String = "",
    decoder: String = ""
) -> SherpaOnnxOfflineFireRedAsrModelConfig {
    return SherpaOnnxOfflineFireRedAsrModelConfig(
        encoder: toCPointer(encoder),
        decoder: toCPointer(decoder)
    )
}

func sherpaOnnxOfflineMoonshineModelConfig(
    preprocessor: String = "",
    encoder: String = "",
    uncachedDecoder: String = "",
    cachedDecoder: String = ""
) -> SherpaOnnxOfflineMoonshineModelConfig {
    return SherpaOnnxOfflineMoonshineModelConfig(
        preprocessor: toCPointer(preprocessor),
        encoder: toCPointer(encoder),
        uncached_decoder: toCPointer(uncachedDecoder),
        cached_decoder: toCPointer(cachedDecoder)
    )
}

func sherpaOnnxOfflineTdnnModelConfig(
    model: String = ""
) -> SherpaOnnxOfflineTdnnModelConfig {
    return SherpaOnnxOfflineTdnnModelConfig(
        model: toCPointer(model)
    )
}

func sherpaOnnxOfflineSenseVoiceModelConfig(
    model: String = "",
    language: String = "",
    useInverseTextNormalization: Bool = false
) -> SherpaOnnxOfflineSenseVoiceModelConfig {
    return SherpaOnnxOfflineSenseVoiceModelConfig(
        model: toCPointer(model),
        language: toCPointer(language),
        use_itn: useInverseTextNormalization ? 1 : 0
    )
}

func sherpaOnnxOfflineLMConfig(
    model: String = "",
    scale: Float = 1.0
) -> SherpaOnnxOfflineLMConfig {
    return SherpaOnnxOfflineLMConfig(
        model: toCPointer(model),
        scale: scale
    )
}

func sherpaOnnxOfflineModelConfig(
    tokens: String,
    transducer: SherpaOnnxOfflineTransducerModelConfig = sherpaOnnxOfflineTransducerModelConfig(),
    paraformer: SherpaOnnxOfflineParaformerModelConfig = sherpaOnnxOfflineParaformerModelConfig(),
    nemoCtc: SherpaOnnxOfflineNemoEncDecCtcModelConfig = sherpaOnnxOfflineNemoEncDecCtcModelConfig(),
    whisper: SherpaOnnxOfflineWhisperModelConfig = sherpaOnnxOfflineWhisperModelConfig(),
    tdnn: SherpaOnnxOfflineTdnnModelConfig = sherpaOnnxOfflineTdnnModelConfig(),
    numThreads: Int = 1,
    provider: String = "cpu",
    debug: Int = 0,
    modelType: String = "",
    modelingUnit: String = "cjkchar",
    bpeVocab: String = "",
    teleSpeechCtc: String = "",
    senseVoice: SherpaOnnxOfflineSenseVoiceModelConfig = sherpaOnnxOfflineSenseVoiceModelConfig(),
    moonshine: SherpaOnnxOfflineMoonshineModelConfig = sherpaOnnxOfflineMoonshineModelConfig(),
    fireRedAsr: SherpaOnnxOfflineFireRedAsrModelConfig = sherpaOnnxOfflineFireRedAsrModelConfig()
) -> SherpaOnnxOfflineModelConfig {
    return SherpaOnnxOfflineModelConfig(
        transducer: transducer,
        paraformer: paraformer,
        nemo_ctc: nemoCtc,
        whisper: whisper,
        tdnn: tdnn,
        tokens: toCPointer(tokens),
        num_threads: Int32(numThreads),
        debug: Int32(debug),
        provider: toCPointer(provider),
        model_type: toCPointer(modelType),
        modeling_unit: toCPointer(modelingUnit),
        bpe_vocab: toCPointer(bpeVocab),
        telespeech_ctc: toCPointer(teleSpeechCtc),
        sense_voice: senseVoice,
        moonshine: moonshine,
        fire_red_asr: fireRedAsr
    )
}

func sherpaOnnxOfflineRecognizerConfig(
    featConfig: SherpaOnnxFeatureConfig,
    modelConfig: SherpaOnnxOfflineModelConfig,
    lmConfig: SherpaOnnxOfflineLMConfig = sherpaOnnxOfflineLMConfig(),
    decodingMethod: String = "greedy_search",
    maxActivePaths: Int = 4,
    hotwordsFile: String = "",
    hotwordsScore: Float = 1.5,
    ruleFsts: String = "",
    ruleFars: String = "",
    blankPenalty: Float = 0.0
) -> SherpaOnnxOfflineRecognizerConfig {
    return SherpaOnnxOfflineRecognizerConfig(
        feat_config: featConfig,
        model_config: modelConfig,
        lm_config: lmConfig,
        decoding_method: toCPointer(decodingMethod),
        max_active_paths: Int32(maxActivePaths),
        hotwords_file: toCPointer(hotwordsFile),
        hotwords_score: hotwordsScore,
        rule_fsts: toCPointer(ruleFsts),
        rule_fars: toCPointer(ruleFars),
        blank_penalty: blankPenalty
    )
}
