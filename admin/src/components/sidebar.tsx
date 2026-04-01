"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import {
  LayoutDashboard,
  Users,
  Radio,
  Mic2,
  MessageSquare,
  BarChart3,
  LogOut,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { useAuthStore } from "@/stores/auth-store";

const navigation = [
  { name: "ダッシュボード", href: "/dashboard", icon: LayoutDashboard },
  { name: "ユーザー管理", href: "/users", icon: Users },
  { name: "番組管理", href: "/programs", icon: Radio },
  { name: "配信者管理", href: "/broadcasters", icon: Mic2 },
  { name: "お問い合わせ", href: "/inquiries", icon: MessageSquare },
  { name: "レポート", href: "/reports", icon: BarChart3 },
];

export function Sidebar() {
  const pathname = usePathname();
  const { logout } = useAuthStore();

  return (
    <div className="flex h-full w-64 flex-col border-r border-crate-border bg-crate-surface">
      {/* CRATE Logo */}
      <div className="flex h-16 items-center gap-3 px-6">
        <span className="font-heading text-xl font-bold uppercase tracking-[4px] text-crate-text-primary">
          CRATE
        </span>
        <span className="rounded-pill bg-crate-accent px-2 py-0.5 text-[10px] font-semibold uppercase tracking-wider text-white">
          ADMIN
        </span>
      </div>

      {/* Separator */}
      <div className="mx-4 h-px bg-crate-border" />

      {/* Navigation */}
      <nav className="flex-1 space-y-1 px-3 py-4">
        {navigation.map((item) => {
          const isActive =
            pathname === item.href || pathname.startsWith(item.href + "/");
          return (
            <Link
              key={item.name}
              href={item.href}
              className={cn(
                "flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium transition-all duration-150",
                isActive
                  ? "bg-crate-accent/10 text-crate-accent"
                  : "text-crate-text-tertiary hover:bg-crate-elevated hover:text-crate-text-secondary"
              )}
            >
              <item.icon
                className={cn(
                  "h-[18px] w-[18px]",
                  isActive ? "text-crate-accent" : "text-crate-text-tertiary"
                )}
                strokeWidth={1.5}
              />
              {item.name}
            </Link>
          );
        })}
      </nav>

      {/* Separator */}
      <div className="mx-4 h-px bg-crate-border" />

      {/* Logout */}
      <div className="p-3">
        <button
          onClick={logout}
          className="flex w-full items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium text-crate-text-tertiary transition-all duration-150 hover:bg-crate-elevated hover:text-crate-text-secondary"
        >
          <LogOut className="h-[18px] w-[18px]" strokeWidth={1.5} />
          ログアウト
        </button>
      </div>
    </div>
  );
}
