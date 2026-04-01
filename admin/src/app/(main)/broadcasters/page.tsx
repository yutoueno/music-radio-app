"use client";

import { useState } from "react";
import Link from "next/link";
import { Search } from "lucide-react";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { DataTable, type Column } from "@/components/data-table";
import { Pagination } from "@/components/pagination";
import { useUsers } from "@/hooks/use-api";
import { formatDate } from "@/lib/utils";
import type { User } from "@/types";

function getUserDisplayName(user: User): string {
  return user.profile?.nickname || user.email;
}

function getUserAvatarUrl(user: User): string | null {
  return user.profile?.avatar_url || null;
}

export default function BroadcastersPage() {
  const [search, setSearch] = useState("");
  const [page, setPage] = useState(1);

  // Use the users endpoint -- backend doesn't have a separate broadcasters endpoint
  // We list all users here; admin can see them all
  const { data, isLoading } = useUsers({
    page,
    per_page: 20,
  });

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

  // Filter to only users with profiles (likely broadcasters)
  // Since the backend doesn't have a role field, we show all users with profiles
  const broadcasters = users.filter((u) => u.profile !== null);

  const columns: Column<User>[] = [
    {
      key: "nickname",
      header: "配信者",
      render: (user) => (
        <Link
          href={`/broadcasters/${user.id}`}
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
      key: "is_active",
      header: "ステータス",
      render: (user) => (
        <Badge variant={user.is_active ? "success" : "destructive"}>
          {user.is_active ? "有効" : "停止中"}
        </Badge>
      ),
    },
    {
      key: "follower_count",
      header: "フォロワー数",
      render: (user) => user.profile?.follower_count ?? 0,
    },
    {
      key: "created_at",
      header: "登録日",
      render: (user) => formatDate(user.created_at),
    },
  ];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">配信者管理</h1>
        <p className="text-muted-foreground">
          プロフィールを持つユーザーの一覧
        </p>
      </div>

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
      </div>

      <div className="rounded-md border bg-card">
        <DataTable
          columns={columns}
          data={broadcasters}
          isLoading={isLoading}
          emptyMessage="配信者がいません"
        />
        {meta && <Pagination meta={meta} onPageChange={setPage} />}
      </div>
    </div>
  );
}
