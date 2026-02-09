import { useState } from "react";
import { motion } from "framer-motion";
import { supabase, isSupabaseConfigured } from "../../lib/supabase";

export default function Login() {
  const [mode, setMode] = useState("signin");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [status, setStatus] = useState("");

  async function handleSubmit(event) {
    event.preventDefault();
    if (!isSupabaseConfigured) {
      localStorage.setItem("pixoraCustomer", email);
      setStatus("Signed in (demo mode).");
      return;
    }

    setStatus("Working...");
    const action =
      mode === "signin"
        ? supabase.auth.signInWithPassword({ email, password })
        : supabase.auth.signUp({ email, password });

    const { error } = await action;
    if (error) {
      setStatus(error.message);
      return;
    }
    setStatus(mode === "signin" ? "Signed in." : "Check your email to confirm sign up.");
  }

  return (
    <div className="grid gap-8 lg:grid-cols-[1.1fr_0.9fr] items-center">
      <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} className="space-y-4">
        <p className="text-sm font-semibold text-[var(--accent)]">Account</p>
        <h1 className="serif text-4xl font-semibold text-slate-900">Access your Pixora workspace</h1>
        <p className="text-sm text-slate-600">
          Track orders, save wishlists, and unlock pro-only bundles curated for photographers and filmmakers.
        </p>
        <div className="grid gap-3 sm:grid-cols-2">
          <div className="rounded-2xl border border-slate-200 bg-white p-4 text-sm text-slate-600">
            <p className="font-semibold text-slate-900">Order history</p>
            <p className="mt-2">View purchase history and download receipts.</p>
          </div>
          <div className="rounded-2xl border border-slate-200 bg-white p-4 text-sm text-slate-600">
            <p className="font-semibold text-slate-900">Exclusive drops</p>
            <p className="mt-2">Get first access to new camera bodies and bundles.</p>
          </div>
        </div>
      </motion.div>

      <motion.form
        onSubmit={handleSubmit}
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="rounded-3xl border border-slate-200 bg-white p-8 shadow-sm space-y-4"
      >
        <div className="flex items-center justify-between">
          <h2 className="text-2xl font-semibold text-slate-900">{mode === "signin" ? "Sign in" : "Create account"}</h2>
          <button
            type="button"
            onClick={() => setMode(mode === "signin" ? "signup" : "signin")}
            className="text-xs font-semibold text-slate-500 hover:text-slate-700"
          >
            Switch to {mode === "signin" ? "sign up" : "sign in"}
          </button>
        </div>
        <label className="text-sm font-semibold text-slate-700">
          Email
          <input
            type="email"
            className="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-900 focus:outline-none focus:ring-2 focus:ring-[var(--accent)]"
            placeholder="you@example.com"
            value={email}
            onChange={(event) => setEmail(event.target.value)}
            required
          />
        </label>
        <label className="text-sm font-semibold text-slate-700">
          Password
          <input
            type="password"
            className="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-900 focus:outline-none focus:ring-2 focus:ring-[var(--accent)]"
            placeholder="At least 8 characters"
            value={password}
            onChange={(event) => setPassword(event.target.value)}
            required
          />
        </label>
        {status && <p className="text-xs text-slate-500">{status}</p>}
        {!isSupabaseConfigured && (
          <p className="text-xs text-slate-500">
            Demo mode: Supabase is not configured, so sign-in is stored locally.
          </p>
        )}
        <button
          type="submit"
          className="mt-2 w-full rounded-full bg-[var(--accent)] px-4 py-3 text-sm font-semibold text-white shadow-sm hover:opacity-90"
        >
          {mode === "signin" ? "Sign in" : "Create account"}
        </button>
      </motion.form>
    </div>
  );
}
