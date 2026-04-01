"use client";

import { ArrowUpDown } from "lucide-react";
import { cn } from "@/lib/utils";

export interface Column<T> {
  key: string;
  header: string;
  sortable?: boolean;
  className?: string;
  render: (item: T) => React.ReactNode;
}

interface DataTableProps<T> {
  columns: Column<T>[];
  data: T[];
  isLoading?: boolean;
  sortBy?: string;
  sortOrder?: "asc" | "desc";
  onSort?: (key: string) => void;
  emptyMessage?: string;
}

export function DataTable<T>({
  columns,
  data,
  isLoading,
  sortBy,
  sortOrder,
  onSort,
  emptyMessage = "データがありません",
}: DataTableProps<T>) {
  if (isLoading) {
    return (
      <div className="space-y-1 p-4">
        {Array.from({ length: 5 }).map((_, i) => (
          <div key={i} className="h-12 w-full animate-pulse rounded-lg bg-crate-elevated" />
        ))}
      </div>
    );
  }

  return (
    <div className="overflow-x-auto">
      <table className="w-full">
        <thead>
          <tr className="border-b border-crate-border bg-crate-surface">
            {columns.map((column) => (
              <th
                key={column.key}
                className={cn(
                  "px-4 py-3 text-left text-xs font-medium uppercase tracking-wider text-crate-text-tertiary",
                  column.className
                )}
              >
                {column.sortable && onSort ? (
                  <button
                    className="flex items-center gap-1 hover:text-crate-text-primary"
                    onClick={() => onSort(column.key)}
                  >
                    {column.header}
                    <ArrowUpDown
                      className={cn(
                        "h-3 w-3",
                        sortBy === column.key
                          ? "text-crate-accent"
                          : "text-crate-text-tertiary"
                      )}
                    />
                  </button>
                ) : (
                  column.header
                )}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {data.length === 0 ? (
            <tr>
              <td
                colSpan={columns.length}
                className="h-24 text-center text-sm text-crate-text-tertiary"
              >
                {emptyMessage}
              </td>
            </tr>
          ) : (
            data.map((item, index) => (
              <tr
                key={index}
                className="border-b border-crate-border/50 bg-crate-void transition-colors last:border-0 hover:bg-crate-elevated/50"
              >
                {columns.map((column) => (
                  <td key={column.key} className={cn("px-4 py-3 text-sm", column.className)}>
                    {column.render(item)}
                  </td>
                ))}
              </tr>
            ))
          )}
        </tbody>
      </table>
    </div>
  );
}
