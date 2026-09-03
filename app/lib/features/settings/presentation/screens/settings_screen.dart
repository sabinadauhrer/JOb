import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController _backendUrlController;

  @override
  void initState() {
    super.initState();
    _backendUrlController = TextEditingController(text: ref.read(backendUrlProvider));
  }

  @override
  void dispose() {
    _backendUrlController.dispose();
    super.dispose();
  }

  void _saveBackendUrl() {
    final url = _backendUrlController.text.trim();
    if (url.isEmpty) return;
    ref.read(sharedPreferencesProvider).setString(backendUrlPrefsKey, url);
    ref.read(backendUrlProvider.notifier).state = url;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Backend-URL gespeichert.')),
    );
  }

  void _resetBackendUrl() {
    _backendUrlController.text = defaultBackendUrl;
    ref.read(sharedPreferencesProvider).remove(backendUrlPrefsKey);
    ref.read(backendUrlProvider.notifier).state = defaultBackendUrl;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Backend-URL zurückgesetzt.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Einstellungen')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Server', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _backendUrlController,
            decoration: const InputDecoration(
              labelText: 'Backend-URL',
              helperText: 'Adresse des JobTailor-Backends, z. B. http://localhost:3000',
            ),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              FilledButton(onPressed: _saveBackendUrl, child: const Text('Speichern')),
              const SizedBox(width: 12),
              TextButton(onPressed: _resetBackendUrl, child: const Text('Zurücksetzen')),
            ],
          ),
          const Divider(height: 32),
          Image.asset(
            'assets/icons/icon_account.png',
            height: 60,
            errorBuilder: (context, error, stackTrace) => Text(
              'Konto',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Image.asset(
              'assets/icons/icon_logout.png',
              width: 42,
              height: 42,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.logout),
            ),
            title: const Text('Abmelden'),
            onTap: () => ref.read(authNotifierProvider.notifier).logout(),
          ),
          const Divider(height: 32),
          Text('Über die App', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.info_outline),
            title: Text('JobTailor'),
            subtitle: Text('Version 1.0.0'),
          ),
        ],
      ),
    );
  }
}
