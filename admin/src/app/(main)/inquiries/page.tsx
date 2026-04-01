"use client";

import { useState } from "react";
import { MessageSquare, Search, Eye, Save } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Label } from "@/components/ui/label";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
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

const STATUS_VARIANTS: Record<Inquiry["status"], "default" | "secondary" | "success" | "destructive"> = {
  pending: "destructive",
  in_progress: "default",
  resolved: "success",
  closed: "secondary",
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
          <p className="font-medium truncate">{inquiry.subject}</p>
          <p className="text-xs text-muted-foreground truncate">{inquiry.body}</p>
        </div>
      ),
    },
    {
      key: "email",
      header: "メールアドレス",
      render: (inquiry) => (
        <span className="text-sm">{inquiry.email}</span>
      ),
    },
    {
      key: "status",
      header: "ステータス",
      render: (inquiry) => (
        <Badge variant={STATUS_VARIANTS[inquiry.status]}>
          {STATUS_LABELS[inquiry.status]}
        </Badge>
      ),
    },
    {
      key: "created_at",
      header: "受信日時",
      render: (inquiry) => (
        <span className="text-sm">{formatDateTime(inquiry.created_at)}</span>
      ),
    },
    {
      key: "actions",
      header: "",
      className: "w-10",
      render: (inquiry) => (
        <Button
          variant="ghost"
          size="icon"
          className="h-8 w-8"
          onClick={() => handleOpenDetail(inquiry)}
        >
          <Eye className="h-4 w-4" />
        </Button>
      ),
    },
  ];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">お問い合わせ管理</h1>
        <p className="text-muted-foreground">
          ユーザーからのお問い合わせ一覧
        </p>
      </div>

      {/* Filters */}
      <div className="flex flex-wrap items-center gap-4">
        <div className="relative flex-1 min-w-[200px] max-w-sm">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          <Input
            placeholder="件名やメールで検索..."
            value={search}
            onChange={(e) => {
              setSearch(e.target.value);
              setPage(1);
            }}
            className="pl-9"
          />
        </div>
        <Select
          value={statusFilter}
          onValueChange={(v) => {
            setStatusFilter(v === "all" ? "" : v);
            setPage(1);
          }}
        >
          <SelectTrigger className="w-[160px]">
            <SelectValue placeholder="ステータス" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">すべて</SelectItem>
            <SelectItem value="pending">未対応</SelectItem>
            <SelectItem value="in_progress">対応中</SelectItem>
            <SelectItem value="resolved">解決済み</SelectItem>
            <SelectItem value="closed">クローズ</SelectItem>
          </SelectContent>
        </Select>
      </div>

      {/* Table */}
      <div className="rounded-md border bg-card">
        <DataTable
          columns={columns}
          data={inquiries}
          isLoading={isLoading}
          emptyMessage="お問い合わせはありません"
        />
        {meta && <Pagination meta={meta} onPageChange={setPage} />}
      </div>

      {/* Detail Dialog */}
      <Dialog
        open={!!selectedInquiry}
        onOpenChange={(open) => {
          if (!open) setSelectedInquiry(null);
        }}
      >
        <DialogContent className="max-w-lg">
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2">
              <MessageSquare className="h-5 w-5" />
              お問い合わせ詳細
            </DialogTitle>
          </DialogHeader>

          {selectedInquiry && (
            <div className="space-y-4">
              <div>
                <Label className="text-xs text-muted-foreground">件名</Label>
                <p className="font-medium">{selectedInquiry.subject}</p>
              </div>

              <div>
                <Label className="text-xs text-muted-foreground">メールアドレス</Label>
                <p className="text-sm">{selectedInquiry.email}</p>
              </div>

              <div>
                <Label className="text-xs text-muted-foreground">受信日時</Label>
                <p className="text-sm">{formatDateTime(selectedInquiry.created_at)}</p>
              </div>

              <div>
                <Label className="text-xs text-muted-foreground">内容</Label>
                <p className="text-sm whitespace-pre-wrap rounded-md border bg-muted/50 p-3">
                  {selectedInquiry.body}
                </p>
              </div>

              <div className="space-y-2">
                <Label className="text-xs text-muted-foreground">ステータス</Label>
                <Select value={editStatus} onValueChange={setEditStatus}>
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="pending">未対応</SelectItem>
                    <SelectItem value="in_progress">対応中</SelectItem>
                    <SelectItem value="resolved">解決済み</SelectItem>
                    <SelectItem value="closed">クローズ</SelectItem>
                  </SelectContent>
                </Select>
              </div>

              <div className="space-y-2">
                <Label className="text-xs text-muted-foreground">管理者メモ</Label>
                <textarea
                  className="flex min-h-[80px] w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
                  placeholder="対応メモを入力..."
                  value={editNote}
                  onChange={(e) => setEditNote(e.target.value)}
                />
              </div>

              <div className="flex justify-end gap-2 pt-2">
                <Button
                  variant="outline"
                  onClick={() => setSelectedInquiry(null)}
                >
                  キャンセル
                </Button>
                <Button
                  onClick={handleSave}
                  disabled={updateInquiry.isPending}
                >
                  <Save className="mr-2 h-4 w-4" />
                  {updateInquiry.isPending ? "保存中..." : "保存"}
                </Button>
              </div>
            </div>
          )}
        </DialogContent>
      </Dialog>
    </div>
  );
}
