"use client";

import { useState } from "react";
import { MessageSquare, Search, Eye, Save, X } from "lucide-react";
import { DataTable, type Column } from "@/components/data-table";
import { Pagination } from "@/components/pagination";
import { useToast } from "@/components/ui/toast";
import { useInquiries, useUpdateInquiry } from "@/hooks/use-api";
import { formatDateTime } from "@/lib/utils";
import type { Inquiry } from "@/types";

const STATUS_LABELS: Record<Inquiry["status"], string> = {
  pending: "未対応",
  in_progress: "対応中",
  resolved: "解決済み",
  closed: "クローズ",
};

const STATUS_COLORS: Record<Inquiry["status"], string> = {
  pending: "bg-crate-error/15 text-crate-error",
  in_progress: "bg-crate-accent/15 text-crate-accent",
  resolved: "bg-crate-success/15 text-crate-success",
  closed: "bg-crate-elevated text-crate-text-tertiary",
};

export default function InquiriesPage() {
  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState<string>("");
  const [page, setPage] = useState(1);
  const [selectedInquiry, setSelectedInquiry] = useState<Inquiry | null>(null);
  const [editStatus, setEditStatus] = useState<string>("");
  const [editNote, setEditNote] = useState<string>("");

  const { toast } = useToast();
  const updateInquiry = useUpdateInquiry();

  const { data, isLoading } = useInquiries({
    page,
    per_page: 30,
    status: statusFilter || undefined,
    search: search || undefined,
  });

  const inquiries = data?.data || [];
  const meta = data?.meta;

  const handleOpenDetail = (inquiry: Inquiry) => {
    setSelectedInquiry(inquiry);
    setEditStatus(inquiry.status);
    setEditNote(inquiry.admin_note || "");
  };

  const handleSave = async () => {
    if (!selectedInquiry) return;

    try {
      const updateData: { status?: string; admin_note?: string } = {};
      if (editStatus !== selectedInquiry.status) {
        updateData.status = editStatus;
      }
      if (editNote !== (selectedInquiry.admin_note || "")) {
        updateData.admin_note = editNote;
      }

      if (Object.keys(updateData).length === 0) {
        setSelectedInquiry(null);
        return;
      }

      await updateInquiry.mutateAsync({
        id: selectedInquiry.id,
        data: updateData,
      });

      toast({
        title: "更新しました",
        description: "お問い合わせ情報を更新しました。",
        variant: "success",
      });
      setSelectedInquiry(null);
    } catch {
      toast({
        title: "エラー",
        description: "更新に失敗しました。",
        variant: "destructive",
      });
    }
  };

  const columns: Column<Inquiry>[] = [
    {
      key: "subject",
      header: "件名",
      render: (inquiry) => (
        <div className="max-w-[300px]">
          <p className="font-medium truncate text-crate-text-primary">{inquiry.subject}</p>
          <p className="text-xs truncate text-crate-text-tertiary">{inquiry.body}</p>
        </div>
      ),
    },
    {
      key: "email",
      header: "メールアドレス",
      render: (inquiry) => (
        <span className="text-sm text-crate-text-secondary">{inquiry.email}</span>
      ),
    },
    {
      key: "status",
      header: "ステータス",
      render: (inquiry) => (
        <span className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium ${STATUS_COLORS[inquiry.status]}`}>
          {STATUS_LABELS[inquiry.status]}
        </span>
      ),
    },
    {
      key: "created_at",
      header: "受信日時",
      render: (inquiry) => (
        <span className="text-sm text-crate-text-secondary">{formatDateTime(inquiry.created_at)}</span>
      ),
    },
    {
      key: "actions",
      header: "",
      className: "w-10",
      render: (inquiry) => (
        <button
          className="flex h-8 w-8 items-center justify-center rounded-lg text-crate-text-tertiary transition-colors hover:bg-crate-elevated hover:text-crate-text-primary"
          onClick={() => handleOpenDetail(inquiry)}
        >
          <Eye className="h-4 w-4" />
        </button>
      ),
    },
  ];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="font-heading text-2xl font-bold text-crate-text-primary">お問い合わせ管理</h1>
        <p className="text-sm text-crate-text-secondary">
          ユーザーからのお問い合わせ一覧
        </p>
      </div>

      {/* Filters */}
      <div className="flex flex-wrap items-center gap-4">
        <div className="relative flex-1 min-w-[200px] max-w-sm">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-crate-text-tertiary" />
          <input
            placeholder="件名やメールで検索..."
            value={search}
            onChange={(e) => { setSearch(e.target.value); setPage(1); }}
            className="w-full rounded-lg border border-crate-border bg-crate-elevated py-2 pl-9 pr-4 text-sm text-crate-text-primary placeholder:text-crate-text-tertiary outline-none transition-colors focus:border-crate-accent"
          />
        </div>
        <select
          value={statusFilter || "all"}
          onChange={(e) => { setStatusFilter(e.target.value === "all" ? "" : e.target.value); setPage(1); }}
          className="rounded-lg border border-crate-border bg-crate-elevated px-3 py-2 text-sm text-crate-text-primary outline-none focus:border-crate-accent"
        >
          <option value="all">すべて</option>
          <option value="pending">未対応</option>
          <option value="in_progress">対応中</option>
          <option value="resolved">解決済み</option>
          <option value="closed">クローズ</option>
        </select>
      </div>

      {/* Table */}
      <div className="rounded-xl border border-crate-border bg-crate-surface">
        <DataTable
          columns={columns}
          data={inquiries}
          isLoading={isLoading}
          emptyMessage="お問い合わせはありません"
        />
        {meta && <Pagination meta={meta} onPageChange={setPage} />}
      </div>

      {/* Detail Modal */}
      {selectedInquiry && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm">
          <div className="mx-4 w-full max-w-lg rounded-xl border border-crate-border bg-crate-surface p-6 shadow-2xl">
            <div className="flex items-center justify-between mb-5">
              <h2 className="flex items-center gap-2 font-heading text-lg font-semibold text-crate-text-primary">
                <MessageSquare className="h-5 w-5 text-crate-accent" />
                お問い合わせ詳細
              </h2>
              <button
                onClick={() => setSelectedInquiry(null)}
                className="flex h-8 w-8 items-center justify-center rounded-lg text-crate-text-tertiary hover:bg-crate-elevated hover:text-crate-text-primary"
              >
                <X className="h-4 w-4" />
              </button>
            </div>

            <div className="space-y-4">
              <div>
                <label className="text-xs font-medium uppercase tracking-wider text-crate-text-tertiary">件名</label>
                <p className="mt-1 font-medium text-crate-text-primary">{selectedInquiry.subject}</p>
              </div>

              <div>
                <label className="text-xs font-medium uppercase tracking-wider text-crate-text-tertiary">メールアドレス</label>
                <p className="mt-1 text-sm text-crate-text-secondary">{selectedInquiry.email}</p>
              </div>

              <div>
                <label className="text-xs font-medium uppercase tracking-wider text-crate-text-tertiary">受信日時</label>
                <p className="mt-1 text-sm text-crate-text-secondary">{formatDateTime(selectedInquiry.created_at)}</p>
              </div>

              <div>
                <label className="text-xs font-medium uppercase tracking-wider text-crate-text-tertiary">内容</label>
                <p className="mt-1 whitespace-pre-wrap rounded-lg border border-crate-border bg-crate-elevated p-3 text-sm text-crate-text-primary">
                  {selectedInquiry.body}
                </p>
              </div>

              <div className="space-y-2">
                <label className="text-xs font-medium uppercase tracking-wider text-crate-text-tertiary">ステータス</label>
                <select
                  value={editStatus}
                  onChange={(e) => setEditStatus(e.target.value)}
                  className="w-full rounded-lg border border-crate-border bg-crate-elevated px-3 py-2 text-sm text-crate-text-primary outline-none focus:border-crate-accent"
                >
                  <option value="pending">未対応</option>
                  <option value="in_progress">対応中</option>
                  <option value="resolved">解決済み</option>
                  <option value="closed">クローズ</option>
                </select>
              </div>

              <div className="space-y-2">
                <label className="text-xs font-medium uppercase tracking-wider text-crate-text-tertiary">管理者メモ</label>
                <textarea
                  className="w-full min-h-[80px] rounded-lg border border-crate-border bg-crate-elevated px-3 py-2 text-sm text-crate-text-primary placeholder:text-crate-text-tertiary outline-none focus:border-crate-accent resize-none"
                  placeholder="対応メモを入力..."
                  value={editNote}
                  onChange={(e) => setEditNote(e.target.value)}
                />
              </div>

              <div className="flex justify-end gap-3 pt-2">
                <button
                  onClick={() => setSelectedInquiry(null)}
                  className="rounded-lg border border-crate-border bg-crate-elevated px-4 py-2 text-sm text-crate-text-secondary transition-colors hover:bg-crate-surface hover:text-crate-text-primary"
                >
                  キャンセル
                </button>
                <button
                  onClick={handleSave}
                  disabled={updateInquiry.isPending}
                  className="flex items-center gap-2 rounded-lg bg-crate-accent px-4 py-2 text-sm font-semibold text-white transition-colors hover:bg-crate-accent-dim disabled:opacity-50"
                >
                  <Save className="h-4 w-4" />
                  {updateInquiry.isPending ? "保存中..." : "保存"}
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
