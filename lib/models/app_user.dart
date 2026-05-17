// models/app_user.dart
//https://fiagwudpgtrlhdlaiize.supabase.co/users this is the api for this table

class AppUser {
  String id;
  String email;
  String role;

  AppUser({required this.id, required this.email, required this.role});
}
