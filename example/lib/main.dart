import 'package:flutter/material.dart';
import 'package:flutter_lite_lm/flutter_lite_lm.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Lite LM Demo',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <_ChatMessage>[];

  LiteLmEngine? _engine;
  LiteLmConversation? _conversation;
  bool _isLoading = false;
  bool _isInitialized = false;
  String _statusMessage = 'Not initialized';

  @override
  void dispose() {
    _conversation?.dispose();
    _engine?.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeEngine() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Loading model...';
    });

    try {
      // TODO: Update this path to your actual model file location on device.
      // Download models from HuggingFace, e.g.:
      //   litert-community/gemma-4-E2B-it-litert-lm
      final modelPath = '/sdcard/Download/model.litertlm';

      _engine = await LiteLmEngine.create(
        LiteLmEngineConfig(
          modelPath: modelPath,
          backend: LiteLmBackend.gpu,
        ),
      );

      _conversation = await _engine!.createConversation(
        LiteLmConversationConfig(
          systemInstruction: 'You are a helpful assistant. Be concise.',
          samplerConfig: const LiteLmSamplerConfig(
            temperature: 0.7,
            topK: 40,
            topP: 0.95,
          ),
        ),
      );

      setState(() {
        _isInitialized = true;
        _statusMessage = 'Ready';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || !_isInitialized || _isLoading) return;

    _controller.clear();
    setState(() {
      _messages.add(_ChatMessage(role: 'user', text: text));
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final response = await _conversation!.sendMessage(text);
      setState(() {
        _messages.add(_ChatMessage(role: 'model', text: response.text));
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add(_ChatMessage(role: 'error', text: 'Error: $e'));
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Lite LM'),
        actions: [
          if (!_isInitialized)
            TextButton.icon(
              onPressed: _isLoading ? null : _initializeEngine,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.play_arrow),
              label: const Text('Init'),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              _statusMessage,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Text('Initialize the engine and start chatting!'),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isUser = msg.role == 'user';
                      return Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: isUser
                                ? Theme.of(context).colorScheme.primaryContainer
                                : msg.role == 'error'
                                    ? Theme.of(context)
                                        .colorScheme
                                        .errorContainer
                                    : Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: SelectableText(msg.text),
                        ),
                      );
                    },
                  ),
          ),
          if (_isLoading && _messages.isNotEmpty)
            const Padding(
              padding: EdgeInsets.all(8),
              child: LinearProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    enabled: _isInitialized && !_isLoading,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed:
                      _isInitialized && !_isLoading ? _sendMessage : null,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String role;
  final String text;
  _ChatMessage({required this.role, required this.text});
}
