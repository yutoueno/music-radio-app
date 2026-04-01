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
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Separator } from "@/components/ui/separator";
import { Skeleton } from "@/components/ui/skeleton";
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

const statusVariants: Record<string, "default" | "success" | "secondary" | "destructive"> = {
  draft: "secondary",
  published: "success",
  archived: "default",
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
      toast({
        title: "アカウントを停止しました",
        variant: "success",
      });
    } catch {
      toast({ title: "エラーが発生しました", variant: "destructive" });
    }
  };

  const handleActivate = async () => {
    if (!broadcaster) return;
    try {
      await activateUser.mutateAsync(broadcaster.id);
      toast({
        title: "アカウントを有効化しました",
        variant: "success",
      });
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
          className="font-medium hover:underline"
        >
          {program.title}
        </Link>
      ),
    },
    {
      key: "status",
      header: "ステータス",
      render: (program) => (
        <Badge variant={statusVariants[program.status] || "secondary"}>
          {statusLabels[program.status] || program.status}
        </Badge>
      ),
    },
    {
      key: "play_count",
      header: "再生数",
      render: (program) => formatNumber(program.play_count),
    },
    {
      key: "favorite_count",
      header: "お気に入り",
      render: (program) => formatNumber(program.favorite_count),
    },
    {
      key: "track_count",
      header: "楽曲数",
      render: (program) => program.track_count,
    },
    {
      key: "genre",
      header: "ジャンル",
      render: (program) => program.genre || "-",
    },
    {
      key: "created_at",
      header: "作成日",
      render: (program) => formatDate(program.created_at),
    },
  ];

  if (isLoading) {
    return (
      <div className="space-y-6">
        <Skeleton className="h-8 w-48" />
        <div className="grid gap-6 md:grid-cols-3">
          <Skeleton className="h-64" />
          <Skeleton className="h-64 md:col-span-2" />
        </div>
        <Skeleton className="h-64" />
      </div>
    );
  }

  if (!broadcaster) {
    return (
      <div className="space-y-6">
        <Button variant="ghost" onClick={() => router.back()}>
          <ArrowLeft className="mr-2 h-4 w-4" />
          戻る
        </Button>
        <p className="text-muted-foreground">配信者が見つかりません。</p>
      </div>
    );
  }

  const stats = broadcaster.stats;

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-4">
          <Button variant="ghost" size="icon" onClick={() => router.back()}>
            <ArrowLeft className="h-4 w-4" />
          </Button>
          <div>
            <h1 className="text-2xl font-bold">配信者詳細</h1>
            <p className="text-muted-foreground">ID: {broadcaster.id}</p>
          </div>
        </div>
        <div className="flex items-center gap-2">
          {broadcaster.is_active ? (
            <Button variant="outline" onClick={handleSuspend}>
              <UserX className="mr-2 h-4 w-4" />
              アカウント停止
            </Button>
          ) : (
            <Button variant="outline" onClick={handleActivate}>
              <UserCheck className="mr-2 h-4 w-4" />
              有効化
            </Button>
          )}
        </div>
      </div>

      {/* Stats Summary */}
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <Card>
          <CardContent className="flex items-center gap-3 pt-6">
            <div className="rounded-lg bg-blue-100 p-2 dark:bg-blue-900">
              <Radio className="h-5 w-5 text-blue-600 dark:text-blue-400" />
            </div>
            <div>
              <p className="text-sm text-muted-foreground">番組数</p>
              <p className="text-2xl font-bold">{formatNumber(stats.total_programs)}</p>
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="flex items-center gap-3 pt-6">
            <div className="rounded-lg bg-green-100 p-2 dark:bg-green-900">
              <Play className="h-5 w-5 text-green-600 dark:text-green-400" />
            </div>
            <div>
              <p className="text-sm text-muted-foreground">総再生数</p>
              <p className="text-2xl font-bold">{formatNumber(stats.total_plays)}</p>
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="flex items-center gap-3 pt-6">
            <div className="rounded-lg bg-red-100 p-2 dark:bg-red-900">
              <Heart className="h-5 w-5 text-red-600 dark:text-red-400" />
            </div>
            <div>
              <p className="text-sm text-muted-foreground">総お気に入り</p>
              <p className="text-2xl font-bold">{formatNumber(stats.total_favorites)}</p>
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="flex items-center gap-3 pt-6">
            <div className="rounded-lg bg-purple-100 p-2 dark:bg-purple-900">
              <Users className="h-5 w-5 text-purple-600 dark:text-purple-400" />
            </div>
            <div>
              <p className="text-sm text-muted-foreground">フォロワー</p>
              <p className="text-2xl font-bold">{formatNumber(stats.follower_count)}</p>
            </div>
          </CardContent>
        </Card>
      </div>

      <div className="grid gap-6 md:grid-cols-3">
        {/* Profile Card */}
        <Card className="md:col-span-1">
          <CardContent className="flex flex-col items-center pt-6">
            <Avatar className="h-20 w-20">
              {avatarUrl && <AvatarImage src={avatarUrl} />}
              <AvatarFallback className="text-2xl">
                {displayName.charAt(0)}
              </AvatarFallback>
            </Avatar>
            <h2 className="mt-4 text-xl font-semibold">{displayName}</h2>
            {broadcaster.profile?.message && (
              <p className="mt-1 text-center text-sm text-muted-foreground">
                {broadcaster.profile.message}
              </p>
            )}
            <div className="mt-3 flex gap-2">
              <Badge
                variant={broadcaster.is_active ? "success" : "destructive"}
              >
                {broadcaster.is_active ? "有効" : "停止中"}
              </Badge>
              {broadcaster.is_admin && (
                <Badge variant="default">管理者</Badge>
              )}
            </div>
            <Separator className="my-4" />
            <div className="w-full space-y-3">
              <div className="flex items-center gap-2 text-sm">
                <Mail className="h-4 w-4 text-muted-foreground" />
                <span className="text-muted-foreground">{broadcaster.email}</span>
              </div>
              <div className="flex items-center gap-2 text-sm">
                <Calendar className="h-4 w-4 text-muted-foreground" />
                <span className="text-muted-foreground">
                  {formatDateTime(broadcaster.created_at)} 登録
                </span>
              </div>
              <div className="flex items-center gap-2 text-sm">
                <Users className="h-4 w-4 text-muted-foreground" />
                <span className="text-muted-foreground">
                  フォロワー {formatNumber(stats.follower_count)} / フォロー中 {formatNumber(stats.following_count)}
                </span>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Details */}
        <Card className="md:col-span-2">
          <CardHeader>
            <CardTitle className="text-base">詳細情報</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-2">
              <div className="flex justify-between text-sm">
                <span className="text-muted-foreground">ユーザーID</span>
                <span className="font-mono">{broadcaster.id}</span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="text-muted-foreground">メールアドレス</span>
                <span>{broadcaster.email}</span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="text-muted-foreground">アクティブ</span>
                <span>{broadcaster.is_active ? "はい" : "いいえ"}</span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="text-muted-foreground">メール認証</span>
                <span>{broadcaster.email_verified ? "認証済み" : "未認証"}</span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="text-muted-foreground">登録日時</span>
                <span>{formatDateTime(broadcaster.created_at)}</span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="text-muted-foreground">最終更新</span>
                <span>{formatDateTime(broadcaster.updated_at)}</span>
              </div>
            </div>

            {broadcaster.profile && (
              <>
                <Separator className="my-6" />
                <h3 className="mb-3 text-sm font-semibold">プロフィール</h3>
                <div className="space-y-2">
                  <div className="flex justify-between text-sm">
                    <span className="text-muted-foreground">ニックネーム</span>
                    <span>{broadcaster.profile.nickname}</span>
                  </div>
                  {broadcaster.profile.message && (
                    <div className="flex justify-between text-sm">
                      <span className="text-muted-foreground">メッセージ</span>
                      <span>{broadcaster.profile.message}</span>
                    </div>
                  )}
                  <div className="flex justify-between text-sm">
                    <span className="text-muted-foreground">フォロワー数</span>
                    <span>{formatNumber(stats.follower_count)}</span>
                  </div>
                  <div className="flex justify-between text-sm">
                    <span className="text-muted-foreground">フォロー中</span>
                    <span>{formatNumber(stats.following_count)}</span>
                  </div>
                </div>
              </>
            )}
          </CardContent>
        </Card>
      </div>

      {/* Programs Table */}
      <Card>
        <CardHeader>
          <CardTitle className="text-base">番組一覧</CardTitle>
        </CardHeader>
        <CardContent>
          <DataTable
            columns={programColumns}
            data={broadcaster.programs}
            isLoading={false}
            emptyMessage="番組がありません"
          />
        </CardContent>
      </Card>
    </div>
  );
}
