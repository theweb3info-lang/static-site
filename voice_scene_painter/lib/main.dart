import 'package:flutter/material.dart';
import 'scene_painter.dart';
import 'speech_service.dart';

void main() => runApp(const VoiceScenePainterApp());

class VoiceScenePainterApp extends StatelessWidget {
  const VoiceScenePainterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '语音场景画板',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SpeechService _speech = SpeechService();
  final List<SceneElement> _elements = [];
  String _lastHeard = '';
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech.init();
  }

  void _toggleListening() {
    if (_isListening) {
      _speech.stop();
      setState(() => _isListening = false);
    } else {
      _speech.listen(onResult: (text) {
        setState(() {
          _lastHeard = text;
          _elements.clear();
          _elements.addAll(SceneParser.parse(text));
        });
      });
      setState(() => _isListening = true);
    }
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎨 语音场景画板'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Status bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: _isListening
                ? Colors.red.withValues(alpha: 0.2)
                : Colors.transparent,
            child: Text(
              _isListening ? '🎤 正在聆听...' : '点击麦克风开始说话',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ),

          // Last heard text
          if (_lastHeard.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                '📝 "$_lastHeard"',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
                textAlign: TextAlign.center,
              ),
            ),

          // ASCII Scene canvas
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.teal.withValues(alpha: 0.5)),
              ),
              child: _elements.isEmpty
                  ? const Center(
                      child: Text(
                        '说些什么，我来画！\n\n试试: "公园里有小朋友，天气晴朗"',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontFamily: 'monospace',
                        ),
                      ),
                    )
                  : AsciiSceneCanvas(elements: _elements),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: _toggleListening,
        backgroundColor: _isListening ? Colors.red : Colors.teal,
        child: Icon(
          _isListening ? Icons.stop : Icons.mic,
          size: 36,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
