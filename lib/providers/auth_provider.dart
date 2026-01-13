import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 1. The Service: Handles the actual actions
class AuthService {
  final GoTrueClient _auth = Supabase.instance.client.auth;

  Future<void> signUp(String email, String password) async {
    await _auth.signUp(email: email, password: password);
  }

  Future<void> signIn(String email, String password) async {
    await _auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}

// 2. The Providers
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// This stream listens to the user's status (Logged In or Out) automatically
final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});
