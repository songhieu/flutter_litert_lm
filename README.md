# Flutter Lite LM

A Flutter plugin for [LiteRT-LM](https://github.com/google-ai-edge/LiteRT-LM) — Google's production-ready, high-performance inference framework for deploying Large Language Models on edge devices.

Run LLMs **on-device** with hardware acceleration (GPU/NPU) directly from your Flutter app.

## Features

- **On-device LLM inference** — no cloud API needed
- **Hardware acceleration** — GPU (OpenCL) and NPU support on Android
- **Multi-modal** — text, image, and audio inputs
- **Streaming** — token-by-token response streaming
- **Tool/function calling** — agentic workflows with model-driven tool use
- **Conversation management** — multi-turn chat with history

## Supported Models

| Model | Status |
|-------|--------|
| Gemma 4 | Supported |
| Gemma 3n | Supported |
| Llama | Supported |
| Phi-4 | Supported |
| Qwen | Supported |
| FunctionGemma | Supported |

## Platform Support

| Platform | Status |
|----------|--------|
| Android | Stable |
| iOS | Pending (LiteRT-LM Swift SDK in development) |

## Installation

```yaml
dependencies:
  flutter_lite_lm:
    git:
      url: https://github.com/songhieutran/flutter_lite_lm.git
```

### Android Setup

Add to your `AndroidManifest.xml` inside `<application>` for GPU support:

```xml
<uses-native-library android:name="libOpenCL.so" android:required="false"/>
<uses-native-library android:name="libvndksupport.so" android:required="false"/>
```

## Quick Start

```dart
import 'package:flutter_lite_lm/flutter_lite_lm.dart';

// 1. Create and initialize engine
final engine = await LiteLmEngine.create(
  LiteLmEngineConfig(
    modelPath: '/path/to/model.litertlm',
    backend: LiteLmBackend.gpu,
  ),
);

// 2. Create a conversation
final conversation = await engine.createConversation(
  LiteLmConversationConfig(
    systemInstruction: 'You are a helpful assistant.',
    samplerConfig: LiteLmSamplerConfig(
      temperature: 0.7,
      topK: 40,
      topP: 0.95,
    ),
  ),
);

// 3. Send a message
final response = await conversation.sendMessage('What is Flutter?');
print(response.text);

// 4. Stream responses
conversation.sendMessageStream('Tell me a story').listen((message) {
  print(message.text); // partial response
});

// 5. Clean up
await conversation.dispose();
await engine.dispose();
```

## Multi-modal Input

```dart
final response = await conversation.sendMultimodalMessage([
  LiteLmContent.text('What do you see in this image?'),
  LiteLmContent.imageFile('/path/to/photo.jpg'),
]);
```

## Tool Calling

```dart
final conversation = await engine.createConversation(
  LiteLmConversationConfig(
    tools: [
      LiteLmTool(
        name: 'get_weather',
        description: 'Get current weather for a city',
        parameters: {
          'type': 'object',
          'properties': {
            'city': {'type': 'string', 'description': 'City name'},
          },
          'required': ['city'],
        },
      ),
    ],
  ),
);

final response = await conversation.sendMessage('What is the weather in Tokyo?');

// Check if model wants to call a tool
if (response.toolCalls.isNotEmpty) {
  final call = response.toolCalls.first;
  print('Tool: ${call.name}, Args: ${call.arguments}');

  // Send tool result back
  final finalResponse = await conversation.sendToolResponse(
    call.name,
    '{"temperature": 22, "condition": "sunny"}',
  );
  print(finalResponse.text);
}
```

## API Reference

### LiteLmEngine

| Method | Description |
|--------|-------------|
| `LiteLmEngine.create(config)` | Load model and create engine |
| `createConversation([config])` | Start a new conversation |
| `countTokens(text)` | Count tokens in text |
| `dispose()` | Release resources |

### LiteLmConversation

| Method | Description |
|--------|-------------|
| `sendMessage(text)` | Send text, get full response |
| `sendMultimodalMessage(contents)` | Send mixed content |
| `sendMessageStream(text)` | Stream response tokens |
| `sendToolResponse(name, result)` | Return tool execution result |
| `dispose()` | Release resources |

### Configuration

- **LiteLmEngineConfig** — `modelPath`, `backend`, `cacheDir`, `visionBackend`, `audioBackend`
- **LiteLmConversationConfig** — `systemInstruction`, `initialMessages`, `samplerConfig`, `tools`, `automaticToolCalling`
- **LiteLmSamplerConfig** — `topK`, `topP`, `temperature`
- **LiteLmBackend** — `cpu`, `gpu`, `npu`

## Getting Models

Download `.litertlm` model files from HuggingFace:

```bash
# Using LiteRT-LM CLI
pip install litert-lm
litert-lm run \
  --from-huggingface-repo=litert-community/gemma-4-E2B-it-litert-lm \
  gemma-4-E2B-it.litertlm \
  --prompt="Hello"
```

Or download directly from HuggingFace litert-community.

## License

MIT
