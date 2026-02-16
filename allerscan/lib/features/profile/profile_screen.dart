import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/scan/scan_controller.dart';
import '../../models/user_profile.dart';
import '../../utils/constants.dart';
import 'allergen_selector.dart';

final profileProvider = StateNotifierProvider<ProfileNotifier, UserProfile>((ref) {
  final storage = ref.watch(storageProvider);
  return ProfileNotifier(storage);
});

class ProfileNotifier extends StateNotifier<UserProfile> {
  final dynamic _storage;

  ProfileNotifier(this._storage) : super(const UserProfile()) {
    _load();
  }

  void _load() {
    try {
      state = _storage.loadProfile();
    } catch (_) {}
  }

  void toggleAllergen(String id) {
    final ids = List<String>.from(state.selectedAllergenIds);
    if (ids.contains(id)) {
      ids.remove(id);
    } else {
      ids.add(id);
    }
    state = state.copyWith(selectedAllergenIds: ids);
    _storage.saveProfile(state);
  }

  void addCustom(String name) {
    if (name.trim().isEmpty) return;
    final custom = List<String>.from(state.customAllergens);
    if (!custom.contains(name.trim())) {
      custom.add(name.trim());
      state = state.copyWith(customAllergens: custom);
      _storage.saveProfile(state);
    }
  }

  void removeCustom(String name) {
    final custom = List<String>.from(state.customAllergens);
    custom.remove(name);
    state = state.copyWith(customAllergens: custom);
    _storage.saveProfile(state);
  }
}

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _customController = TextEditingController();

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final notifier = ref.read(profileProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('My Allergen Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Select your allergens',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'We\'ll alert you when these are found in ingredients',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 20),

          AllergenSelector(
            allergens: AppConstants.commonAllergens,
            selectedIds: profile.selectedAllergenIds,
            onToggle: notifier.toggleAllergen,
          ),

          const SizedBox(height: 32),
          Text(
            'Custom Allergens',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _customController,
                  decoration: InputDecoration(
                    hintText: 'Add custom allergen...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  onSubmitted: (v) {
                    notifier.addCustom(v);
                    _customController.clear();
                  },
                ),
              ),
              const SizedBox(width: 12),
              IconButton.filled(
                onPressed: () {
                  notifier.addCustom(_customController.text);
                  _customController.clear();
                },
                icon: const Icon(Icons.add),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: profile.customAllergens
                .map((a) => Chip(
                      label: Text(a),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () => notifier.removeCustom(a),
                      backgroundColor: Colors.red.shade50,
                    ))
                .toList(),
          ),

          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Text('ℹ️', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${profile.selectedAllergenIds.length + profile.customAllergens.length} allergen(s) selected. '
                    'AllerScan will check for these and their hidden forms.',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
