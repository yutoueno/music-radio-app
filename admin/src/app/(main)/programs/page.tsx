"use client";

import { useState, useRef, useEffect } from "react";
import Link from "next/link";
import { Search, MoreHorizontal, EyeOff, Play, Pause } from "lucide-react";
import { ExportButton } from "@/components/ExportButton";
import { Button } from "@/components/ui/button";
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
  usePrograms,
  useUpdateProgramStatus,
  useGenres,
} from "@/hooks/use-api";
import { formatDate, formatNumber, formatDuration } from "@/lib/utils";
import type { Program } from "@/types";

const statusMap: Record<string, { label: string; colorClass: string }> = {
  published: { label: "公開中", colorClass: "bg-crate-success/15 text-crate-success" },
  archived: { label: "アーカイブ", colorClass: "bg-yellow-500/15 text-yellow-400" },
  draft: { label: "下書き", colorClass: "bg-crate-elevated text-crate-text-tertiary" },
};

function MiniWaveform({ isPlaying }: { isPlaying: boolean }) {
  return (
    <div className="flex items-end gap-[2px] h-4">
      {[0.4, 0.7, 0.5, 1, 0.6, 0.8, 0.3, 0.9, 0.5, 0.7, 0.4, 0.6].map((h, i) => (
        <div
          key={i}
          className={`w-[2px] rounded-full transition-all duration-300 ${
            isPlaying ? "bg-crate-accent" : "bg-crate-text-tertiary"
          }`}
          style={{
            height: `${h * 100}%`,
            animation: isPlaying ? `waveform 0.8s ease-in-out ${i * 0.06}s infinite alternate` : "none",
          }}
        />
      ))}
      <style jsx>{`
        @keyframes waveform {
          0% { transform: scaleY(0.3); }
          100% { transform: scaleY(1); }
        }
      `}</style>
    </div>
  );
}

function AudioPreviewButton({ audioUrl }: { audioUrl: string | null }) {
  const [isPlaying, setIsPlaying] = useState(false);
  const audioRef = useRef<HTMLAudioElement | null>(null);

  useEffect(() => {
    return () => {
      if (audioRef.current) {
        audioRef.current.pause();
        audioRef.current = null;
      }
    };
  }, []);

  const togglePlay = (e: React.MouseEvent) => {
    e.preventDefault();
    e.stopPropagation();

    if (!audioUrl) return;

    if (isPlaying && audioRef.current) {
      audioRef.current.pause();
      setIsPlaying(false);
    } else {
      if (!audioRef.current) {
        audioRef.current = new Audio(audioUrl);
        audioRef.current.addEventListener("ended", () => setIsPlaying(false));
      }
      audioRef.current.play().catch(() => setIsPlaying(false));
      setIsPlaying(true);
    }
  };

  return (
    <button
      onClick={togglePlay}
      disabled={!audioUrl}
      className="flex items-center gap-2 rounded-lg px-2 py-1.5 transition-colors hover:bg-crate-elevated disabled:opacity-30 disabled:cursor-not-allowed"
    >
      <div className="flex h-6 w-6 items-center justify-center rounded-full bg-crate-accent/15">
        {isPlaying ? (
          <Pause className="h-3 w-3 text-crate-accent" />
        ) : (
          <Play className="h-3 w-3 text-crate-accent ml-0.5" />
        )}
      </div>
      <MiniWaveform isPlaying={isPlaying} />
    </button>
  );
}

const sortOptions = [
  { value: "created_at:desc", label: "新着順" },
  { value: "play_count:desc", label: "再生数順" },
  { value: "favorite_count:desc", label: "お気に入り順" },
  { value: "created_at:asc", label: "古い順" },
];

export default function ProgramsPage() {
  const [search, setSearch] = useState("");
  const [status, setStatus] = useState<string>("");
  const [genre, setGenre] = useState<string>("");
  const [sort, setSort] = useState<string>("created_at:desc");
  const [page, setPage] = useState(1);

  const { toast } = useToast();

  const [sortBy, sortOrder] = sort.split(":") as [string, string];

  const { data, isLoading } = usePrograms({
    status: status || undefined,
    genre: genre || undefined,
    sort_by: sortBy,
    sort_order: sortOrder as "asc" | "desc",
    page,
    per_page: 20,
  });

  const { data: genresData } = useGenres();
  const genres = genresData?.data || [];

  const updateProgramStatus = useUpdateProgramStatus();

  let programs = data?.data || [];
  const meta = data?.meta;

  if (search) {
    const s = search.toLowerCase();
    programs = programs.filter(
      (p) =>
        p.title.toLowerCase().includes(s) ||
        (p.user_nickname || "").toLowerCase().includes(s)
    );
  }

  const handleArchive = async (program: Program) => {
    try {
      await updateProgramStatus.mutateAsync({ id: program.id, status: "archived" });
      toast({
        title: "番組をアーカイブしました",
        description: `「${program.title}」をアーカイブしました。`,
        variant: "success",
      });
    } catch {
      toast({ title: "エラーが発生しました", variant: "destructive" });
    }
  };

  const columns: Column<Program>[] = [
    {
      key: "title",
      header: "番組",
      render: (program) => (
        <Link
          href={`/programs/${program.id}`}
          className="flex items-center gap-3 hover:opacity-80"
        >
          <Avatar className="h-10 w-10 rounded-lg border border-crate-border bg-crate-elevated">
            {program.thumbnail_url && <AvatarImage src={program.thumbnail_url} className="rounded-lg" />}
            <AvatarFallback className="rounded-lg bg-crate-elevated text-xs text-crate-text-secondary">
              {program.title.charAt(0)}
            </AvatarFallback>
          </Avatar>
          <div>
            <p className="font-medium text-crate-text-primary">{program.title}</p>
            <p className="text-xs text-crate-text-tertiary">
              {program.user_nickname || program.user_id}
            </p>
          </div>
        </Link>
      ),
    },
    {
      key: "audio_preview",
      header: "Preview",
      className: "w-28",
      render: (program) => (
        <AudioPreviewButton audioUrl={program.audio_url} />
      ),
    },
    {
      key: "status",
      header: "ステータス",
      render: (program) => {
        const s = statusMap[program.status] || { label: program.status, colorClass: "bg-crate-elevated text-crate-text-tertiary" };
        return (
          <span className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium ${s.colorClass}`}>
            {s.label}
          </span>
        );
      },
    },
    {
      key: "genre",
      header: "ジャンル",
      render: (program) => (
        <span className="text-sm text-crate-text-secondary">{program.genre || "-"}</span>
      ),
    },
    {
      key: "duration_seconds",
      header: "再生時間",
      render: (program) => (
        <span className="text-sm text-crate-text-secondary">
          {program.duration_seconds ? formatDuration(program.duration_seconds) : "-"}
        </span>
      ),
    },
    {
      key: "play_count",
      header: "再生数",
      render: (program) => (
        <span className="text-sm tabular-nums text-crate-text-primary">{formatNumber(program.play_count)}</span>
      ),
    },
    {
      key: "favorite_count",
      header: "お気に入り",
      render: (program) => (
        <span className="text-sm tabular-nums text-crate-text-secondary">{formatNumber(program.favorite_count)}</span>
      ),
    },
    {
      key: "created_at",
      header: "作成日",
      render: (program) => (
        <span className="text-sm text-crate-text-secondary">{formatDate(program.created_at)}</span>
      ),
    },
    {
      key: "actions",
      header: "",
      className: "w-10",
      render: (program) => (
        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <Button variant="ghost" size="icon" className="h-8 w-8 text-crate-text-tertiary hover:bg-crate-elevated hover:text-crate-text-primary">
              <MoreHorizontal className="h-4 w-4" />
            </Button>
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end" className="border-crate-border bg-crate-elevated text-crate-text-primary">
            <DropdownMenuItem asChild className="focus:bg-crate-surface">
              <Link href={`/programs/${program.id}`}>詳細を表示</Link>
            </DropdownMenuItem>
            <DropdownMenuSeparator className="bg-crate-border" />
            {program.status === "published" && (
              <DropdownMenuItem onClick={() => handleArchive(program)} className="text-yellow-400 focus:bg-yellow-500/10 focus:text-yellow-400">
                <EyeOff className="mr-2 h-4 w-4" />
                アーカイブにする
              </DropdownMenuItem>
            )}
          </DropdownMenuContent>
        </DropdownMenu>
      ),
    },
  ];

  const selectClass = "rounded-lg border border-crate-border bg-crate-elevated px-3 py-2 text-sm text-crate-text-primary outline-none focus:border-crate-accent";

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="font-heading text-2xl font-bold text-crate-text-primary">番組管理</h1>
          <p className="text-sm text-crate-text-secondary">登録番組の一覧と管理</p>
        </div>
        <ExportButton
          data={programs.map((p) => ({
            Title: p.title,
            Status: p.status,
            Genre: p.genre || "-",
            Play_Count: p.play_count,
            Favorite_Count: p.favorite_count,
            Duration: p.duration_seconds ? formatDuration(p.duration_seconds) : "-",
            Created: formatDate(p.created_at),
          }))}
          filename="programs"
        />
      </div>

      {/* Filters */}
      <div className="flex flex-wrap items-center gap-4">
        <div className="relative flex-1 min-w-[200px] max-w-sm">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-crate-text-tertiary" />
          <input
            placeholder="番組名や配信者名で検索..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full rounded-lg border border-crate-border bg-crate-elevated py-2 pl-9 pr-4 text-sm text-crate-text-primary placeholder:text-crate-text-tertiary outline-none transition-colors focus:border-crate-accent"
          />
        </div>
        <select
          value={status || "all"}
          onChange={(e) => { setStatus(e.target.value === "all" ? "" : e.target.value); setPage(1); }}
          className={selectClass}
        >
          <option value="all">すべて</option>
          <option value="published">公開中</option>
          <option value="archived">アーカイブ</option>
          <option value="draft">下書き</option>
        </select>
        <select
          value={genre || "all"}
          onChange={(e) => { setGenre(e.target.value === "all" ? "" : e.target.value); setPage(1); }}
          className={selectClass}
        >
          <option value="all">すべてのジャンル</option>
          {genres.map((g) => (
            <option key={g.genre} value={g.genre}>
              {g.genre} ({g.count})
            </option>
          ))}
        </select>
        <select
          value={sort}
          onChange={(e) => { setSort(e.target.value); setPage(1); }}
          className={selectClass}
        >
          {sortOptions.map((opt) => (
            <option key={opt.value} value={opt.value}>
              {opt.label}
            </option>
          ))}
        </select>
      </div>

      {/* Table */}
      <div className="rounded-xl border border-crate-border bg-crate-surface">
        <DataTable
          columns={columns}
          data={programs}
          isLoading={isLoading}
        />
        {meta && <Pagination meta={meta} onPageChange={setPage} />}
      </div>
    </div>
  );
}
