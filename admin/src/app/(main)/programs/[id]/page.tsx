"use client";

import { useParams, useRouter } from "next/navigation";
import {
  ArrowLeft,
  EyeOff,
  Clock,
  PlayCircle,
  Heart,
  Music,
} from "lucide-react";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { useToast } from "@/components/ui/toast";
import {
  useProgram,
  useProgramTracks,
  useUpdateProgramStatus,
} from "@/hooks/use-api";
import { formatDateTime, formatNumber, formatDuration } from "@/lib/utils";

const statusMap: Record<string, { label: string; colorClass: string }> = {
  published: { label: "公開中", colorClass: "bg-crate-success/15 text-crate-success" },
  archived: { label: "アーカイブ", colorClass: "bg-yellow-500/15 text-yellow-400" },
  draft: { label: "下書き", colorClass: "bg-crate-elevated text-crate-text-tertiary" },
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
        <div className="h-8 w-48 animate-pulse rounded-lg bg-crate-surface" />
        <div className="h-64 animate-pulse rounded-xl bg-crate-surface" />
      </div>
    );
  }

  if (!program) {
    return (
      <div className="space-y-6">
        <button
          onClick={() => router.back()}
          className="flex items-center gap-2 text-sm text-crate-text-secondary hover:text-crate-text-primary"
        >
          <ArrowLeft className="h-4 w-4" />
          戻る
        </button>
        <p className="text-crate-text-tertiary">番組が見つかりません。</p>
      </div>
    );
  }

  const s = statusMap[program.status] || { label: program.status, colorClass: "bg-crate-elevated text-crate-text-tertiary" };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-4">
          <button
            onClick={() => router.back()}
            className="flex h-9 w-9 items-center justify-center rounded-lg border border-crate-border bg-crate-surface text-crate-text-secondary transition-colors hover:bg-crate-elevated hover:text-crate-text-primary"
          >
            <ArrowLeft className="h-4 w-4" />
          </button>
          <div>
            <h1 className="font-heading text-2xl font-bold text-crate-text-primary">番組詳細</h1>
            <p className="text-xs font-mono text-crate-text-tertiary">ID: {program.id}</p>
          </div>
        </div>
        <div className="flex items-center gap-2">
          {program.status === "published" && (
            <button
              onClick={handleArchive}
              className="flex items-center gap-2 rounded-lg border border-crate-border bg-crate-surface px-4 py-2 text-sm text-yellow-400 transition-colors hover:bg-yellow-500/10"
            >
              <EyeOff className="h-4 w-4" />
              アーカイブにする
            </button>
          )}
        </div>
      </div>

      {/* Program Info */}
      <div className="grid gap-6 md:grid-cols-3">
        {/* Thumbnail & Title */}
        <div className="rounded-xl border border-crate-border bg-crate-surface p-6 md:col-span-1">
          <div className="flex flex-col items-center">
            <Avatar className="h-32 w-32 rounded-xl border-2 border-crate-border bg-crate-elevated">
              {program.thumbnail_url && (
                <AvatarImage src={program.thumbnail_url} className="rounded-xl" />
              )}
              <AvatarFallback className="rounded-xl bg-crate-elevated text-3xl text-crate-text-tertiary">
                {program.title.charAt(0)}
              </AvatarFallback>
            </Avatar>
            <h2 className="mt-4 text-center text-xl font-semibold text-crate-text-primary">
              {program.title}
            </h2>
            <span className={`mt-2 inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium ${s.colorClass}`}>
              {s.label}
            </span>
          </div>
          <div className="my-4 h-px w-full bg-crate-border" />
          <div className="space-y-3">
            <div className="text-sm">
              <span className="text-crate-text-tertiary">配信者: </span>
              <span className="font-medium text-crate-text-primary">{program.user_nickname || program.user_id}</span>
            </div>
            {program.description && (
              <p className="text-sm text-crate-text-secondary">
                {program.description}
              </p>
            )}
          </div>
        </div>

        <div className="space-y-6 md:col-span-2">
          {/* Stats */}
          <div className="grid gap-4 sm:grid-cols-3">
            {[
              { icon: PlayCircle, label: "再生数", value: formatNumber(program.play_count) },
              { icon: Heart, label: "お気に入り数", value: formatNumber(program.favorite_count) },
              { icon: Clock, label: "再生時間", value: program.duration_seconds ? formatDuration(program.duration_seconds) : "-" },
            ].map((stat) => (
              <div key={stat.label} className="rounded-xl border border-crate-border bg-crate-surface p-4">
                <div className="flex items-center gap-3">
                  <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-crate-accent/10">
                    <stat.icon className="h-4 w-4 text-crate-accent" />
                  </div>
                  <div>
                    <p className="text-xs text-crate-text-tertiary">{stat.label}</p>
                    <p className="text-lg font-bold text-crate-text-primary">{stat.value}</p>
                  </div>
                </div>
              </div>
            ))}
          </div>

          {/* Details */}
          <div className="rounded-xl border border-crate-border bg-crate-surface">
            <div className="border-b border-crate-border px-5 py-4">
              <h3 className="text-sm font-semibold text-crate-text-primary">番組情報</h3>
            </div>
            <div className="p-5 space-y-3">
              {[
                { label: "番組ID", value: <span className="font-mono">{program.id}</span> },
                { label: "配信者ID", value: <span className="font-mono">{program.user_id}</span> },
                { label: "番組タイプ", value: program.program_type },
                { label: "作成日時", value: formatDateTime(program.created_at) },
                { label: "最終更新", value: formatDateTime(program.updated_at) },
                ...(program.scheduled_at
                  ? [{ label: "配信予定", value: formatDateTime(program.scheduled_at) }]
                  : []),
              ].map((row) => (
                <div key={row.label} className="flex justify-between text-sm">
                  <span className="text-crate-text-tertiary">{row.label}</span>
                  <span className="text-crate-text-primary">{row.value}</span>
                </div>
              ))}
            </div>
          </div>

          {/* Track List */}
          <div className="rounded-xl border border-crate-border bg-crate-surface">
            <div className="border-b border-crate-border px-5 py-4">
              <h3 className="text-sm font-semibold text-crate-text-primary">トラック一覧</h3>
            </div>
            <div className="p-5">
              {tracksLoading ? (
                <div className="space-y-3">
                  {Array.from({ length: 3 }).map((_, i) => (
                    <div key={i} className="h-12 animate-pulse rounded-lg bg-crate-elevated" />
                  ))}
                </div>
              ) : tracks.length === 0 ? (
                <p className="py-8 text-center text-sm text-crate-text-tertiary">
                  トラックがありません
                </p>
              ) : (
                <div className="overflow-x-auto">
                  <table className="w-full">
                    <thead>
                      <tr className="border-b border-crate-border text-left">
                        <th className="w-12 pb-3 text-xs font-medium text-crate-text-tertiary">#</th>
                        <th className="pb-3 text-xs font-medium text-crate-text-tertiary">タイトル</th>
                        <th className="pb-3 text-xs font-medium text-crate-text-tertiary">アーティスト</th>
                        <th className="pb-3 text-right text-xs font-medium text-crate-text-tertiary">再生時間</th>
                      </tr>
                    </thead>
                    <tbody>
                      {tracks.map((track) => (
                        <tr key={track.id} className="border-b border-crate-border/50 last:border-0">
                          <td className="py-3 text-sm text-crate-text-tertiary">
                            {track.track_order}
                          </td>
                          <td className="py-3">
                            <div className="flex items-center gap-2">
                              <Avatar className="h-8 w-8 rounded border border-crate-border bg-crate-elevated">
                                {track.artwork_url && <AvatarImage src={track.artwork_url} />}
                                <AvatarFallback className="rounded bg-crate-elevated">
                                  <Music className="h-3 w-3 text-crate-text-tertiary" />
                                </AvatarFallback>
                              </Avatar>
                              <span className="text-sm font-medium text-crate-text-primary">{track.title}</span>
                            </div>
                          </td>
                          <td className="py-3 text-sm text-crate-text-secondary">{track.artist_name}</td>
                          <td className="py-3 text-right text-sm tabular-nums text-crate-text-secondary">
                            {track.duration_seconds ? formatDuration(track.duration_seconds) : "-"}
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
