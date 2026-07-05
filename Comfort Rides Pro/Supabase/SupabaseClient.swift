//
//  SupabaseClient.swift
//  Comfort Rides Pro
//

import Supabase

let supabase = SupabaseClient(
    supabaseURL: URL(string: K.supabaseURL)!,
    supabaseKey: K.supabaseAnonKey
)
