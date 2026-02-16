import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  final _textRecognizer = TextRecognizer();

  Future<String> extractText(String imagePath) async {
    final inputImage = InputImage.fromFile(File(imagePath));
    final recognized = await _textRecognizer.processImage(inputImage);
    return recognized.text;
  }

  void dispose() {
    _textRecognizer.close();
  }
}
