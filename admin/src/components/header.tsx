"use client";

import { useAuthStore } from "@/stores/auth-store";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { LogOut } from "lucide-react";

export function Header() {
  const { admin, logout } = useAuthStore();

  return (
    <header className="flex h-14 items-center justify-between border-b border-crate-border bg-crate-surface px-6">
      <div />
      <div className="flex items-center gap-4">
        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <button className="flex items-center gap-2 rounded-lg px-2 py-1.5 transition-colors hover:bg-crate-elevated">
              <Avatar className="h-8 w-8 border border-crate-border bg-crate-elevated">
                <AvatarFallback className="bg-crate-elevated text-xs text-crate-text-secondary">
                  {admin?.name?.charAt(0) || "A"}
                </AvatarFallback>
              </Avatar>
              <span className="text-sm font-medium text-crate-text-primary">
                {admin?.name || "管理者"}
              </span>
            </button>
          </DropdownMenuTrigger>
          <DropdownMenuContent
            align="end"
            className="w-48 border-crate-border bg-crate-elevated text-crate-text-primary"
          >
            <DropdownMenuLabel className="text-crate-text-secondary">
              マイアカウント
            </DropdownMenuLabel>
            <DropdownMenuSeparator className="bg-crate-border" />
            <DropdownMenuItem
              onClick={logout}
              className="text-crate-error focus:bg-crate-error/10 focus:text-crate-error"
            >
              <LogOut className="mr-2 h-4 w-4" />
              ログアウト
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      </div>
    </header>
  );
}
