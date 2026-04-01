"use client";

import { useState } from "react";
import Link from "next/link";
import { Search, MoreHorizontal, UserX, UserCheck } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { DataTable, type Column } from "@/components/data-table";
import { Pagination } from "@/components/pagination";
import { useToast } from "@/components/ui/toast";
import {
  useUsers,
  useSuspendUser,
  useActivateUser,
} from "@/hooks/use-api";
import { formatDate } from "@/lib/utils";
import type { User } from "@/types";

function getUserDisplayName(user: User): string {
  return user.profile?.nickname || user.email;
}

function getUserAvatarUrl(user: User): string | null {
  return user.profile?.avatar_url || null;
}

export default function UsersPage() {
  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState<string>("");
  const [page, setPage] = useState(1);

  const { toast } = useToast();

  const { data, isLoading } = useUsers({
    page,
    per_page: 20,
  });

  const suspendUser = useSuspendUser();
  const activateUser = useActivateUser();

  // Client-side filtering since backend doesn't support search/filter params
  let users = data?.data || [];
  const meta = data?.meta;

  // Client-side search filter
  if (search) {
    const s = search.toLowerCase();
    users = users.filter(
      (u) =>
        getUserDisplayName(u).toLowerCase().includes(s) ||
        u.email.toLowerCase().includes(s)
    );
  }

  // Client-side status filter
  if (statusFilter === "active") {
    users = users.filter((u) => u.is_active);
  } else if (statusFilter === "suspended") {
    users = users.filter((u) => !u.is_active);
  }

  const handleSuspend = async (user: User) => {
    try {
      await suspendUser.mutateAsync(user.id);
      toast({
        title: "ユーザーを停止しました",
        description: `${getUserDisplayName(user)} のアカウントを停止しました。`,
        variant: "success",
      });
    } catch (error) {
      toast({
        title: "エラー",
        description: "操作に失敗しました。",
        variant: "destructive",
      });
    }
  };

  const handleActivate = async (user: User) => {
    try {
      await activateUser.mutateAsync(user.id);
      toast({
        title: "ユーザーを有効化しました",
        description: `${getUserDisplayName(user)} のアカウントを有効化しました。`,
        variant: "success",
      });
    } catch (error) {
      toast({
        title: "エラー",
        description: "操作に失敗しました。",
        variant: "destructive",
      });
    }
  };

  const columns: Column<User>[] = [
    {
      key: "nickname",
      header: "ユーザー",
      render: (user) => (
        <Link
          href={`/users/${user.id}`}
          className="flex items-center gap-3 hover:underline"
        >
          <Avatar className="h-8 w-8">
            {getUserAvatarUrl(user) && <AvatarImage src={getUserAvatarUrl(user)!} />}
            <AvatarFallback className="text-xs">
              {getUserDisplayName(user).charAt(0)}
            </AvatarFallback>
          </Avatar>
          <div>
            <p className="font-medium">{getUserDisplayName(user)}</p>
            <p className="text-xs text-muted-foreground">{user.email}</p>
          </div>
        </Link>
      ),
    },
    {
      key: "is_admin",
      header: "ロール",
      render: (user) => (
        <Badge variant={user.is_admin ? "default" : "secondary"}>
          {user.is_admin ? "管理者" : "ユーザー"}
        </Badge>
      ),
    },
    {
      key: "is_active",
      header: "ステータス",
      render: (user) => (
        <Badge
          variant={user.is_active ? "success" : "destructive"}
        >
          {user.is_active ? "有効" : "停止中"}
        </Badge>
      ),
    },
    {
      key: "email_verified",
      header: "メール認証",
      render: (user) => (
        <Badge variant={user.email_verified ? "success" : "secondary"}>
          {user.email_verified ? "認証済み" : "未認証"}
        </Badge>
      ),
    },
    {
      key: "created_at",
      header: "登録日",
      render: (user) => formatDate(user.created_at),
    },
    {
      key: "actions",
      header: "",
      className: "w-10",
      render: (user) => (
        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <Button variant="ghost" size="icon" className="h-8 w-8">
              <MoreHorizontal className="h-4 w-4" />
            </Button>
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end">
            <DropdownMenuItem asChild>
              <Link href={`/users/${user.id}`}>詳細を表示</Link>
            </DropdownMenuItem>
            <DropdownMenuSeparator />
            {user.is_active ? (
              <DropdownMenuItem onClick={() => handleSuspend(user)}>
                <UserX className="mr-2 h-4 w-4" />
                アカウント停止
              </DropdownMenuItem>
            ) : (
              <DropdownMenuItem onClick={() => handleActivate(user)}>
                <UserCheck className="mr-2 h-4 w-4" />
                有効化
              </DropdownMenuItem>
            )}
          </DropdownMenuContent>
        </DropdownMenu>
      ),
    },
  ];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">ユーザー管理</h1>
        <p className="text-muted-foreground">
          登録ユーザーの一覧と管理
        </p>
      </div>

      {/* Filters */}
      <div className="flex flex-wrap items-center gap-4">
        <div className="relative flex-1 min-w-[200px] max-w-sm">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          <Input
            placeholder="名前やメールで検索..."
            value={search}
            onChange={(e) => {
              setSearch(e.target.value);
            }}
            className="pl-9"
          />
        </div>
        <Select
          value={statusFilter}
          onValueChange={(v) => {
            setStatusFilter(v === "all" ? "" : v);
          }}
        >
          <SelectTrigger className="w-[140px]">
            <SelectValue placeholder="ステータス" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">すべて</SelectItem>
            <SelectItem value="active">有効</SelectItem>
            <SelectItem value="suspended">停止中</SelectItem>
          </SelectContent>
        </Select>
      </div>

      {/* Table */}
      <div className="rounded-md border bg-card">
        <DataTable
          columns={columns}
          data={users}
          isLoading={isLoading}
        />
        {meta && <Pagination meta={meta} onPageChange={setPage} />}
      </div>
    </div>
  );
}
