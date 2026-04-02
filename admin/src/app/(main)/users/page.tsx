"use client";

import { useState } from "react";
import Link from "next/link";
import { Search, MoreHorizontal, UserX, UserCheck } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { ExportButton } from "@/components/ExportButton";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
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
import { formatDate, formatDateTime } from "@/lib/utils";
import type { User } from "@/types";

type UserRole = "admin" | "broadcaster" | "listener";

function getUserRole(user: User): UserRole {
  if (user.is_admin) return "admin";
  // Heuristic: if user has a profile with a follower_count > 0, they are likely a broadcaster
  if (user.profile && user.profile.follower_count > 0) return "broadcaster";
  return "listener";
}

const roleConfig: Record<UserRole, { label: string; colorClass: string }> = {
  admin: { label: "Admin", colorClass: "bg-crate-accent/15 text-crate-accent" },
  broadcaster: { label: "Broadcaster", colorClass: "bg-yellow-500/15 text-yellow-400" },
  listener: { label: "Listener", colorClass: "bg-crate-elevated text-crate-text-secondary" },
};

function getLastActive(user: User): string {
  // Use updated_at as a proxy for last active
  return user.updated_at;
}

function getUserDisplayName(user: User): string {
  return user.profile?.nickname || user.email;
}

function getUserAvatarUrl(user: User): string | null {
  return user.profile?.avatar_url || null;
}

export default function UsersPage() {
  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState<string>("");
  const [roleFilter, setRoleFilter] = useState<string>("");
  const [page, setPage] = useState(1);

  const { toast } = useToast();

  const { data, isLoading } = useUsers({
    page,
    per_page: 20,
  });

  const suspendUser = useSuspendUser();
  const activateUser = useActivateUser();

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

  if (statusFilter === "active") {
    users = users.filter((u) => u.is_active);
  } else if (statusFilter === "suspended") {
    users = users.filter((u) => !u.is_active);
  }

  if (roleFilter) {
    users = users.filter((u) => getUserRole(u) === roleFilter);
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
      key: "role",
      header: "Role",
      render: (user) => {
        const role = getUserRole(user);
        const config = roleConfig[role];
        return (
          <span
            className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium ${config.colorClass}`}
          >
            {config.label}
          </span>
        );
      },
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
      key: "email_verified",
      header: "メール認証",
      render: (user) => (
        <span
          className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium ${
            user.email_verified
              ? "bg-crate-success/15 text-crate-success"
              : "bg-crate-elevated text-crate-text-tertiary"
          }`}
        >
          {user.email_verified ? "認証済み" : "未認証"}
        </span>
      ),
    },
    {
      key: "created_at",
      header: "登録日",
      render: (user) => (
        <span className="text-sm text-crate-text-secondary">
          {formatDate(user.created_at)}
        </span>
      ),
    },
    {
      key: "last_active",
      header: "Last Active",
      render: (user) => (
        <span className="text-sm text-crate-text-secondary">
          {formatDateTime(getLastActive(user))}
        </span>
      ),
    },
    {
      key: "actions",
      header: "",
      className: "w-10",
      render: (user) => (
        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <Button variant="ghost" size="icon" className="h-8 w-8 text-crate-text-tertiary hover:bg-crate-elevated hover:text-crate-text-primary">
              <MoreHorizontal className="h-4 w-4" />
            </Button>
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end" className="border-crate-border bg-crate-elevated text-crate-text-primary">
            <DropdownMenuItem asChild className="focus:bg-crate-surface">
              <Link href={`/users/${user.id}`}>詳細を表示</Link>
            </DropdownMenuItem>
            <DropdownMenuSeparator className="bg-crate-border" />
            {user.is_active ? (
              <DropdownMenuItem onClick={() => handleSuspend(user)} className="text-crate-error focus:bg-crate-error/10 focus:text-crate-error">
                <UserX className="mr-2 h-4 w-4" />
                アカウント停止
              </DropdownMenuItem>
            ) : (
              <DropdownMenuItem onClick={() => handleActivate(user)} className="text-crate-success focus:bg-crate-success/10 focus:text-crate-success">
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
      <div className="flex items-center justify-between">
        <div>
          <h1 className="font-heading text-2xl font-bold text-crate-text-primary">ユーザー管理</h1>
          <p className="text-sm text-crate-text-secondary">
            登録ユーザーの一覧と管理
          </p>
        </div>
        <ExportButton
          data={users.map((u) => ({
            Name: getUserDisplayName(u),
            Email: u.email,
            Role: roleConfig[getUserRole(u)].label,
            Status: u.is_active ? "Active" : "Suspended",
            Email_Verified: u.email_verified ? "Yes" : "No",
            Registered: formatDate(u.created_at),
            Last_Active: formatDateTime(getLastActive(u)),
          }))}
          filename="users"
        />
      </div>

      {/* Filters */}
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
        <select
          value={statusFilter}
          onChange={(e) => setStatusFilter(e.target.value === "all" ? "" : e.target.value)}
          className="rounded-lg border border-crate-border bg-crate-elevated px-3 py-2 text-sm text-crate-text-primary outline-none focus:border-crate-accent"
        >
          <option value="all">すべて</option>
          <option value="active">有効</option>
          <option value="suspended">停止中</option>
        </select>
        <select
          value={roleFilter}
          onChange={(e) => setRoleFilter(e.target.value === "all" ? "" : e.target.value)}
          className="rounded-lg border border-crate-border bg-crate-elevated px-3 py-2 text-sm text-crate-text-primary outline-none focus:border-crate-accent"
        >
          <option value="all">All Roles</option>
          <option value="admin">Admin</option>
          <option value="broadcaster">Broadcaster</option>
          <option value="listener">Listener</option>
        </select>
      </div>

      {/* Table */}
      <div className="rounded-xl border border-crate-border bg-crate-surface">
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
