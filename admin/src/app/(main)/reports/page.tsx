"use client";

import { useState } from "react";
import { BarChartCard, LineChartCard } from "@/components/chart";
import { useReports, useDailyAnalytics } from "@/hooks/use-api";
import { formatNumber, formatDate, formatPercentage } from "@/lib/utils";
import Link from "next/link";

function SummaryCard({
  title,
  value,
  subtitle,
  badge,
}: {
  title: string;
  value: string;
  subtitle?: string;
  badge?: { label: string; positive: boolean };
}) {
  return (
    <div className="rounded-xl border border-crate-border bg-crate-surface p-5">
      <p className="text-xs font-medium uppercase tracking-wider text-crate-text-tertiary">
        {title}
      </p>
      <div className="mt-2 flex items-baseline gap-2">
        <span className="text-2xl font-bold text-crate-text-primary">{value}</span>
        {badge && (
          <span
            className={`inline-flex items-center rounded-full px-2 py-0.5 text-xs font-medium ${
              badge.positive
                ? "bg-crate-success/15 text-crate-success"
                : "bg-crate-error/15 text-crate-error"
            }`}
          >
            {badge.label}
          </span>
        )}
      </div>
      {subtitle && (
        <p className="mt-1 text-xs text-crate-text-tertiary">{subtitle}</p>
      )}
    </div>
  );
}

function RankBadge({ rank }: { rank: number }) {
  if (rank <= 3) {
    const colors = [
      "bg-yellow-500/20 text-yellow-400",
      "bg-gray-400/20 text-gray-300",
      "bg-amber-700/20 text-amber-500",
    ];
    return (
      <span
        className={`flex h-7 w-7 items-center justify-center rounded-full text-xs font-bold ${colors[rank - 1]}`}
      >
        {rank}
      </span>
    );
  }
  return (
    <span className="flex h-7 w-7 items-center justify-center rounded-full bg-crate-elevated text-xs font-medium text-crate-text-tertiary">
      {rank}
    </span>
  );
}

export default function ReportsPage() {
  const [activeTab, setActiveTab] = useState<"overview" | "plays" | "favorites">("overview");
  const { data: reportsData, isLoading: reportsLoading } = useReports();
  const { data: analyticsData, isLoading: analyticsLoading } = useDailyAnalytics(30);

  const topByPlays = reportsData?.data?.top_programs_by_plays || [];
  const topByFavorites = reportsData?.data?.top_programs_by_favorites || [];
  const dailyPlays = analyticsData?.data?.daily_plays || [];
  const summary = analyticsData?.data?.summary;

  const isLoading = reportsLoading || analyticsLoading;

  const chartData = dailyPlays.map((d) => {
    const dateObj = new Date(d.date);
    const label = `${dateObj.getMonth() + 1}/${dateObj.getDate()}`;
    return { date: label, count: d.count };
  });

  const tabs = [
    { key: "overview" as const, label: "概要" },
    { key: "plays" as const, label: "再生数ランキング" },
    { key: "favorites" as const, label: "お気に入りランキング" },
  ];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="font-heading text-2xl font-bold text-crate-text-primary">レポート</h1>
        <p className="text-sm text-crate-text-secondary">
          再生データの分析と人気番組ランキング
        </p>
        {summary && (
          <p className="mt-1 text-xs text-crate-text-tertiary">
            集計期間: {formatDate(summary.period_start)} ~ {formatDate(summary.period_end)}
            ({summary.period_days}日間)
          </p>
        )}
      </div>

      {/* Summary Stats */}
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        {isLoading ? (
          <>
            {Array.from({ length: 3 }).map((_, i) => (
              <div key={i} className="h-24 animate-pulse rounded-xl border border-crate-border bg-crate-surface" />
            ))}
          </>
        ) : (
          <>
            <SummaryCard
              title="今月の総再生数"
              value={formatNumber(summary?.total_plays ?? 0)}
              subtitle={`過去${summary?.period_days ?? 30}日間の再生数`}
            />
            <SummaryCard
              title="前期比成長率"
              value={formatPercentage(summary?.growth_percent ?? 0)}
              badge={{
                label: (summary?.growth_percent ?? 0) >= 0 ? "増加" : "減少",
                positive: (summary?.growth_percent ?? 0) >= 0,
              }}
              subtitle="前の同期間との比較"
            />
            <SummaryCard
              title="最もアクティブな日"
              value={
                summary?.most_active_day
                  ? formatDate(summary.most_active_day)
                  : "-"
              }
              subtitle={
                summary?.most_active_count
                  ? `${formatNumber(summary.most_active_count)} 再生`
                  : "データなし"
              }
            />
          </>
        )}
      </div>

      {/* Tabs */}
      <div className="border-b border-crate-border">
        <div className="flex gap-1">
          {tabs.map((tab) => (
            <button
              key={tab.key}
              onClick={() => setActiveTab(tab.key)}
              className={`px-4 py-2.5 text-sm font-medium transition-colors ${
                activeTab === tab.key
                  ? "border-b-2 border-crate-accent text-crate-accent"
                  : "text-crate-text-tertiary hover:text-crate-text-secondary"
              }`}
            >
              {tab.label}
            </button>
          ))}
        </div>
      </div>

      {/* Tab Content */}
      {activeTab === "overview" && (
        <div className="space-y-6">
          {isLoading ? (
            <div className="h-[350px] animate-pulse rounded-xl border border-crate-border bg-crate-surface" />
          ) : chartData.length === 0 ? (
            <div className="rounded-xl border border-crate-border bg-crate-surface py-12">
              <p className="text-center text-sm text-crate-text-tertiary">
                再生データがありません
              </p>
            </div>
          ) : (
            <LineChartCard
              title="日別再生数 (過去30日間)"
              data={chartData}
              dataKey="count"
              xAxisKey="date"
              height={350}
            />
          )}
        </div>
      )}

      {activeTab === "plays" && (
        <div className="space-y-6">
          <div className="rounded-xl border border-crate-border bg-crate-surface">
            <div className="flex items-center justify-between border-b border-crate-border px-5 py-4">
              <h3 className="text-sm font-semibold text-crate-text-primary">再生数トップ10</h3>
              <span className="inline-flex items-center rounded-full border border-crate-border px-2.5 py-0.5 text-xs text-crate-text-tertiary">
                公開中の番組
              </span>
            </div>
            <div className="p-5">
              {reportsLoading ? (
                <div className="space-y-3">
                  {Array.from({ length: 10 }).map((_, i) => (
                    <div key={i} className="h-12 animate-pulse rounded-lg bg-crate-elevated" />
                  ))}
                </div>
              ) : topByPlays.length === 0 ? (
                <p className="py-8 text-center text-sm text-crate-text-tertiary">
                  データがありません
                </p>
              ) : (
                <div className="overflow-x-auto">
                  <table className="w-full">
                    <thead>
                      <tr className="border-b border-crate-border text-left">
                        <th className="w-14 pb-3 text-xs font-medium text-crate-text-tertiary">順位</th>
                        <th className="pb-3 text-xs font-medium text-crate-text-tertiary">番組名</th>
                        <th className="w-32 pb-3 text-right text-xs font-medium text-crate-text-tertiary">再生数</th>
                      </tr>
                    </thead>
                    <tbody>
                      {topByPlays.map((program, index) => (
                        <tr key={program.id} className="border-b border-crate-border/50 last:border-0">
                          <td className="py-3">
                            <RankBadge rank={index + 1} />
                          </td>
                          <td className="py-3">
                            <Link
                              href={`/programs/${program.id}`}
                              className="font-medium text-crate-text-primary hover:text-crate-accent"
                            >
                              {program.title}
                            </Link>
                          </td>
                          <td className="py-3 text-right tabular-nums font-medium text-crate-text-primary">
                            {formatNumber(program.play_count ?? 0)}
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              )}
            </div>
          </div>

          {!reportsLoading && topByPlays.length > 0 && (
            <BarChartCard
              title="上位番組の再生数比較"
              data={topByPlays.map((p) => ({
                name: p.title.length > 10 ? p.title.slice(0, 10) + "..." : p.title,
                play_count: p.play_count ?? 0,
              }))}
              dataKey="play_count"
              xAxisKey="name"
              height={300}
            />
          )}
        </div>
      )}

      {activeTab === "favorites" && (
        <div className="space-y-6">
          <div className="rounded-xl border border-crate-border bg-crate-surface">
            <div className="flex items-center justify-between border-b border-crate-border px-5 py-4">
              <h3 className="text-sm font-semibold text-crate-text-primary">お気に入りトップ10</h3>
              <span className="inline-flex items-center rounded-full border border-crate-border px-2.5 py-0.5 text-xs text-crate-text-tertiary">
                公開中の番組
              </span>
            </div>
            <div className="p-5">
              {reportsLoading ? (
                <div className="space-y-3">
                  {Array.from({ length: 10 }).map((_, i) => (
                    <div key={i} className="h-12 animate-pulse rounded-lg bg-crate-elevated" />
                  ))}
                </div>
              ) : topByFavorites.length === 0 ? (
                <p className="py-8 text-center text-sm text-crate-text-tertiary">
                  データがありません
                </p>
              ) : (
                <div className="overflow-x-auto">
                  <table className="w-full">
                    <thead>
                      <tr className="border-b border-crate-border text-left">
                        <th className="w-14 pb-3 text-xs font-medium text-crate-text-tertiary">順位</th>
                        <th className="pb-3 text-xs font-medium text-crate-text-tertiary">番組名</th>
                        <th className="w-32 pb-3 text-right text-xs font-medium text-crate-text-tertiary">お気に入り数</th>
                      </tr>
                    </thead>
                    <tbody>
                      {topByFavorites.map((program, index) => (
                        <tr key={program.id} className="border-b border-crate-border/50 last:border-0">
                          <td className="py-3">
                            <RankBadge rank={index + 1} />
                          </td>
                          <td className="py-3">
                            <Link
                              href={`/programs/${program.id}`}
                              className="font-medium text-crate-text-primary hover:text-crate-accent"
                            >
                              {program.title}
                            </Link>
                          </td>
                          <td className="py-3 text-right tabular-nums font-medium text-crate-text-primary">
                            {formatNumber(program.favorite_count ?? 0)}
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              )}
            </div>
          </div>

          {!reportsLoading && topByFavorites.length > 0 && (
            <BarChartCard
              title="上位番組のお気に入り数比較"
              data={topByFavorites.map((p) => ({
                name: p.title.length > 10 ? p.title.slice(0, 10) + "..." : p.title,
                favorite_count: p.favorite_count ?? 0,
              }))}
              dataKey="favorite_count"
              xAxisKey="name"
              height={300}
            />
          )}
        </div>
      )}
    </div>
  );
}
