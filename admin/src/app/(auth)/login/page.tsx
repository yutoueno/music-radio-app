"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/hooks/use-auth";
import { useToast } from "@/components/ui/toast";

export default function LoginPage() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const { login } = useAuth();
  const { toast } = useToast();
  const router = useRouter();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email || !password) {
      toast({
        title: "入力エラー",
        description: "メールアドレスとパスワードを入力してください。",
        variant: "destructive",
      });
      return;
    }

    setIsLoading(true);
    try {
      await login({ email, password });
      toast({
        title: "ログイン成功",
        description: "管理画面にようこそ。",
        variant: "success",
      });
    } catch (error) {
      toast({
        title: "ログイン失敗",
        description:
          error instanceof Error
            ? error.message
            : "メールアドレスまたはパスワードが正しくありません。",
        variant: "destructive",
      });
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="flex min-h-screen items-center justify-center bg-crate-void px-4">
      <div className="w-full max-w-md space-y-8">
        {/* Logo */}
        <div className="text-center">
          <h1 className="font-heading text-5xl font-bold tracking-tight text-crate-text-primary">
            CRATE
          </h1>
          <p className="mt-2 text-sm font-semibold uppercase tracking-[0.3em] text-crate-accent">
            ADMIN
          </p>
        </div>

        {/* Card */}
        <div className="rounded-xl border border-crate-border bg-crate-surface p-8">
          <p className="mb-6 text-center text-sm text-crate-text-secondary">
            管理画面にログインしてください
          </p>

          <form onSubmit={handleSubmit} className="space-y-5">
            <div className="space-y-2">
              <label
                htmlFor="email"
                className="block text-xs font-medium uppercase tracking-wider text-crate-text-secondary"
              >
                メールアドレス
              </label>
              <input
                id="email"
                type="email"
                placeholder="admin@example.com"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                disabled={isLoading}
                autoComplete="email"
                className="w-full rounded-lg border border-crate-border bg-crate-elevated px-4 py-3 text-sm text-crate-text-primary placeholder:text-crate-text-tertiary outline-none transition-colors focus:border-crate-accent focus:ring-1 focus:ring-crate-accent disabled:opacity-50"
              />
            </div>

            <div className="space-y-2">
              <label
                htmlFor="password"
                className="block text-xs font-medium uppercase tracking-wider text-crate-text-secondary"
              >
                パスワード
              </label>
              <input
                id="password"
                type="password"
                placeholder="パスワードを入力"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                disabled={isLoading}
                autoComplete="current-password"
                className="w-full rounded-lg border border-crate-border bg-crate-elevated px-4 py-3 text-sm text-crate-text-primary placeholder:text-crate-text-tertiary outline-none transition-colors focus:border-crate-accent focus:ring-1 focus:ring-crate-accent disabled:opacity-50"
              />
            </div>

            <button
              type="submit"
              disabled={isLoading}
              className="w-full rounded-lg bg-crate-accent px-4 py-3 text-sm font-semibold text-white transition-colors hover:bg-crate-accent-dim disabled:opacity-50"
            >
              {isLoading ? (
                <span className="flex items-center justify-center gap-2">
                  <span className="h-4 w-4 animate-spin rounded-full border-2 border-white border-t-transparent" />
                  ログイン中...
                </span>
              ) : (
                "ログイン"
              )}
            </button>
          </form>
        </div>

        <p className="text-center text-xs text-crate-text-tertiary">
          CRATE Admin Panel
        </p>
      </div>
    </div>
  );
}
