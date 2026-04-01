"use client";

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Skeleton } from "@/components/ui/skeleton";
import { Badge } from "@/components/ui/badge";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
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
  badge?: { label: string; variant: "default" | "secondary" | "destructive" | "outline" };
}) {
  return (
    <Card>
      <CardHeader className="pb-2">
        <CardTitle className="text-sm font-medium text-muted-foreground">
          {title}
        </CardTitle>
      </CardHeader>
      <CardContent>
        <div className="flex items-baseline gap-2">
          <span className="text-2xl font-bold">{value}</span>
          {badge && (
            <Badge variant={badge.variant} className="text-xs">
              {badge.label}
            </Badge>
          )}
        </div>
        {subtitle && (
          <p className="mt-1 text-xs text-muted-foreground">{subtitle}</p>
        )}
      </CardContent>
    </Card>
  );
}

function RankBadge({ rank }: { rank: number }) {
  if (rank <= 3) {
    const colors = [
      "bg-yellow-500 text-white",
      "bg-gray-400 text-white",
      "bg-amber-700 text-white",
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
    <span className="flex h-7 w-7 items-center justify-center rounded-full bg-muted text-xs font-medium text-muted-foreground">
      {rank}
    </span>
  );
}

export default function ReportsPage() {
  const { data: reportsData, isLoading: reportsLoading } = useReports();
  const { data: analyticsData, isLoading: analyticsLoading } = useDailyAnalytics(30);

  const topByPlays = reportsData?.data?.top_programs_by_plays || [];
  const topByFavorites = reportsData?.data?.top_programs_by_favorites || [];
  const dailyPlays = analyticsData?.data?.daily_plays || [];
  const summary = analyticsData?.data?.summary;

  const isLoading = reportsLoading || analyticsLoading;

  // Format chart data with short date labels (MM/DD)
  const chartData = dailyPlays.map((d) => {
    const dateObj = new Date(d.date);
    const label = `${dateObj.getMonth() + 1}/${dateObj.getDate()}`;
    return { date: label, count: d.count };
  });

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">レポート</h1>
        <p className="text-muted-foreground">
          再生データの分析と人気番組ランキング
        </p>
        {summary && (
          <p className="mt-1 text-xs text-muted-foreground">
            集計期間: {formatDate(summary.period_start)} ~ {formatDate(summary.period_end)}
            ({summary.period_days}日間)
          </p>
        )}
      </div>

      {/* Summary Stats */}
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        {isLoading ? (
          <>
            <Skeleton className="h-24" />
            <Skeleton className="h-24" />
            <Skeleton className="h-24" />
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
                label:
                  (summary?.growth_percent ?? 0) >= 0 ? "増加" : "減少",
                variant:
                  (summary?.growth_percent ?? 0) >= 0
                    ? "default"
                    : "destructive",
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

      <Tabs defaultValue="overview" className="space-y-6">
        <TabsList>
          <TabsTrigger value="overview">概要</TabsTrigger>
          <TabsTrigger value="plays">再生数ランキング</TabsTrigger>
          <TabsTrigger value="favorites">お気に入りランキング</TabsTrigger>
        </TabsList>

        {/* Overview Tab */}
        <TabsContent value="overview" className="space-y-6">
          {isLoading ? (
            <Skeleton className="h-[350px]" />
          ) : chartData.length === 0 ? (
            <Card>
              <CardContent className="py-12">
                <p className="text-center text-sm text-muted-foreground">
                  再生データがありません
                </p>
              </CardContent>
            </Card>
          ) : (
            <LineChartCard
              title="日別再生数 (過去30日間)"
              data={chartData}
              dataKey="count"
              xAxisKey="date"
              height={350}
            />
          )}
        </TabsContent>

        {/* Top by Plays */}
        <TabsContent value="plays" className="space-y-6">
          <Card>
            <CardHeader className="flex flex-row items-center justify-between">
              <CardTitle className="text-base">再生数トップ10</CardTitle>
              <Badge variant="outline" className="text-xs">
                公開中の番組
              </Badge>
            </CardHeader>
            <CardContent>
              {reportsLoading ? (
                <div className="space-y-3">
                  {Array.from({ length: 10 }).map((_, i) => (
                    <Skeleton key={i} className="h-12" />
                  ))}
                </div>
              ) : topByPlays.length === 0 ? (
                <p className="py-8 text-center text-sm text-muted-foreground">
                  データがありません
                </p>
              ) : (
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead className="w-14">順位</TableHead>
                      <TableHead>番組名</TableHead>
                      <TableHead className="w-32 text-right">再生数</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {topByPlays.map((program, index) => (
                      <TableRow key={program.id}>
                        <TableCell>
                          <RankBadge rank={index + 1} />
                        </TableCell>
                        <TableCell>
                          <Link
                            href={`/programs/${program.id}`}
                            className="font-medium hover:underline"
                          >
                            {program.title}
                          </Link>
                        </TableCell>
                        <TableCell className="text-right tabular-nums font-medium">
                          {formatNumber(program.play_count ?? 0)}
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              )}
            </CardContent>
          </Card>

          {/* Bar chart */}
          {!reportsLoading && topByPlays.length > 0 && (
            <BarChartCard
              title="上位番組の再生数比較"
              data={topByPlays.map((p) => ({
                name:
                  p.title.length > 10
                    ? p.title.slice(0, 10) + "..."
                    : p.title,
                play_count: p.play_count ?? 0,
              }))}
              dataKey="play_count"
              xAxisKey="name"
              height={300}
            />
          )}
        </TabsContent>

        {/* Top by Favorites */}
        <TabsContent value="favorites" className="space-y-6">
          <Card>
            <CardHeader className="flex flex-row items-center justify-between">
              <CardTitle className="text-base">お気に入りトップ10</CardTitle>
              <Badge variant="outline" className="text-xs">
                公開中の番組
              </Badge>
            </CardHeader>
            <CardContent>
              {reportsLoading ? (
                <div className="space-y-3">
                  {Array.from({ length: 10 }).map((_, i) => (
                    <Skeleton key={i} className="h-12" />
                  ))}
                </div>
              ) : topByFavorites.length === 0 ? (
                <p className="py-8 text-center text-sm text-muted-foreground">
                  データがありません
                </p>
              ) : (
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead className="w-14">順位</TableHead>
                      <TableHead>番組名</TableHead>
                      <TableHead className="w-32 text-right">お気に入り数</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {topByFavorites.map((program, index) => (
                      <TableRow key={program.id}>
                        <TableCell>
                          <RankBadge rank={index + 1} />
                        </TableCell>
                        <TableCell>
                          <Link
                            href={`/programs/${program.id}`}
                            className="font-medium hover:underline"
                          >
                            {program.title}
                          </Link>
                        </TableCell>
                        <TableCell className="text-right tabular-nums font-medium">
                          {formatNumber(program.favorite_count ?? 0)}
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              )}
            </CardContent>
          </Card>

          {/* Bar chart for favorites */}
          {!reportsLoading && topByFavorites.length > 0 && (
            <BarChartCard
              title="上位番組のお気に入り数比較"
              data={topByFavorites.map((p) => ({
                name:
                  p.title.length > 10
                    ? p.title.slice(0, 10) + "..."
                    : p.title,
                favorite_count: p.favorite_count ?? 0,
              }))}
              dataKey="favorite_count"
              xAxisKey="name"
              height={300}
            />
          )}
        </TabsContent>
      </Tabs>
    </div>
  );
}
