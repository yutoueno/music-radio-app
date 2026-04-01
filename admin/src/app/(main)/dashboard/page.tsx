"use client";

import { Users, Radio, PlayCircle, Heart, UserPlus, BookOpen } from "lucide-react";
import {
  useDashboardStats,
  useReports,
} from "@/hooks/use-api";
import { formatNumber } from "@/lib/utils";
import Link from "next/link";
import type { LucideIcon } from "lucide-react";

function KPICard({
  title,
  value,
  icon: Icon,
  accent = false,
}: {
  title: string;
  value: number;
  icon: LucideIcon;
  accent?: boolean;
}) {
  return (
    <div className="rounded-xl border border-crate-border bg-crate-surface p-5 transition-colors hover:border-crate-accent/30">
      <div className="flex items-center justify-between">
        <span className="text-xs font-medium uppercase tracking-wider text-crate-text-secondary">
          {title}
        </span>
        <Icon className={`h-4 w-4 ${accent ? "text-crate-accent" : "text-crate-text-tertiary"}`} />
      </div>
      <p className={`mt-3 text-3xl font-bold ${accent ? "text-crate-accent" : "text-crate-text-primary"}`}>
        {formatNumber(value)}
      </p>
    </div>
  );
}

export default function DashboardPage() {
  const { data: statsData, isLoading: statsLoading } = useDashboardStats();
  const { data: reportsData, isLoading: reportsLoading } = useReports();

  const stats = statsData?.data;
  const topPrograms = reportsData?.data?.top_programs_by_plays || [];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="font-heading text-2xl font-bold text-crate-text-primary">
          CRATE ダッシュボード
        </h1>
        <p className="text-sm text-crate-text-secondary">プラットフォームの概要</p>
      </div>

      {/* KPI Cards */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
        {statsLoading ? (
          Array.from({ length: 6 }).map((_, i) => (
            <div
              key={i}
              className="h-[104px] animate-pulse rounded-xl border border-crate-border bg-crate-surface"
            />
          ))
        ) : (
          <>
            <KPICard title="総ユーザー数" value={stats?.total_users ?? 0} icon={Users} accent />
            <KPICard title="総番組数" value={stats?.total_programs ?? 0} icon={Radio} />
            <KPICard title="公開中の番組" value={stats?.published_programs ?? 0} icon={BookOpen} />
            <KPICard title="総再生数" value={stats?.total_plays ?? 0} icon={PlayCircle} accent />
            <KPICard title="総お気に入り数" value={stats?.total_favorites ?? 0} icon={Heart} />
            <KPICard title="総フォロー数" value={stats?.total_follows ?? 0} icon={UserPlus} />
          </>
        )}
      </div>

      {/* Popular Programs Ranking */}
      <div className="rounded-xl border border-crate-border bg-crate-surface">
        <div className="border-b border-crate-border px-5 py-4">
          <h2 className="text-sm font-semibold text-crate-text-primary">
            人気番組ランキング (再生数順)
          </h2>
        </div>
        <div className="p-5">
          {reportsLoading ? (
            <div className="space-y-3">
              {Array.from({ length: 5 }).map((_, i) => (
                <div
                  key={i}
                  className="h-12 animate-pulse rounded-lg bg-crate-elevated"
                />
              ))}
            </div>
          ) : topPrograms.length === 0 ? (
            <p className="py-8 text-center text-sm text-crate-text-tertiary">
              データがありません
            </p>
          ) : (
            <div className="space-y-1">
              {topPrograms.slice(0, 10).map((program, index) => (
                <Link
                  key={program.id}
                  href={`/programs/${program.id}`}
                  className="flex items-center gap-3 rounded-lg px-3 py-2.5 transition-colors hover:bg-crate-elevated"
                >
                  <span
                    className={`flex h-7 w-7 items-center justify-center rounded-full text-xs font-bold ${
                      index < 3
                        ? "bg-crate-accent/20 text-crate-accent"
                        : "bg-crate-elevated text-crate-text-tertiary"
                    }`}
                  >
                    {index + 1}
                  </span>
                  <div className="min-w-0 flex-1">
                    <p className="truncate text-sm font-medium text-crate-text-primary">
                      {program.title}
                    </p>
                  </div>
                  <span className="text-xs tabular-nums text-crate-text-secondary">
                    {formatNumber(program.play_count ?? 0)} 再生
                  </span>
                </Link>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
