# Changelog

All notable changes to `flutter_litert_lm` are documented in this file. The
format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and
this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [0.1.0] — 2026-04-10

Initial public release.

### Added
- Android support targeting `com.google.ai.edge.litertlm:litertlm-android:0.10.0`.
- `LiteLmEngine` for loading `.litertlm` model files with CPU, GPU (OpenCL),
  or NPU backends.
- `LiteLmConversation` for multi-turn chat with system instructions, sampler
  config, optional tools, and initial-message seeding.
- `sendMessage` for full responses and `sendMessageStream` for token-by-token
  streaming.
- Multimodal `sendMultimodalMessage` for text + image + audio inputs.
- Tool / function calling via `LiteLmTool` and `sendToolResponse`.
- Consumer Proguard / R8 keep rules shipped with the AAR so release builds
  don't strip the LiteRT-LM JNI surface.
- `<uses-native-library>` manifest entries merged into the host app for
  `libOpenCL.so` (Qualcomm Adreno), `libOpenCL-pixel.so` (Pixel Tensor), and
  `libOpenCL-car.so` (Android Auto) so the GPU backend works on Android 12+.
- Example app with model picker, on-device download with progress, backend
  selector, streaming chat, and per-response inference stats
  (tokens, tok/s, time-to-first-token, total duration).

### Known limitations
- iOS bridge is currently a stub — Google's LiteRT-LM Swift SDK is still in
  development. Method-channel calls return `UNSUPPORTED` until upstream ships.
- `countTokens` returns `-1` because token counting is not yet exposed by the
  upstream public API.
- Streaming downloads do not yet resume on network interruption — they
  restart from byte zero on retry.
