-- =============================================================================
-- BLUPP AI FINANCE - COMPLETE SUPABASE DATABASE SCHEMA
-- Run this script in your Supabase Dashboard: SQL Editor -> New Query -> Run
-- =============================================================================

-- 1. PROFILES & USER SETTINGS
CREATE TABLE IF NOT EXISTS public.profiles (
  id TEXT PRIMARY KEY,
  full_name TEXT,
  email TEXT,
  phone TEXT,
  notifications_enabled BOOLEAN DEFAULT true,
  biometrics_enabled BOOLEAN DEFAULT true,
  monthly_budget NUMERIC DEFAULT 3200.00,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS & Allow Access
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow public all access on profiles" 
  ON public.profiles FOR ALL USING (true) WITH CHECK (true);

-- 2. BANK ACCOUNTS
CREATE TABLE IF NOT EXISTS public.bank_accounts (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  name TEXT NOT NULL,
  account_number TEXT,
  balance NUMERIC NOT NULL DEFAULT 0.00,
  color_hex TEXT DEFAULT '0xFFFFB800',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.bank_accounts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow public all access on bank_accounts" 
  ON public.bank_accounts FOR ALL USING (true) WITH CHECK (true);

-- 3. TRANSACTIONS (EXPENSES & INCOMES)
CREATE TABLE IF NOT EXISTS public.transactions (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  title TEXT NOT NULL,
  amount NUMERIC NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('income', 'expense')),
  category_id TEXT NOT NULL,
  date TIMESTAMP WITH TIME ZONE NOT NULL,
  bank_account_id TEXT,
  note TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow public all access on transactions" 
  ON public.transactions FOR ALL USING (true) WITH CHECK (true);

-- 4. INVESTMENTS & SAVINGS
CREATE TABLE IF NOT EXISTS public.investments (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  name TEXT NOT NULL,
  institution TEXT,
  balance NUMERIC NOT NULL DEFAULT 0.00,
  return_rate_annual NUMERIC DEFAULT 0.00,
  notes TEXT,
  color_hex TEXT DEFAULT '0xFF00C48C',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.investments ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow public all access on investments" 
  ON public.investments FOR ALL USING (true) WITH CHECK (true);

-- 5. LOANS & LIABILITIES
CREATE TABLE IF NOT EXISTS public.loans (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  name TEXT NOT NULL,
  provider TEXT,
  total_loan NUMERIC NOT NULL DEFAULT 0.00,
  remaining_balance NUMERIC NOT NULL DEFAULT 0.00,
  monthly_installment NUMERIC NOT NULL DEFAULT 0.00,
  due_day_of_month INT DEFAULT 1,
  color_hex TEXT DEFAULT '0xFFFF6584',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.loans ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow public all access on loans" 
  ON public.loans FOR ALL USING (true) WITH CHECK (true);

-- 6. PLANNED EXPENSES (CALENDAR PLANNER)
CREATE TABLE IF NOT EXISTS public.planned_expenses (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  title TEXT NOT NULL,
  amount NUMERIC NOT NULL,
  category_id TEXT NOT NULL,
  date TIMESTAMP WITH TIME ZONE NOT NULL,
  is_recurring BOOLEAN DEFAULT false,
  is_paid BOOLEAN DEFAULT false,
  note TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.planned_expenses ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow public all access on planned_expenses" 
  ON public.planned_expenses FOR ALL USING (true) WITH CHECK (true);

-- 7. FOMO AI WISHLIST & AVOIDANCES
CREATE TABLE IF NOT EXISTS public.fomo_wishlist (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  title TEXT NOT NULL,
  cost NUMERIC NOT NULL,
  category_id TEXT NOT NULL,
  added_date TIMESTAMP WITH TIME ZONE NOT NULL,
  ai_verdict TEXT,
  ai_reason TEXT,
  avoided BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.fomo_wishlist ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow public all access on fomo_wishlist" 
  ON public.fomo_wishlist FOR ALL USING (true) WITH CHECK (true);
