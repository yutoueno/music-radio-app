"use client";

import { useParams, useRouter } from "next/navigation";
import { ArrowLeft, UserX, UserCheck, Mail, Calendar, Shield } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Separator } from "@/components/ui/separator";
import { Skeleton } from "@/components/ui/skeleton";
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
      toast({
        title: "アカウントを停止しました",
        variant: "success",
      });
    } catch {
      toast({ title: "エラーが発生しました", variant: "destructive" });
    }
  };

  const handleActivate = async () => {
    if (!user) return;
    try {
      await activateUser.mutateAsync(user.id);
      toast({
        title: "アカウントを有効化しました",
        variant: "success",
      });
    } catch {
      toast({ title: "エラーが発生しました", variant: "destructive" });
    }
  };

  if (isLoading) {
    return (
      <div className="space-y-6">
        <Skeleton className="h-8 w-48" />
        <Skeleton className="h-64" />
      </div>
    );
  }

  if (!user) {
    return (
      <div className="space-y-6">
        <Button variant="ghost" onClick={() => router.back()}>
          <ArrowLeft className="mr-2 h-4 w-4" />
          戻る
        </Button>
        <p className="text-muted-foreground">ユーザーが見つかりません。</p>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-4">
          <Button variant="ghost" size="icon" onClick={() => router.back()}>
            <ArrowLeft className="h-4 w-4" />
          </Button>
          <div>
            <h1 className="text-2xl font-bold">ユーザー詳細</h1>
            <p className="text-muted-foreground">ID: {user.id}</p>
          </div>
        </div>
        <div className="flex items-center gap-2">
          {user.is_active ? (
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
            <div className="mt-2 flex gap-2">
              <Badge
                variant={user.is_admin ? "default" : "secondary"}
              >
                {user.is_admin ? "管理者" : "ユーザー"}
              </Badge>
              <Badge
                variant={user.is_active ? "success" : "destructive"}
              >
                {user.is_active ? "有効" : "停止中"}
              </Badge>
            </div>
            <Separator className="my-4" />
            <div className="w-full space-y-3">
              <div className="flex items-center gap-2 text-sm">
                <Mail className="h-4 w-4 text-muted-foreground" />
                <span className="text-muted-foreground">{user.email}</span>
              </div>
              <div className="flex items-center gap-2 text-sm">
                <Calendar className="h-4 w-4 text-muted-foreground" />
                <span className="text-muted-foreground">
                  {formatDateTime(user.created_at)} 登録
                </span>
              </div>
              <div className="flex items-center gap-2 text-sm">
                <Shield className="h-4 w-4 text-muted-foreground" />
                <span className="text-muted-foreground">
                  メール認証: {user.email_verified ? "済み" : "未認証"}
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
                <span className="font-mono">{user.id}</span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="text-muted-foreground">メールアドレス</span>
                <span>{user.email}</span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="text-muted-foreground">アクティブ</span>
                <span>{user.is_active ? "はい" : "いいえ"}</span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="text-muted-foreground">管理者</span>
                <span>{user.is_admin ? "はい" : "いいえ"}</span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="text-muted-foreground">メール認証</span>
                <span>{user.email_verified ? "認証済み" : "未認証"}</span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="text-muted-foreground">登録日時</span>
                <span>{formatDateTime(user.created_at)}</span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="text-muted-foreground">最終更新</span>
                <span>{formatDateTime(user.updated_at)}</span>
              </div>
            </div>

            {user.profile && (
              <>
                <Separator className="my-6" />
                <h3 className="mb-3 text-sm font-semibold">プロフィール</h3>
                <div className="space-y-2">
                  <div className="flex justify-between text-sm">
                    <span className="text-muted-foreground">ニックネーム</span>
                    <span>{user.profile.nickname}</span>
                  </div>
                  {user.profile.message && (
                    <div className="flex justify-between text-sm">
                      <span className="text-muted-foreground">メッセージ</span>
                      <span>{user.profile.message}</span>
                    </div>
                  )}
                  <div className="flex justify-between text-sm">
                    <span className="text-muted-foreground">フォロワー数</span>
                    <span>{user.profile.follower_count}</span>
                  </div>
                </div>
              </>
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
