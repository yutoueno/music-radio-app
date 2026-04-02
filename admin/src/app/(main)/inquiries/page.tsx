"use client";

import { useState, Fragment } from "react";
import { Save, ChevronDown, ChevronUp } from "lucide-react";
import { ExportButton } from "@/components/ExportButton";
import { formatDateTime } from "@/lib/utils";

type InquiryStatus = "pending" | "in_progress" | "resolved" | "closed";

interface MockInquiry {
  id: string;
  email: string;
  subject: string;
  body: string;
  status: InquiryStatus;
  admin_note: string | null;
  created_at: string;
  updated_at: string;
}

const STATUS_LABELS: Record<InquiryStatus, string> = {
  pending: "Pending",
  in_progress: "In Progress",
  resolved: "Resolved",
  closed: "Closed",
};

const STATUS_COLORS: Record<InquiryStatus, string> = {
  pending: "bg-yellow-500/15 text-yellow-400",
  in_progress: "bg-crate-accent/15 text-crate-accent",
  resolved: "bg-crate-success/15 text-crate-success",
  closed: "bg-crate-elevated text-crate-text-tertiary",
};

const FILTER_OPTIONS: { value: string; label: string }[] = [
  { value: "all", label: "All" },
  { value: "pending", label: "Pending" },
  { value: "in_progress", label: "In Progress" },
  { value: "resolved", label: "Resolved" },
  { value: "closed", label: "Closed" },
];

const mockInquiries: MockInquiry[] = [
  {
    id: "inq-001",
    email: "tanaka@example.com",
    subject: "Apple Music連携が動作しません",
    body: "番組再生中にApple Musicの楽曲が再生されません。サブスクリプションは有効です。iPhoneのMusicKit設定も確認済みです。再起動しても改善しません。環境: iPhone 15 Pro, iOS 17.4",
    status: "pending",
    admin_note: null,
    created_at: "2026-04-01T14:30:00Z",
    updated_at: "2026-04-01T14:30:00Z",
  },
  {
    id: "inq-002",
    email: "sato.yuki@example.com",
    subject: "配信者登録について",
    body: "配信者として番組を作成したいのですが、登録方法がわかりません。マニュアルやガイドはありますか？",
    status: "in_progress",
    admin_note: "配信者ガイドのリンクを送付予定",
    created_at: "2026-03-31T09:15:00Z",
    updated_at: "2026-04-01T10:00:00Z",
  },
  {
    id: "inq-003",
    email: "music_lover@example.com",
    subject: "お気に入りが消えました",
    body: "アプリをアップデートしたところ、お気に入りに登録していた番組がすべて消えていました。復旧は可能でしょうか？",
    status: "resolved",
    admin_note: "サーバー側にデータ残存を確認。v2.1.1で修正済み。ユーザーに通知済み。",
    created_at: "2026-03-29T18:45:00Z",
    updated_at: "2026-03-30T11:20:00Z",
  },
  {
    id: "inq-004",
    email: "dj_yamada@example.com",
    subject: "音声アップロードのファイルサイズ制限",
    body: "2時間の番組を録音したところ、ファイルサイズが120MBを超えてアップロードできませんでした。上限を緩和していただくことは可能でしょうか？",
    status: "pending",
    admin_note: null,
    created_at: "2026-04-01T22:10:00Z",
    updated_at: "2026-04-01T22:10:00Z",
  },
  {
    id: "inq-005",
    email: "support_test@example.com",
    subject: "アカウント削除の依頼",
    body: "個人的な事情によりアカウントを完全に削除したいです。関連するデータもすべて削除をお願いします。",
    status: "in_progress",
    admin_note: "GDPR対応手順に従い処理中",
    created_at: "2026-03-28T07:00:00Z",
    updated_at: "2026-03-29T15:30:00Z",
  },
  {
    id: "inq-006",
    email: "radio_fan@example.com",
    subject: "バックグラウンド再生が停止する",
    body: "他のアプリに切り替えると数分後に再生が止まります。iOS 17.3で発生しています。バッテリー最適化はオフにしています。",
    status: "pending",
    admin_note: null,
    created_at: "2026-04-02T01:20:00Z",
    updated_at: "2026-04-02T01:20:00Z",
  },
  {
    id: "inq-007",
    email: "pro_user@example.com",
    subject: "波形表示の不具合",
    body: "番組の波形表示がフラットになってしまい、正しく描画されていないようです。すべての番組で同様の現象が発生しています。",
    status: "closed",
    admin_note: "v2.0.8で修正済み。再発報告なし。",
    created_at: "2026-03-20T12:00:00Z",
    updated_at: "2026-03-22T09:45:00Z",
  },
  {
    id: "inq-008",
    email: "new_user@example.com",
    subject: "メール認証メールが届きません",
    body: "新規登録を行いましたが、認証メールが届きません。迷惑メールフォルダも確認済みです。再送もしましたが同様です。",
    status: "resolved",
    admin_note: "SendGrid配信遅延が原因。手動で認証を有効化。ユーザーに連絡済み。",
    created_at: "2026-03-30T16:30:00Z",
    updated_at: "2026-03-31T08:00:00Z",
  },
];

export default function InquiriesPage() {
  const [statusFilter, setStatusFilter] = useState<string>("all");
  const [expandedId, setExpandedId] = useState<string | null>(null);
  const [adminNotes, setAdminNotes] = useState<Record<string, string>>({});

  const filteredInquiries = statusFilter === "all"
    ? mockInquiries
    : mockInquiries.filter((i) => i.status === statusFilter);

  const statusCounts = {
    all: mockInquiries.length,
    pending: mockInquiries.filter((i) => i.status === "pending").length,
    in_progress: mockInquiries.filter((i) => i.status === "in_progress").length,
    resolved: mockInquiries.filter((i) => i.status === "resolved").length,
    closed: mockInquiries.filter((i) => i.status === "closed").length,
  };

  const toggleRow = (id: string) => {
    setExpandedId(expandedId === id ? null : id);
  };

  const getAdminNote = (inquiry: MockInquiry) => {
    return adminNotes[inquiry.id] ?? inquiry.admin_note ?? "";
  };

  const exportData = filteredInquiries.map((i) => ({
    Date: formatDateTime(i.created_at),
    Email: i.email,
    Subject: i.subject,
    Status: STATUS_LABELS[i.status],
    Message: i.body,
    Admin_Note: i.admin_note || "",
  }));

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <h1 className="font-heading text-2xl font-bold text-crate-text-primary">
            Inquiries
          </h1>
          <span className="inline-flex items-center justify-center rounded-full bg-crate-accent/15 px-2.5 py-0.5 text-xs font-bold tabular-nums text-crate-accent">
            {mockInquiries.length}
          </span>
        </div>
        <ExportButton data={exportData} filename="inquiries" />
      </div>

      {/* Filter Pills */}
      <div className="flex flex-wrap gap-2">
        {FILTER_OPTIONS.map((opt) => {
          const isActive = statusFilter === opt.value;
          const count = statusCounts[opt.value as keyof typeof statusCounts];
          return (
            <button
              key={opt.value}
              onClick={() => setStatusFilter(opt.value)}
              className={`inline-flex items-center gap-1.5 rounded-full px-4 py-1.5 text-sm font-medium transition-all ${
                isActive
                  ? "bg-crate-accent text-white shadow-sm shadow-crate-accent/20"
                  : "bg-crate-elevated text-crate-text-secondary hover:bg-crate-surface hover:text-crate-text-primary"
              }`}
            >
              {opt.label}
              <span
                className={`text-xs tabular-nums ${
                  isActive ? "text-white/70" : "text-crate-text-tertiary"
                }`}
              >
                {count}
              </span>
            </button>
          );
        })}
      </div>

      {/* Table */}
      <div className="rounded-xl border border-crate-border bg-crate-surface overflow-hidden">
        <table className="w-full">
          <thead>
            <tr className="border-b border-crate-border bg-crate-surface">
              <th className="px-4 py-3 text-left text-xs font-medium uppercase tracking-wider text-crate-text-tertiary">
                Date
              </th>
              <th className="px-4 py-3 text-left text-xs font-medium uppercase tracking-wider text-crate-text-tertiary">
                Email
              </th>
              <th className="px-4 py-3 text-left text-xs font-medium uppercase tracking-wider text-crate-text-tertiary">
                Subject
              </th>
              <th className="px-4 py-3 text-left text-xs font-medium uppercase tracking-wider text-crate-text-tertiary">
                Status
              </th>
              <th className="w-10 px-4 py-3 text-left text-xs font-medium uppercase tracking-wider text-crate-text-tertiary">
                Actions
              </th>
            </tr>
          </thead>
          <tbody>
            {filteredInquiries.length === 0 ? (
              <tr>
                <td
                  colSpan={5}
                  className="h-24 text-center text-sm text-crate-text-tertiary"
                >
                  No inquiries found
                </td>
              </tr>
            ) : (
              filteredInquiries.map((inquiry) => {
                const isExpanded = expandedId === inquiry.id;
                return (
                  <Fragment key={inquiry.id}>
                    <tr
                      className="border-b border-crate-border/50 bg-crate-void transition-colors hover:bg-crate-elevated/50 cursor-pointer"
                      onClick={() => toggleRow(inquiry.id)}
                    >
                      <td className="px-4 py-3 text-sm text-crate-text-secondary whitespace-nowrap">
                        {formatDateTime(inquiry.created_at)}
                      </td>
                      <td className="px-4 py-3 text-sm text-crate-text-secondary">
                        {inquiry.email}
                      </td>
                      <td className="px-4 py-3">
                        <p className="text-sm font-medium text-crate-text-primary truncate max-w-[300px]">
                          {inquiry.subject}
                        </p>
                      </td>
                      <td className="px-4 py-3">
                        <span
                          className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium ${STATUS_COLORS[inquiry.status]}`}
                        >
                          {STATUS_LABELS[inquiry.status]}
                        </span>
                      </td>
                      <td className="px-4 py-3">
                        <button className="flex h-8 w-8 items-center justify-center rounded-lg text-crate-text-tertiary transition-colors hover:bg-crate-elevated hover:text-crate-text-primary">
                          {isExpanded ? (
                            <ChevronUp className="h-4 w-4" />
                          ) : (
                            <ChevronDown className="h-4 w-4" />
                          )}
                        </button>
                      </td>
                    </tr>
                    {isExpanded && (
                      <tr className="border-b border-crate-border/50">
                        <td colSpan={5} className="bg-crate-elevated/30 px-6 py-5">
                          <div className="space-y-4 max-w-2xl">
                            <div>
                              <label className="text-xs font-medium uppercase tracking-wider text-crate-text-tertiary">
                                Full Message
                              </label>
                              <p className="mt-1.5 whitespace-pre-wrap rounded-lg border border-crate-border bg-crate-void p-3 text-sm text-crate-text-primary">
                                {inquiry.body}
                              </p>
                            </div>

                            <div>
                              <label className="text-xs font-medium uppercase tracking-wider text-crate-text-tertiary">
                                Admin Note
                              </label>
                              <textarea
                                className="mt-1.5 w-full min-h-[72px] rounded-lg border border-crate-border bg-crate-void px-3 py-2 text-sm text-crate-text-primary placeholder:text-crate-text-tertiary outline-none focus:border-crate-accent resize-none"
                                placeholder="Add a note..."
                                value={getAdminNote(inquiry)}
                                onClick={(e) => e.stopPropagation()}
                                onChange={(e) =>
                                  setAdminNotes((prev) => ({
                                    ...prev,
                                    [inquiry.id]: e.target.value,
                                  }))
                                }
                              />
                            </div>

                            <div className="flex items-center gap-3">
                              <select
                                className="rounded-lg border border-crate-border bg-crate-void px-3 py-2 text-sm text-crate-text-primary outline-none focus:border-crate-accent"
                                defaultValue={inquiry.status}
                                onClick={(e) => e.stopPropagation()}
                              >
                                <option value="pending">Pending</option>
                                <option value="in_progress">In Progress</option>
                                <option value="resolved">Resolved</option>
                                <option value="closed">Closed</option>
                              </select>
                              <button
                                onClick={(e) => {
                                  e.stopPropagation();
                                }}
                                className="inline-flex items-center gap-2 rounded-lg bg-crate-accent px-4 py-2 text-sm font-semibold text-white transition-colors hover:bg-crate-accent-dim"
                              >
                                <Save className="h-4 w-4" />
                                Save
                              </button>
                            </div>
                          </div>
                        </td>
                      </tr>
                    )}
                  </Fragment>
                );
              })
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
