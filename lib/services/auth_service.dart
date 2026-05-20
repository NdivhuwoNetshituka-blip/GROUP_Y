import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_user.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Sign up a new user with email + password
  Future<AppUser> signUp(String email, String password, String role) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Sign up failed: ${response.session?.toJson()}');
    }

    // Insert into users table to store role
    final insertResponse = await _client.from('users').insert({
      'id': response.user!.id, // UUID from Supabase Auth
      'email': email,
      'role': role,
    }).select();

    if (insertResponse.isEmpty) {
      throw Exception('Insert into users table failed. Check RLS policies.');
    }

    return AppUser(id: response.user!.id, email: email, role: role);
  }

  /// Sign in an existing user
  Future<AppUser> signIn(String email, String password) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Login failed');
    }

    // Fetch role from users table
    final userData = await _client
        .from('users')
        .select()
        .eq('id', response.user!.id)
        .maybeSingle();

    if (userData == null) {
      throw Exception(
        'No user record found in users table for id ${response.user!.id}',
      );
    }

    return AppUser(
      id: response.user!.id,
      email: response.user!.email ?? '',
      role: userData['role'],
    );
  }

  /// Sign out the current user
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Get the currently logged-in user
  Future<AppUser?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final userData = await _client
        .from('users')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (userData == null) return null;

    return AppUser(
      id: user.id,
      email: user.email ?? '',
      role: userData['role'],
    );
  }
}
