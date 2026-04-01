"use client";

import { useParams, useRouter } from "next/navigation";
import {
  ArrowLeft,
  EyeOff,
  Clock,
  PlayCircle,
  Heart,
  Music,
  ListMusic,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Separator } from "@/components/ui/separator";
import { Skeleton } from "@/components/ui/skeleton";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { useToast } from "@/components/ui/toast";
import {
  useProgram,
  useProgramTracks,
  useUpdateProgramStatus,
} from "@/hooks/use-api";
import { formatDateTime, formatNumber, formatDuration } from "@/lib/utils";

const statusMap: Record<string, { label: string; variant: "success" | "warning" | "secondary" }> = {
  published: { label: "公開中", variant: "success" },
  archived: { label: "アーカイブ", variant: "warning" },
  draft: { label: "下書き", variant: "secondary" },
};

export default function ProgramDetailPage() {
  const params = useParams();
  const router = useRouter();
  const { toast } = useToast();
  const id = params.id as string;

  const { data: programData, isLoading: programLoading } = useProgram(id);
  const { data: tracksData, isLoading: tracksLoading } = useProgramTracks(id);
  const updateProgramStatus = useUpdateProgramStatus();

  const program = programData?.data;
  const tracks = tracksData?.data || [];

  const handleArchive = async () => {
    if (!program) return;
    try {
      await updateProgramStatus.mutateAsync({ id: program.id, status: "archived" });
      toast({ title: "番組をアーカイブしました", variant: "success" });
    } catch {
      toast({ title: "エラーが発生しました", variant: "destructive" });
    }
  };

  if (programLoading) {
    return (
      <div className="space-y-6">
        <Skeleton className="h-8 w-48" />
        <Skeleton className="h-64" />
      </div>
    );
  }

  if (!program) {
    return (
      <div className="space-y-6">
        <Button variant="ghost" onClick={() => router.back()}>
          <ArrowLeft className="mr-2 h-4 w-4" />
          戻る
        </Button>
        <p className="text-muted-foreground">番組が見つかりません。</p>
      </div>
    );
  }

  const s = statusMap[program.status] || { label: program.status, variant: "secondary" as const };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-4">
          <Button variant="ghost" size="icon" onClick={() => router.back()}>
            <ArrowLeft className="h-4 w-4" />
          </Button>
          <div>
            <h1 className="text-2xl font-bold">番組詳細</h1>
            <p className="text-muted-foreground">ID: {program.id}</p>
          </div>
        </div>
        <div className="flex items-center gap-2">
          {program.status === "published" && (
            <Button variant="outline" onClick={handleArchive}>
              <EyeOff className="mr-2 h-4 w-4" />
              アーカイブにする
            </Button>
          )}
        </div>
      </div>

      {/* Program Info */}
      <div className="grid gap-6 md:grid-cols-3">
        <Card className="md:col-span-1">
          <CardContent className="pt-6">
            <div className="flex flex-col items-center">
              <Avatar className="h-32 w-32 rounded-lg">
                {program.thumbnail_url && (
                  <AvatarImage src={program.thumbnail_url} className="rounded-lg" />
                )}
                <AvatarFallback className="rounded-lg text-3xl">
                  {program.title.charAt(0)}
                </AvatarFallback>
              </Avatar>
              <h2 className="mt-4 text-center text-xl font-semibold">
                {program.title}
              </h2>
              <Badge variant={s.variant} className="mt-2">
                {s.label}
              </Badge>
            </div>
            <Separator className="my-4" />
            <div className="space-y-3">
              <div className="text-sm">
                <span className="text-muted-foreground">配信者: </span>
                <span className="font-medium">{program.user_nickname || program.user_id}</span>
              </div>
              {program.description && (
                <p className="text-sm text-muted-foreground">
                  {program.description}
                </p>
              )}
            </div>
          </CardContent>
        </Card>

        <div className="space-y-6 md:col-span-2">
          {/* Stats */}
          <div className="grid gap-4 sm:grid-cols-3">
            <Card>
              <CardContent className="flex items-center gap-3 pt-6">
                <div className="rounded-full bg-primary/10 p-2">
                  <PlayCircle className="h-4 w-4 text-primary" />
                </div>
                <div>
                  <p className="text-xs text-muted-foreground">再生数</p>
                  <p className="text-lg font-bold">
                    {formatNumber(program.play_count)}
                  </p>
                </div>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="flex items-center gap-3 pt-6">
                <div className="rounded-full bg-primary/10 p-2">
                  <Heart className="h-4 w-4 text-primary" />
                </div>
                <div>
                  <p className="text-xs text-muted-foreground">お気に入り数</p>
                  <p className="text-lg font-bold">
                    {formatNumber(program.favorite_count)}
                  </p>
                </div>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="flex items-center gap-3 pt-6">
                <div className="rounded-full bg-primary/10 p-2">
                  <Clock className="h-4 w-4 text-primary" />
                </div>
                <div>
                  <p className="text-xs text-muted-foreground">再生時間</p>
                  <p className="text-lg font-bold">
                    {program.duration_seconds
                      ? formatDuration(program.duration_seconds)
                      : "-"}
                  </p>
                </div>
              </CardContent>
            </Card>
          </div>

          {/* Details */}
          <Card>
            <CardHeader>
              <CardTitle className="text-base">番組情報</CardTitle>
            </CardHeader>
            <CardContent className="space-y-2">
              <div className="flex justify-between text-sm">
                <span className="text-muted-foreground">番組ID</span>
                <span className="font-mono">{program.id}</span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="text-muted-foreground">配信者ID</span>
                <span className="font-mono">{program.user_id}</span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="text-muted-foreground">番組タイプ</span>
                <span>{program.program_type}</span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="text-muted-foreground">作成日時</span>
                <span>{formatDateTime(program.created_at)}</span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="text-muted-foreground">最終更新</span>
                <span>{formatDateTime(program.updated_at)}</span>
              </div>
              {program.scheduled_at && (
                <div className="flex justify-between text-sm">
                  <span className="text-muted-foreground">配信予定</span>
                  <span>{formatDateTime(program.scheduled_at)}</span>
                </div>
              )}
            </CardContent>
          </Card>

          {/* Track List */}
          <Card>
            <CardHeader>
              <CardTitle className="text-base">トラック一覧</CardTitle>
            </CardHeader>
            <CardContent>
              {tracksLoading ? (
                <div className="space-y-3">
                  {Array.from({ length: 3 }).map((_, i) => (
                    <Skeleton key={i} className="h-12" />
                  ))}
                </div>
              ) : tracks.length === 0 ? (
                <p className="py-8 text-center text-sm text-muted-foreground">
                  トラックがありません
                </p>
              ) : (
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead className="w-12">#</TableHead>
                      <TableHead>タイトル</TableHead>
                      <TableHead>アーティスト</TableHead>
                      <TableHead className="text-right">再生時間</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {tracks.map((track) => (
                      <TableRow key={track.id}>
                        <TableCell className="text-muted-foreground">
                          {track.track_order}
                        </TableCell>
                        <TableCell>
                          <div className="flex items-center gap-2">
                            <Avatar className="h-8 w-8 rounded">
                              {track.artwork_url && (
                                <AvatarImage src={track.artwork_url} />
                              )}
                              <AvatarFallback className="rounded">
                                <Music className="h-3 w-3" />
                              </AvatarFallback>
                            </Avatar>
                            <span className="font-medium">{track.title}</span>
                          </div>
                        </TableCell>
                        <TableCell>{track.artist_name}</TableCell>
                        <TableCell className="text-right">
                          {track.duration_seconds
                            ? formatDuration(track.duration_seconds)
                            : "-"}
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              )}
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}
