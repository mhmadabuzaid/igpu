import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Import your screens and providers
import 'providers/auth_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ugfmkpezgakhyyfzouib.supabase.co', // Keep your real keys here!
    anonKey: 'sb_publishable_uCFEEdEye2t4wF_ETm4Vrg_UOwVVeAY',
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PC Hardware Store',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AuthChecker(), // <--- The new Gatekeeper
    );
  }
}

class AuthChecker extends ConsumerWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the auth state (Logged In vs Logged Out)
    final authStateAsync = ref.watch(authStateProvider);

    return authStateAsync.when(
      data: (authState) {
        final session = authState.session;
        // If we have a session, go to Home. If not, go to Auth.
        if (session != null) {
          return const HomeScreen();
        } else {
          return const AuthScreen();
        }
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}
