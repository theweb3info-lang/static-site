import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _available = false;

  Future<void> init() async {
    _available = await _speech.initialize(
      onError: (error) => print('Speech error: $error'),
      onStatus: (status) => print('Speech status: $status'),
    );
  }

  void listen({required Function(String) onResult}) {
    if (!_available) return;
    _speech.listen(
      onResult: (result) {
        if (result.finalResult || result.recognizedWords.isNotEmpty) {
          onResult(result.recognizedWords);
        }
      },
      localeId: 'zh_CN',
      listenMode: stt.ListenMode.dictation,
      cancelOnError: false,
      partialResults: true,
    );
  }

  void stop() => _speech.stop();
}
