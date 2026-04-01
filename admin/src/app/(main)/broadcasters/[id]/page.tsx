"use client";

import { useParams, useRouter } from "next/navigation";
import Link from "next/link";
import {
  ArrowLeft,
  UserX,
  UserCheck,
  Mail,
  Calendar,
  Users,
  Radio,
  Play,
  Heart,
} from "lucide-react";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { DataTable, type Column } from "@/components/data-table";
import { useToast } from "@/components/ui/toast";
import {
  useBroadcaster,
  useSuspendUser,
  useActivateUser,
} from "@/hooks/use-api";
import { formatDate, formatDateTime, formatNumber } from "@/lib/utils";
import type { BroadcasterProgram } from "@/types";

const statusLabels: Record<string, string> = {
  draft: "下書き",
  published: "公開中",
  archived: "アーカイブ",
};

const statusColors: Record<string, string> = {
  draft: "bg-crate-elevated text-crate-text-tertiary",
  published: "bg-crate-success/15 text-crate-success",
  archived: "bg-yellow-500/15 text-yellow-400",
};

export default function BroadcasterDetailPage() {
  const params = useParams();
  const router = useRouter();
  const { toast } = useToast();
  const id = params.id as string;

  const { data, isLoading } = useBroadcaster(id);
  const suspendUser = useSuspendUser();
  const activateUser = useActivateUser();

  const broadcaster = data?.data;

  const displayName = broadcaster?.profile?.nickname || broadcaster?.email || "";
  const avatarUrl = broadcaster?.profile?.avatar_url || null;

  const handleSuspend = async () => {
    if (!broadcaster) return;
    try {
      await suspendUser.mutateAsync(broadcaster.id);
      toast({ title: "アカウントを停止しました", variant: "success" });
    } catch {
      toast({ title: "エラーが発生しました", variant: "destructive" });
    }
  };

  const handleActivate = async () => {
    if (!broadcaster) return;
    try {
      await activateUser.mutateAsync(broadcaster.id);
      toast({ title: "アカウントを有効化しました", variant: "success" });
    } catch {
      toast({ title: "エラーが発生しました", variant: "destructive" });
    }
  };

  const programColumns: Column<BroadcasterProgram>[] = [
    {
      key: "title",
      header: "番組タイトル",
      render: (program) => (
        <Link
          href={`/programs/${program.id}`}
          className="font-medium text-crate-text-primary hover:text-crate-accent"
        >
          {program.title}
        </Link>
      ),
    },
    {
      key: "status",
      header: "ステータス",
      render: (program) => (
        <span className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium ${statusColors[program.status] || statusColors.draft}`}>
          {statusLabels[program.status] || program.status}
        </span>
      ),
    },
    {
      key: "play_count",
      header: "再生数",
      render: (program) => (
        <span className="text-sm tabular-nums text-crate-text-primary">{formatNumber(program.play_count)}</span>
      ),
    },
    {
      key: "favorite_count",
      header: "お気に入り",
      render: (program) => (
        <span className="text-sm tabular-nums text-crate-text-secondary">{formatNumber(program.favorite_count)}</span>
      ),
    },
    {
      key: "track_count",
      header: "楽曲数",
      render: (program) => (
        <span className="text-sm text-crate-text-secondary">{program.track_count}</span>
      ),
    },
    {
      key: "genre",
      header: "ジャンル",
      render: (program) => (
        <span className="text-sm text-crate-text-secondary">{program.genre || "-"}</span>
      ),
    },
    {
      key: "created_at",
      header: "作成日",
      render: (program) => (
        <span className="text-sm text-crate-text-secondary">{formatDate(program.created_at)}</span>
      ),
    },
  ];

  if (isLoading) {
    return (
      <div className="space-y-6">
        <div className="h-8 w-48 animate-pulse rounded-lg bg-crate-surface" />
        <div className="grid gap-6 md:grid-cols-3">
          <div className="h-64 animate-pulse rounded-xl bg-crate-surface" />
          <div className="h-64 animate-pulse rounded-xl bg-crate-surface md:col-span-2" />
        </div>
        <div className="h-64 animate-pulse rounded-xl bg-crate-surface" />
      </div>
    );
  }

  if (!broadcaster) {
    return (
      <div className="space-y-6">
        <button
          onClick={() => router.back()}
          className="flex items-center gap-2 text-sm text-crate-text-secondary hover:text-crate-text-primary"
        >
          <ArrowLeft className="h-4 w-4" />
          戻る
        </button>
        <p className="text-crate-text-tertiary">配信者が見つかりません。</p>
      </div>
    );
  }

  const stats = broadcaster.stats;

  const statCards = [
    { icon: Radio, label: "番組数", value: formatNumber(stats.total_programs), color: "text-crate-accent", bgColor: "bg-crate-accent/10" },
    { icon: Play, label: "総再生数", value: formatNumber(stats.total_plays), color: "text-crate-success", bgColor: "bg-crate-success/10" },
    { icon: Heart, label: "総お気に入り", value: formatNumber(stats.total_favorites), color: "text-crate-error", bgColor: "bg-crate-error/10" },
    { icon: Users, label: "フォロワー", value: formatNumber(stats.follower_count), color: "text-purple-400", bgColor: "bg-purple-400/10" },
  ];

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
            <h1 className="font-heading text-2xl font-bold text-crate-text-primary">配信者詳細</h1>
            <p className="text-xs font-mono text-crate-text-tertiary">ID: {broadcaster.id}</p>
          </div>
        </div>
        <div className="flex items-center gap-2">
          {broadcaster.is_active ? (
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

      {/* Stats Summary */}
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {statCards.map((stat) => (
          <div key={stat.label} className="rounded-xl border border-crate-border bg-crate-surface p-4">
            <div className="flex items-center gap-3">
              <div className={`flex h-10 w-10 items-center justify-center rounded-lg ${stat.bgColor}`}>
                <stat.icon className={`h-5 w-5 ${stat.color}`} />
              </div>
              <div>
                <p className="text-xs text-crate-text-tertiary">{stat.label}</p>
                <p className="text-2xl font-bold text-crate-text-primary">{stat.value}</p>
              </div>
            </div>
          </div>
        ))}
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
            {broadcaster.profile?.message && (
              <p className="mt-1 text-center text-sm text-crate-text-secondary">
                {broadcaster.profile.message}
              </p>
            )}
            <div className="mt-3 flex gap-2">
              <span
                className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium ${
                  broadcaster.is_active
                    ? "bg-crate-success/15 text-crate-success"
                    : "bg-crate-error/15 text-crate-error"
                }`}
              >
                {broadcaster.is_active ? "有効" : "停止中"}
              </span>
              {broadcaster.is_admin && (
                <span className="inline-flex items-center rounded-full bg-crate-accent/15 px-2.5 py-0.5 text-xs font-medium text-crate-accent">
                  管理者
                </span>
              )}
            </div>

            <div className="my-4 h-px w-full bg-crate-border" />

            <div className="w-full space-y-3">
              <div className="flex items-center gap-2 text-sm">
                <Mail className="h-4 w-4 text-crate-text-tertiary" />
                <span className="text-crate-text-secondary">{broadcaster.email}</span>
              </div>
              <div className="flex items-center gap-2 text-sm">
                <Calendar className="h-4 w-4 text-crate-text-tertiary" />
                <span className="text-crate-text-secondary">
                  {formatDateTime(broadcaster.created_at)} 登録
                </span>
              </div>
              <div className="flex items-center gap-2 text-sm">
                <Users className="h-4 w-4 text-crate-text-tertiary" />
                <span className="text-crate-text-secondary">
                  フォロワー {formatNumber(stats.follower_count)} / フォロー中 {formatNumber(stats.following_count)}
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
              { label: "ユーザーID", value: <span className="font-mono">{broadcaster.id}</span> },
              { label: "メールアドレス", value: broadcaster.email },
              { label: "アクティブ", value: broadcaster.is_active ? "はい" : "いいえ" },
              { label: "メール認証", value: broadcaster.email_verified ? "認証済み" : "未認証" },
              { label: "登録日時", value: formatDateTime(broadcaster.created_at) },
              { label: "最終更新", value: formatDateTime(broadcaster.updated_at) },
            ].map((row) => (
              <div key={row.label} className="flex justify-between text-sm">
                <span className="text-crate-text-tertiary">{row.label}</span>
                <span className="text-crate-text-primary">{row.value}</span>
              </div>
            ))}

            {broadcaster.profile && (
              <>
                <div className="my-4 h-px w-full bg-crate-border" />
                <h4 className="mb-3 text-sm font-semibold text-crate-text-primary">プロフィール</h4>
                <div className="space-y-3">
                  <div className="flex justify-between text-sm">
                    <span className="text-crate-text-tertiary">ニックネーム</span>
                    <span className="text-crate-text-primary">{broadcaster.profile.nickname}</span>
                  </div>
                  {broadcaster.profile.message && (
                    <div className="flex justify-between text-sm">
                      <span className="text-crate-text-tertiary">メッセージ</span>
                      <span className="text-crate-text-primary">{broadcaster.profile.message}</span>
                    </div>
                  )}
                  <div className="flex justify-between text-sm">
                    <span className="text-crate-text-tertiary">フォロワー数</span>
                    <span className="text-crate-text-primary">{formatNumber(stats.follower_count)}</span>
                  </div>
                  <div className="flex justify-between text-sm">
                    <span className="text-crate-text-tertiary">フォロー中</span>
                    <span className="text-crate-text-primary">{formatNumber(stats.following_count)}</span>
                  </div>
                </div>
              </>
            )}
          </div>
        </div>
      </div>

      {/* Programs Table */}
      <div className="rounded-xl border border-crate-border bg-crate-surface">
        <div className="border-b border-crate-border px-5 py-4">
          <h3 className="text-sm font-semibold text-crate-text-primary">番組一覧</h3>
        </div>
        <div className="p-5">
          <DataTable
            columns={programColumns}
            data={broadcaster.programs}
            isLoading={false}
            emptyMessage="番組がありません"
          />
        </div>
      </div>
    </div>
  );
}
