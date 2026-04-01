"use client";

import { useParams, useRouter } from "next/navigation";
import { ArrowLeft, UserX, UserCheck, Mail, Calendar, Shield } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { useToast } from "@/components/ui/toast";
import {
  useUser,
  useSuspendUser,
  useActivateUser,
} from "@/hooks/use-api";
import { formatDateTime } from "@/lib/utils";

export default function UserDetailPage() {
  const params = useParams();
  const router = useRouter();
  const { toast } = useToast();
  const id = params.id as string;

  const { data, isLoading } = useUser(id);
  const suspendUser = useSuspendUser();
  const activateUser = useActivateUser();

  const user = data?.data;

  const displayName = user?.profile?.nickname || user?.email || "";
  const avatarUrl = user?.profile?.avatar_url || null;

  const handleSuspend = async () => {
    if (!user) return;
    try {
      await suspendUser.mutateAsync(user.id);
      toast({ title: "アカウントを停止しました", variant: "success" });
    } catch {
      toast({ title: "エラーが発生しました", variant: "destructive" });
    }
  };

  const handleActivate = async () => {
    if (!user) return;
    try {
      await activateUser.mutateAsync(user.id);
      toast({ title: "アカウントを有効化しました", variant: "success" });
    } catch {
      toast({ title: "エラーが発生しました", variant: "destructive" });
    }
  };

  if (isLoading) {
    return (
      <div className="space-y-6">
        <div className="h-8 w-48 animate-pulse rounded-lg bg-crate-surface" />
        <div className="h-64 animate-pulse rounded-xl bg-crate-surface" />
      </div>
    );
  }

  if (!user) {
    return (
      <div className="space-y-6">
        <button
          onClick={() => router.back()}
          className="flex items-center gap-2 text-sm text-crate-text-secondary hover:text-crate-text-primary"
        >
          <ArrowLeft className="h-4 w-4" />
          戻る
        </button>
        <p className="text-crate-text-tertiary">ユーザーが見つかりません。</p>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-4">
          <button
            onClick={() => router.back()}
            className="flex h-9 w-9 items-center justify-center rounded-lg border border-crate-border bg-crate-surface text-crate-text-secondary transition-colors hover:bg-crate-elevated hover:text-crate-text-primary"
          >
            <ArrowLeft className="h-4 w-4" />
          </button>
          <div>
            <h1 className="font-heading text-2xl font-bold text-crate-text-primary">ユーザー詳細</h1>
            <p className="text-xs font-mono text-crate-text-tertiary">ID: {user.id}</p>
          </div>
        </div>
        <div className="flex items-center gap-2">
          {user.is_active ? (
            <button
              onClick={handleSuspend}
              className="flex items-center gap-2 rounded-lg border border-crate-border bg-crate-surface px-4 py-2 text-sm text-crate-error transition-colors hover:bg-crate-error/10"
            >
              <UserX className="h-4 w-4" />
              アカウント停止
            </button>
          ) : (
            <button
              onClick={handleActivate}
              className="flex items-center gap-2 rounded-lg border border-crate-border bg-crate-surface px-4 py-2 text-sm text-crate-success transition-colors hover:bg-crate-success/10"
            >
              <UserCheck className="h-4 w-4" />
              有効化
            </button>
          )}
        </div>
      </div>

      <div className="grid gap-6 md:grid-cols-3">
        {/* Profile Card */}
        <div className="rounded-xl border border-crate-border bg-crate-surface p-6 md:col-span-1">
          <div className="flex flex-col items-center">
            <Avatar className="h-20 w-20 border-2 border-crate-border bg-crate-elevated">
              {avatarUrl && <AvatarImage src={avatarUrl} />}
              <AvatarFallback className="bg-crate-elevated text-2xl text-crate-text-secondary">
                {displayName.charAt(0)}
              </AvatarFallback>
            </Avatar>
            <h2 className="mt-4 text-xl font-semibold text-crate-text-primary">{displayName}</h2>
            <div className="mt-3 flex gap-2">
              <span
                className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium ${
                  user.is_admin
                    ? "bg-crate-accent/15 text-crate-accent"
                    : "bg-crate-elevated text-crate-text-secondary"
                }`}
              >
                {user.is_admin ? "管理者" : "ユーザー"}
              </span>
              <span
                className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium ${
                  user.is_active
                    ? "bg-crate-success/15 text-crate-success"
                    : "bg-crate-error/15 text-crate-error"
                }`}
              >
                {user.is_active ? "有効" : "停止中"}
              </span>
            </div>

            <div className="my-4 h-px w-full bg-crate-border" />

            <div className="w-full space-y-3">
              <div className="flex items-center gap-2 text-sm">
                <Mail className="h-4 w-4 text-crate-text-tertiary" />
                <span className="text-crate-text-secondary">{user.email}</span>
              </div>
              <div className="flex items-center gap-2 text-sm">
                <Calendar className="h-4 w-4 text-crate-text-tertiary" />
                <span className="text-crate-text-secondary">
                  {formatDateTime(user.created_at)} 登録
                </span>
              </div>
              <div className="flex items-center gap-2 text-sm">
                <Shield className="h-4 w-4 text-crate-text-tertiary" />
                <span className="text-crate-text-secondary">
                  メール認証: {user.email_verified ? "済み" : "未認証"}
                </span>
              </div>
            </div>
          </div>
        </div>

        {/* Details */}
        <div className="rounded-xl border border-crate-border bg-crate-surface md:col-span-2">
          <div className="border-b border-crate-border px-5 py-4">
            <h3 className="text-sm font-semibold text-crate-text-primary">詳細情報</h3>
          </div>
          <div className="p-5 space-y-3">
            {[
              { label: "ユーザーID", value: <span className="font-mono">{user.id}</span> },
              { label: "メールアドレス", value: user.email },
              { label: "アクティブ", value: user.is_active ? "はい" : "いいえ" },
              { label: "管理者", value: user.is_admin ? "はい" : "いいえ" },
              { label: "メール認証", value: user.email_verified ? "認証済み" : "未認証" },
              { label: "登録日時", value: formatDateTime(user.created_at) },
              { label: "最終更新", value: formatDateTime(user.updated_at) },
            ].map((row) => (
              <div key={row.label} className="flex justify-between text-sm">
                <span className="text-crate-text-tertiary">{row.label}</span>
                <span className="text-crate-text-primary">{row.value}</span>
              </div>
            ))}

            {user.profile && (
              <>
                <div className="my-4 h-px w-full bg-crate-border" />
                <h4 className="mb-3 text-sm font-semibold text-crate-text-primary">プロフィール</h4>
                <div className="space-y-3">
                  <div className="flex justify-between text-sm">
                    <span className="text-crate-text-tertiary">ニックネーム</span>
                    <span className="text-crate-text-primary">{user.profile.nickname}</span>
                  </div>
                  {user.profile.message && (
                    <div className="flex justify-between text-sm">
                      <span className="text-crate-text-tertiary">メッセージ</span>
                      <span className="text-crate-text-primary">{user.profile.message}</span>
                    </div>
                  )}
                  <div className="flex justify-between text-sm">
                    <span className="text-crate-text-tertiary">フォロワー数</span>
                    <span className="text-crate-text-primary">{user.profile.follower_count}</span>
                  </div>
                </div>
              </>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
