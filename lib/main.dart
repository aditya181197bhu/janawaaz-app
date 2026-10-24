import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'config/theme.dart';
import 'providers/app_state.dart';
import 'screens/admin/admin_home.dart';
import 'screens/janta/janta_home.dart';
import 'screens/onboarding/language_screen.dart';
import 'screens/onboarding/profile_screen.dart';
import 'screens/volunteer/volunteer_home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  runApp(ChangeNotifierProvider(create: (_) => AppState()..load(), child: const JanAwaazApp()));
}

class JanAwaazApp extends StatelessWidget {
  const JanAwaazApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jan Awaaz',
      debugShowCheckedModeBanner: false,
      theme: JaTheme.light,
      home: const RootGate(),
    );
  }
}

/// Language first, then profile, then that profile's home. Switching language
/// redraws the whole app in the chosen language only.
class RootGate extends StatelessWidget {
  const RootGate({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    if (!state.loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final Widget screen = switch ((state.language, state.profile)) {
      (null, _) => const LanguageScreen(),
      (_, null) => const ProfileScreen(),
      (_, Profile.janta) => const JantaHome(),
      (_, Profile.volunteer) => const VolunteerHome(),
      (_, Profile.admin) => const AdminHome(),
    };
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: KeyedSubtree(key: ValueKey('${state.language}-${state.profile}'), child: screen),
    );
  }
}
