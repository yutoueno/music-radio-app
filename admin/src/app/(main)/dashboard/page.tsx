"use client";

import { Users, Radio, PlayCircle, Heart, UserPlus, BookOpen } from "lucide-react";
import { StatsCard } from "@/components/stats-card";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import {
  useDashboardStats,
  useReports,
} from "@/hooks/use-api";
import { formatNumber } from "@/lib/utils";
import Link from "next/link";

export default function DashboardPage() {
  const { data: statsData, isLoading: statsLoading } = useDashboardStats();
  const { data: reportsData, isLoading: reportsLoading } = useReports();

  const stats = statsData?.data;
  const topPrograms = reportsData?.data?.top_programs_by_plays || [];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">ダッシュボード</h1>
        <p className="text-muted-foreground">Music Radio の概要</p>
      </div>

      {/* KPI Cards */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
        {statsLoading ? (
          Array.from({ length: 6 }).map((_, i) => (
            <Skeleton key={i} className="h-32" />
          ))
        ) : (
          <>
            <StatsCard
              title="総ユーザー数"
              value={stats?.total_users ?? 0}
              icon={Users}
            />
            <StatsCard
              title="総番組数"
              value={stats?.total_programs ?? 0}
              icon={Radio}
            />
            <StatsCard
              title="公開中の番組"
              value={stats?.published_programs ?? 0}
              icon={BookOpen}
            />
            <StatsCard
              title="総再生数"
              value={stats?.total_plays ?? 0}
              icon={PlayCircle}
            />
            <StatsCard
              title="総お気に入り数"
              value={stats?.total_favorites ?? 0}
              icon={Heart}
            />
            <StatsCard
              title="総フォロー数"
              value={stats?.total_follows ?? 0}
              icon={UserPlus}
            />
          </>
        )}
      </div>

      {/* Popular Programs by plays */}
      <Card>
        <CardHeader>
          <CardTitle className="text-base">人気番組ランキング (再生数順)</CardTitle>
        </CardHeader>
        <CardContent>
          {reportsLoading ? (
            <div className="space-y-4">
              {Array.from({ length: 5 }).map((_, i) => (
                <Skeleton key={i} className="h-12" />
              ))}
            </div>
          ) : topPrograms.length === 0 ? (
            <p className="text-sm text-muted-foreground">
              データがありません
            </p>
          ) : (
            <div className="space-y-3">
              {topPrograms.slice(0, 10).map((program, index) => (
                <Link
                  key={program.id}
                  href={`/programs/${program.id}`}
                  className="flex items-center gap-3 rounded-md p-2 transition-colors hover:bg-muted"
                >
                  <span className="flex h-6 w-6 items-center justify-center rounded-full bg-primary/10 text-xs font-bold text-primary">
                    {index + 1}
                  </span>
                  <div className="min-w-0 flex-1">
                    <p className="truncate text-sm font-medium">
                      {program.title}
                    </p>
                  </div>
                  <span className="text-xs text-muted-foreground">
                    {formatNumber(program.play_count ?? 0)} 再生
                  </span>
                </Link>
              ))}
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
