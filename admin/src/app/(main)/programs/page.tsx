"use client";

import { useState } from "react";
import Link from "next/link";
import { Search, MoreHorizontal, EyeOff, Trash2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
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

const statusMap: Record<string, { label: string; variant: "success" | "warning" | "secondary" }> = {
  published: { label: "公開中", variant: "success" },
  archived: { label: "アーカイブ", variant: "warning" },
  draft: { label: "下書き", variant: "secondary" },
};

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

  // Client-side search filter
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
          className="flex items-center gap-3 hover:underline"
        >
          <Avatar className="h-10 w-10 rounded-md">
            {program.thumbnail_url && (
              <AvatarImage src={program.thumbnail_url} />
            )}
            <AvatarFallback className="rounded-md text-xs">
              {program.title.charAt(0)}
            </AvatarFallback>
          </Avatar>
          <div>
            <p className="font-medium">{program.title}</p>
            <p className="text-xs text-muted-foreground">
              {program.user_nickname || program.user_id}
            </p>
          </div>
        </Link>
      ),
    },
    {
      key: "status",
      header: "ステータス",
      render: (program) => {
        const s = statusMap[program.status] || { label: program.status, variant: "secondary" as const };
        return <Badge variant={s.variant}>{s.label}</Badge>;
      },
    },
    {
      key: "genre",
      header: "ジャンル",
      render: (program) => program.genre || "-",
    },
    {
      key: "duration_seconds",
      header: "再生時間",
      render: (program) => program.duration_seconds ? formatDuration(program.duration_seconds) : "-",
    },
    {
      key: "play_count",
      header: "再生数",
      render: (program) => formatNumber(program.play_count),
    },
    {
      key: "favorite_count",
      header: "お気に入り",
      render: (program) => formatNumber(program.favorite_count),
    },
    {
      key: "created_at",
      header: "作成日",
      render: (program) => formatDate(program.created_at),
    },
    {
      key: "actions",
      header: "",
      className: "w-10",
      render: (program) => (
        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <Button variant="ghost" size="icon" className="h-8 w-8">
              <MoreHorizontal className="h-4 w-4" />
            </Button>
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end">
            <DropdownMenuItem asChild>
              <Link href={`/programs/${program.id}`}>詳細を表示</Link>
            </DropdownMenuItem>
            <DropdownMenuSeparator />
            {program.status === "published" && (
              <DropdownMenuItem onClick={() => handleArchive(program)}>
                <EyeOff className="mr-2 h-4 w-4" />
                アーカイブにする
              </DropdownMenuItem>
            )}
          </DropdownMenuContent>
        </DropdownMenu>
      ),
    },
  ];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">番組管理</h1>
        <p className="text-muted-foreground">登録番組の一覧と管理</p>
      </div>

      {/* Filters */}
      <div className="flex flex-wrap items-center gap-4">
        <div className="relative flex-1 min-w-[200px] max-w-sm">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          <Input
            placeholder="番組名や配信者名で検索..."
            value={search}
            onChange={(e) => {
              setSearch(e.target.value);
            }}
            className="pl-9"
          />
        </div>
        <Select
          value={status}
          onValueChange={(v) => {
            setStatus(v === "all" ? "" : v);
            setPage(1);
          }}
        >
          <SelectTrigger className="w-[140px]">
            <SelectValue placeholder="ステータス" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">すべて</SelectItem>
            <SelectItem value="published">公開中</SelectItem>
            <SelectItem value="archived">アーカイブ</SelectItem>
            <SelectItem value="draft">下書き</SelectItem>
          </SelectContent>
        </Select>
        <Select
          value={genre}
          onValueChange={(v) => {
            setGenre(v === "all" ? "" : v);
            setPage(1);
          }}
        >
          <SelectTrigger className="w-[160px]">
            <SelectValue placeholder="ジャンル" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">すべてのジャンル</SelectItem>
            {genres.map((g) => (
              <SelectItem key={g.genre} value={g.genre}>
                {g.genre} ({g.count})
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
        <Select
          value={sort}
          onValueChange={(v) => {
            setSort(v);
            setPage(1);
          }}
        >
          <SelectTrigger className="w-[160px]">
            <SelectValue placeholder="並び順" />
          </SelectTrigger>
          <SelectContent>
            {sortOptions.map((opt) => (
              <SelectItem key={opt.value} value={opt.value}>
                {opt.label}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
      </div>

      {/* Table */}
      <div className="rounded-md border bg-card">
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
