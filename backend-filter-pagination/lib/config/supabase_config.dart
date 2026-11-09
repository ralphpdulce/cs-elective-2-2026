/// Supabase Configuration
/// 
/// Replace [supabaseUrl] and [supabaseAnonKey] with your project credentials
/// from your Supabase Dashboard: Settings -> API.
class SupabaseConfig {
  // Your Supabase Project URL, e.g.: 'https://xyzcompany.supabase.co'
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';

  // Your Supabase Anon / Public Key, e.g.: 'eyJhbGciOi...'
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  /// Whether Supabase credentials have been configured by the developer
  static bool get isConfigured {
    return supabaseUrl.isNotEmpty &&
        supabaseAnonKey.isNotEmpty &&
        !supabaseUrl.contains('YOUR_SUPABASE') &&
        !supabaseAnonKey.contains('YOUR_SUPABASE');
  }
}
