import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/conversion.dart';
import '../../services/ai_service.dart';
import '../../services/storage_service.dart';
import '../../utils/constants.dart';

class ConvertState {
  final String output;
  final bool isLoading;
  final String? error;
  final KeigoLevel selectedLevel;

  const ConvertState({
    this.output = '',
    this.isLoading = false,
    this.error,
    this.selectedLevel = KeigoLevel.teinei,
  });

  ConvertState copyWith({
    String? output,
    bool? isLoading,
    String? error,
    KeigoLevel? selectedLevel,
  }) =>
      ConvertState(
        output: output ?? this.output,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        selectedLevel: selectedLevel ?? this.selectedLevel,
      );
}

class ConvertController extends StateNotifier<ConvertState> {
  final AiService _aiService;
  final StorageService _storage;

  ConvertController(this._aiService, this._storage) : super(const ConvertState());

  void setLevel(KeigoLevel level) {
    state = state.copyWith(selectedLevel: level);
  }

  Future<void> convert(String input) async {
    if (input.trim().isEmpty) return;

    if (_storage.isFreeTierExhausted()) {
      state = state.copyWith(
        error: '本日の無料変換回数（${AppConstants.freeTierDailyLimit}回）に達しました。Proプランにアップグレードしてください。',
      );
      return;
    }

    state = state.copyWith(isLoading: true, error: null, output: '');

    try {
      final result = await _aiService.convertToKeigo(input, state.selectedLevel);
      state = state.copyWith(output: result, isLoading: false);

      await _storage.incrementDailyCount();
      await _storage.addToHistory(Conversion(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        input: input,
        output: result,
        level: state.selectedLevel,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void clear() {
    state = const ConvertState();
  }
}

final convertControllerProvider =
    StateNotifierProvider<ConvertController, ConvertState>((ref) {
  return ConvertController(
    ref.watch(aiServiceProvider),
    ref.watch(storageServiceProvider),
  );
});
