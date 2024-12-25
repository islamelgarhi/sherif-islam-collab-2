// Supabase configuration constants
export const SUPABASE_CONFIG = {
  url: import.meta.env.VITE_SUPABASE_URL,
  anonKey: import.meta.env.VITE_SUPABASE_ANON_KEY,
  serviceKey: import.meta.env.VITE_SUPABASE_SERVICE_KEY // Only used in secure contexts
} as const;

// Type guard to check if we're in an admin/service context
export const isServiceContext = () => {
  return !!SUPABASE_CONFIG.serviceKey;
};

// Validate required environment variables
if (!SUPABASE_CONFIG.url || !SUPABASE_CONFIG.anonKey) {
  throw new Error('Missing required Supabase configuration');
}