import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'shared/theme/app_theme.dart';
import 'features/home/view/setup_screen.dart';
import 'features/home/view/home_screen.dart';
import 'features/chores/service/chore_service.dart';
import 'app/providers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: FairShareApp()));
}

class FairShareApp extends ConsumerWidget {
  const FairShareApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'FairShare',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const _AppLoader(),
    );
  }
}

class _AppLoader extends ConsumerStatefulWidget {
  const _AppLoader();

  @override
  ConsumerState<_AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends ConsumerState<_AppLoader> {
  bool _loading = true;
  bool _hasHousehold = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final households = await ChoreService.getAllHouseholds();
    if (households.isNotEmpty) {
      final household = households.first;
      final members = await ChoreService.getMembers(household.id);
      ref.read(currentHouseholdProvider.notifier).state = household;
      if (members.isNotEmpty) {
        ref.read(currentMemberProvider.notifier).state = members.first;
      }
      _hasHousehold = true;
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🏠', style: TextStyle(fontSize: 64)),
              SizedBox(height: 16),
              Text('FairShare', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
    }

    return _hasHousehold ? const HomeScreen() : const SetupScreen();
  }
}
