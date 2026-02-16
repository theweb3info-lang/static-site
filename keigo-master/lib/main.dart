import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/router.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const KeigoMasterApp(),
    ),
  );
}

class KeigoMasterApp extends ConsumerWidget {
  const KeigoMasterApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = ref.watch(storageServiceProvider);
    final hasApiKey = (storage.getApiKey() ?? '').isNotEmpty;

    return MaterialApp.router(
      title: '敬語マスター',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      routerConfig: router,
      builder: (context, child) {
        if (!hasApiKey) {
          return _OnboardingScreen();
        }
        return child!;
      },
    );
  }

  ThemeData _buildTheme() {
    final base = ThemeData(
      brightness: Brightness.dark,
      colorSchemeSeed: const Color(0xFF6750A4),
      useMaterial3: true,
    );
    return base.copyWith(
      textTheme: GoogleFonts.notoSansJpTextTheme(base.textTheme),
    );
  }
}

class _OnboardingScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<_OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<_OnboardingScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '敬語マスター',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'AIで日本語をスマートに敬語変換',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'OpenAI APIキー',
                  hintText: 'sk-...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.key),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () async {
                  final key = _controller.text.trim();
                  if (key.isEmpty) return;
                  await ref.read(storageServiceProvider).setApiKey(key);
                  ref.invalidate(storageServiceProvider);
                },
                icon: const Icon(Icons.arrow_forward),
                label: const Text('始める'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'APIキーはデバイスにのみ保存されます',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
