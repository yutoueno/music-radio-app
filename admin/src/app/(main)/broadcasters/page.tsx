"use client";

import { useState } from "react";
import Link from "next/link";
import { Search } from "lucide-react";
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

  const { data, isLoading } = useUsers({
    page,
    per_page: 20,
  });

  let users = data?.data || [];
  const meta = data?.meta;

  if (search) {
    const s = search.toLowerCase();
    users = users.filter(
      (u) =>
        getUserDisplayName(u).toLowerCase().includes(s) ||
        u.email.toLowerCase().includes(s)
    );
  }

  const broadcasters = users.filter((u) => u.profile !== null);

  const columns: Column<User>[] = [
    {
      key: "nickname",
      header: "配信者",
      render: (user) => (
        <Link
          href={`/broadcasters/${user.id}`}
          className="flex items-center gap-3 hover:opacity-80"
        >
          <Avatar className="h-8 w-8 border border-crate-border bg-crate-elevated">
            {getUserAvatarUrl(user) && <AvatarImage src={getUserAvatarUrl(user)!} />}
            <AvatarFallback className="bg-crate-elevated text-xs text-crate-text-secondary">
              {getUserDisplayName(user).charAt(0)}
            </AvatarFallback>
          </Avatar>
          <div>
            <p className="font-medium text-crate-text-primary">{getUserDisplayName(user)}</p>
            <p className="text-xs text-crate-text-tertiary">{user.email}</p>
          </div>
        </Link>
      ),
    },
    {
      key: "is_active",
      header: "ステータス",
      render: (user) => (
        <span
          className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium ${
            user.is_active
              ? "bg-crate-success/15 text-crate-success"
              : "bg-crate-error/15 text-crate-error"
          }`}
        >
          {user.is_active ? "有効" : "停止中"}
        </span>
      ),
    },
    {
      key: "follower_count",
      header: "フォロワー数",
      render: (user) => (
        <span className="text-sm tabular-nums text-crate-text-primary">
          {user.profile?.follower_count ?? 0}
        </span>
      ),
    },
    {
      key: "created_at",
      header: "登録日",
      render: (user) => (
        <span className="text-sm text-crate-text-secondary">{formatDate(user.created_at)}</span>
      ),
    },
  ];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="font-heading text-2xl font-bold text-crate-text-primary">配信者管理</h1>
        <p className="text-sm text-crate-text-secondary">
          プロフィールを持つユーザーの一覧
        </p>
      </div>

      <div className="flex flex-wrap items-center gap-4">
        <div className="relative flex-1 min-w-[200px] max-w-sm">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-crate-text-tertiary" />
          <input
            placeholder="名前やメールで検索..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full rounded-lg border border-crate-border bg-crate-elevated py-2 pl-9 pr-4 text-sm text-crate-text-primary placeholder:text-crate-text-tertiary outline-none transition-colors focus:border-crate-accent"
          />
        </div>
      </div>

      <div className="rounded-xl border border-crate-border bg-crate-surface">
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
