"use client";

import { ChevronLeft, ChevronRight } from "lucide-react";
import type { PaginationMeta } from "@/types";

interface PaginationProps {
  meta: PaginationMeta;
  onPageChange: (page: number) => void;
}

export function Pagination({ meta, onPageChange }: PaginationProps) {
  const totalPages = Math.ceil(meta.total / meta.per_page);
  const currentPage = meta.page;

  if (totalPages <= 1) return null;

  const pages: (number | "...")[] = [];
  if (totalPages <= 7) {
    for (let i = 1; i <= totalPages; i++) pages.push(i);
  } else {
    pages.push(1);
    if (currentPage > 3) pages.push("...");
    for (
      let i = Math.max(2, currentPage - 1);
      i <= Math.min(totalPages - 1, currentPage + 1);
      i++
    ) {
      pages.push(i);
    }
    if (currentPage < totalPages - 2) pages.push("...");
    pages.push(totalPages);
  }

  return (
    <div className="flex items-center justify-between border-t border-crate-border px-4 py-3">
      <p className="text-sm text-crate-text-tertiary">
        全 {meta.total.toLocaleString()} 件中{" "}
        {((currentPage - 1) * meta.per_page + 1).toLocaleString()} -{" "}
        {Math.min(currentPage * meta.per_page, meta.total).toLocaleString()} 件
      </p>
      <div className="flex items-center gap-1">
        <button
          className="flex h-8 w-8 items-center justify-center rounded-lg border border-crate-border bg-crate-elevated text-crate-text-secondary transition-colors hover:bg-crate-surface hover:text-crate-text-primary disabled:opacity-40 disabled:cursor-not-allowed"
          onClick={() => onPageChange(currentPage - 1)}
          disabled={currentPage <= 1}
        >
          <ChevronLeft className="h-4 w-4" />
        </button>
        {pages.map((page, i) =>
          page === "..." ? (
            <span key={`dots-${i}`} className="px-2 text-crate-text-tertiary">
              ...
            </span>
          ) : (
            <button
              key={page}
              className={`flex h-8 w-8 items-center justify-center rounded-lg text-xs font-medium transition-colors ${
                page === currentPage
                  ? "bg-crate-accent text-white"
                  : "border border-crate-border bg-crate-elevated text-crate-text-secondary hover:bg-crate-surface hover:text-crate-text-primary"
              }`}
              onClick={() => onPageChange(page as number)}
            >
              {page}
            </button>
          )
        )}
        <button
          className="flex h-8 w-8 items-center justify-center rounded-lg border border-crate-border bg-crate-elevated text-crate-text-secondary transition-colors hover:bg-crate-surface hover:text-crate-text-primary disabled:opacity-40 disabled:cursor-not-allowed"
          onClick={() => onPageChange(currentPage + 1)}
          disabled={!meta.has_next}
        >
          <ChevronRight className="h-4 w-4" />
        </button>
      </div>
    </div>
  );
}
