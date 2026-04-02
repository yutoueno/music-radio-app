"use client";

import { Download } from "lucide-react";

interface ExportButtonProps {
  data: Record<string, unknown>[];
  filename: string;
  label?: string;
}

function convertToCSV(data: Record<string, unknown>[]): string {
  if (data.length === 0) return "";

  const headers = Object.keys(data[0]);
  const csvRows: string[] = [];

  // Header row
  csvRows.push(headers.map((h) => `"${h}"`).join(","));

  // Data rows
  for (const row of data) {
    const values = headers.map((h) => {
      const val = row[h];
      if (val === null || val === undefined) return '""';
      const str = String(val).replace(/"/g, '""');
      return `"${str}"`;
    });
    csvRows.push(values.join(","));
  }

  return csvRows.join("\n");
}

export function ExportButton({ data, filename, label = "CSV出力" }: ExportButtonProps) {
  const handleExport = () => {
    if (data.length === 0) return;

    const csv = convertToCSV(data);
    const bom = "\uFEFF";
    const blob = new Blob([bom + csv], { type: "text/csv;charset=utf-8;" });
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.href = url;
    link.download = `${filename}.csv`;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    URL.revokeObjectURL(url);
  };

  return (
    <button
      onClick={handleExport}
      disabled={data.length === 0}
      className="inline-flex items-center gap-2 rounded-full bg-crate-accent px-4 py-2 text-sm font-semibold text-white transition-colors hover:bg-crate-accent-dim disabled:opacity-40 disabled:cursor-not-allowed"
    >
      <Download className="h-4 w-4" />
      {label}
    </button>
  );
}
