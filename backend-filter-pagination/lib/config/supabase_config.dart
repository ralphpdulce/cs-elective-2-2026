/// Supabase Configuration
/// 
/// Replace [supabaseUrl] and [supabaseAnonKey] with your project credentials
/// from your Supabase Dashboard: Settings -> API.
class SupabaseConfig {
  // Your Supabase Project URL
  static const String supabaseUrl = 'https://dfwoygvyymtdwepsjgtz.supabase.co';

  // Your Supabase Anon / Public Key
  static const String supabaseAnonKey = 'sb_publishable_nj-mJHyneKIinhNzc84mOA_RHYT5mGK';

  /// Whether Supabase credentials have been configured by the developer
  static bool get isConfigured {
    return supabaseUrl.isNotEmpty &&
        supabaseAnonKey.isNotEmpty &&
        !supabaseUrl.contains('YOUR_SUPABASE') &&
        !supabaseAnonKey.contains('YOUR_SUPABASE');
  }
}

