"use client";

import { Users, Radio, PlayCircle, Heart, UserPlus, BookOpen, TrendingUp, TrendingDown, Activity } from "lucide-react";
import {
  useDashboardStats,
  useReports,
} from "@/hooks/use-api";
import { formatNumber } from "@/lib/utils";
import Link from "next/link";
import { ExportButton } from "@/components/ExportButton";
import type { LucideIcon } from "lucide-react";

// Mock trend data for KPI cards
const kpiTrends: Record<string, { percent: number; direction: "up" | "down" }> = {
  total_users: { percent: 12.3, direction: "up" },
  total_programs: { percent: 8.7, direction: "up" },
  published_programs: { percent: 5.2, direction: "up" },
  total_plays: { percent: 24.1, direction: "up" },
  total_favorites: { percent: 15.6, direction: "up" },
  total_follows: { percent: 3.2, direction: "down" },
};

// Mock recent activity
const recentActivity = [
  { id: "1", type: "user_signup", description: "新規ユーザー tanaka_yuki が登録", time: "2 minutes ago", icon: UserPlus },
  { id: "2", type: "program_publish", description: '番組「夜のジャズラジオ #45」が公開', time: "15 minutes ago", icon: Radio },
  { id: "3", type: "play_milestone", description: '「朝のクラシック」が再生数 10,000 を突破', time: "1 hour ago", icon: PlayCircle },
  { id: "4", type: "user_signup", description: "新規ユーザー music_fan_22 が登録", time: "2 hours ago", icon: UserPlus },
  { id: "5", type: "program_publish", description: '番組「Weekend Pop Mix」が公開', time: "3 hours ago", icon: Radio },
];

// Mock weekly plays data for bar chart
const weeklyPlays = [
  { label: "Mon", value: 1240 },
  { label: "Tue", value: 1580 },
  { label: "Wed", value: 980 },
  { label: "Thu", value: 2100 },
  { label: "Fri", value: 1850 },
  { label: "Sat", value: 2400 },
  { label: "Sun", value: 2200 },
];

const maxPlay = Math.max(...weeklyPlays.map((d) => d.value));

function KPICard({
  title,
  value,
  icon: Icon,
  accent = false,
  trendKey,
}: {
  title: string;
  value: number;
  icon: LucideIcon;
  accent?: boolean;
  trendKey?: string;
}) {
  const trend = trendKey ? kpiTrends[trendKey] : undefined;

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
      {trend && (
        <div className="mt-2 flex items-center gap-1">
          {trend.direction === "up" ? (
            <TrendingUp className="h-3.5 w-3.5 text-crate-success" />
          ) : (
            <TrendingDown className="h-3.5 w-3.5 text-crate-error" />
          )}
          <span
            className={`text-xs font-medium tabular-nums ${
              trend.direction === "up" ? "text-crate-success" : "text-crate-error"
            }`}
          >
            {trend.direction === "up" ? "+" : "-"}{trend.percent}%
          </span>
          <span className="text-xs text-crate-text-tertiary">vs last week</span>
        </div>
      )}
    </div>
  );
}

export default function DashboardPage() {
  const { data: statsData, isLoading: statsLoading } = useDashboardStats();
  const { data: reportsData, isLoading: reportsLoading } = useReports();

  const stats = statsData?.data;
  const topPrograms = reportsData?.data?.top_programs_by_plays || [];

  const activityExportData = recentActivity.map((a) => ({
    Type: a.type,
    Description: a.description,
    Time: a.time,
  }));

  return (
    <div className="space-y-6">
      <div>
        <h1 className="font-heading text-2xl font-bold text-crate-text-primary">
          CRATE Dashboard
        </h1>
        <p className="text-sm text-crate-text-secondary">Platform overview and key metrics</p>
      </div>

      {/* KPI Cards */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
        {statsLoading ? (
          Array.from({ length: 6 }).map((_, i) => (
            <div
              key={i}
              className="h-[120px] animate-pulse rounded-xl border border-crate-border bg-crate-surface"
            />
          ))
        ) : (
          <>
            <KPICard title="Total Users" value={stats?.total_users ?? 0} icon={Users} accent trendKey="total_users" />
            <KPICard title="Active Programs" value={stats?.total_programs ?? 0} icon={Radio} trendKey="total_programs" />
            <KPICard title="Total Plays" value={stats?.total_plays ?? 0} icon={PlayCircle} accent trendKey="total_plays" />
            <KPICard title="New Users (7d)" value={Math.round((stats?.total_users ?? 0) * 0.12)} icon={UserPlus} trendKey="total_follows" />
            <KPICard title="Total Favorites" value={stats?.total_favorites ?? 0} icon={Heart} trendKey="total_favorites" />
            <KPICard title="Published Programs" value={stats?.published_programs ?? 0} icon={BookOpen} trendKey="published_programs" />
          </>
        )}
      </div>

      {/* Bar Chart - Weekly Plays (CSS only) */}
      <div className="rounded-xl border border-crate-border bg-crate-surface">
        <div className="border-b border-crate-border px-5 py-4">
          <h2 className="text-sm font-semibold text-crate-text-primary">
            Weekly Play Count
          </h2>
        </div>
        <div className="p-5">
          <div className="flex items-end justify-between gap-3" style={{ height: "200px" }}>
            {weeklyPlays.map((day) => {
              const heightPercent = (day.value / maxPlay) * 100;
              return (
                <div key={day.label} className="flex flex-1 flex-col items-center gap-2">
                  <span className="text-xs tabular-nums text-crate-text-tertiary">
                    {formatNumber(day.value)}
                  </span>
                  <div className="w-full flex items-end" style={{ height: "160px" }}>
                    <div
                      className="w-full rounded-t-md bg-crate-accent transition-all duration-500 hover:bg-crate-accent-dim"
                      style={{ height: `${heightPercent}%` }}
                    />
                  </div>
                  <span className="text-xs font-medium text-crate-text-secondary">
                    {day.label}
                  </span>
                </div>
              );
            })}
          </div>
        </div>
      </div>

      <div className="grid gap-6 lg:grid-cols-2">
        {/* Recent Activity */}
        <div className="rounded-xl border border-crate-border bg-crate-surface">
          <div className="flex items-center justify-between border-b border-crate-border px-5 py-4">
            <h2 className="flex items-center gap-2 text-sm font-semibold text-crate-text-primary">
              <Activity className="h-4 w-4 text-crate-accent" />
              Recent Activity
            </h2>
            <ExportButton data={activityExportData} filename="recent_activity" label="Export" />
          </div>
          <div className="divide-y divide-crate-border/50">
            {recentActivity.map((event) => {
              const EventIcon = event.icon;
              return (
                <div
                  key={event.id}
                  className="flex items-center gap-3 px-5 py-3 transition-colors hover:bg-crate-elevated/50"
                >
                  <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-lg bg-crate-accent/10">
                    <EventIcon className="h-4 w-4 text-crate-accent" />
                  </div>
                  <div className="min-w-0 flex-1">
                    <p className="truncate text-sm text-crate-text-primary">
                      {event.description}
                    </p>
                    <p className="text-xs text-crate-text-tertiary">{event.time}</p>
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        {/* Popular Programs Ranking */}
        <div className="rounded-xl border border-crate-border bg-crate-surface">
          <div className="border-b border-crate-border px-5 py-4">
            <h2 className="text-sm font-semibold text-crate-text-primary">
              Top Programs (by plays)
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
                No data available
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
                      {formatNumber(program.play_count ?? 0)} plays
                    </span>
                  </Link>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
