/// Supabase Configuration
/// 
/// Replace [supabaseUrl] and [supabaseAnonKey] with your project credentials
/// from your Supabase Dashboard: Settings -> API.
class SupabaseConfig {
  // Your Supabase Project URL
  static const String supabaseUrl = 'https://mkwlneayechpfecwwtyj.supabase.co';

  // Your Supabase Anon / Public Key
  static const String supabaseAnonKey = 'sb_publishable_4QMi_q2O0Nfa5lF6XNHCHg_yk33mQSd';

  // OAuth callback redirect URI for native mobile deep linking
  static const String authRedirectUri = 'io.supabase.flutterquickstart://login-callback/';

  /// Whether Supabase credentials have been configured by the developer
  static bool get isConfigured {
    return supabaseUrl.isNotEmpty &&
        supabaseAnonKey.isNotEmpty &&
        !supabaseUrl.contains('YOUR_SUPABASE') &&
        !supabaseAnonKey.contains('YOUR_SUPABASE');
  }
}

