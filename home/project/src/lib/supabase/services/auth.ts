import { supabase } from '../client';
import type { AuthError, AuthResponse } from '@supabase/supabase-js';

export interface AuthCredentials {
  email: string;
  password: string;
}

export interface AuthResult {
  success: boolean;
  error?: string;
  data?: AuthResponse['data'];
}

export const authService = {
  signUp: async ({ email, password }: AuthCredentials): Promise<AuthResult> => {
    try {
      // First check if user already exists
      const { data: existingUser } = await supabase
        .from('profiles')
        .select('id')
        .eq('email', email)
        .single();

      if (existingUser) {
        return {
          success: false,
          error: 'An account with this email already exists'
        };
      }

      // Proceed with signup
      const { data, error } = await supabase.auth.signUp({
        email,
        password,
        options: {
          emailRedirectTo: `${window.location.origin}/auth/callback`,
          data: {
            email_confirmed: true // Auto-confirm for demo
          }
        }
      });

      if (error) throw error;

      // Wait for database trigger to complete
      await new Promise(resolve => setTimeout(resolve, 1500));

      // Verify profile was created
      const { data: profile, error: profileError } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', data.user?.id)
        .single();

      if (profileError || !profile) {
        throw new Error('Failed to create user profile');
      }

      return {
        success: true,
        data
      };
    } catch (err) {
      console.error('Signup error:', err);
      const error = err as AuthError;
      return {
        success: false,
        error: error.message || 'Failed to create account'
      };
    }
  },

  signIn: async ({ email, password }: AuthCredentials): Promise<AuthResult> => {
    try {
      const { data, error } = await supabase.auth.signInWithPassword({
        email,
        password
      });

      if (error) throw error;

      return {
        success: true,
        data
      };
    } catch (err) {
      const error = err as AuthError;
      return {
        success: false,
        error: error.message
      };
    }
  },

  signOut: async (): Promise<{ success: boolean; error?: string }> => {
    try {
      const { error } = await supabase.auth.signOut();
      if (error) throw error;
      return { success: true };
    } catch (err) {
      const error = err as AuthError;
      return {
        success: false,
        error: error.message
      };
    }
  }
};