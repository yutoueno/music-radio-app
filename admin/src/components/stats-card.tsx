import { cn, formatNumber, formatPercentage } from "@/lib/utils";
import type { LucideIcon } from "lucide-react";

interface StatsCardProps {
  title: string;
  value: number;
  icon: LucideIcon;
  growthRate?: number;
  description?: string;
  className?: string;
}

export function StatsCard({
  title,
  value,
  icon: Icon,
  growthRate,
  description,
  className,
}: StatsCardProps) {
  return (
    <div
      className={cn(
        "rounded-xl border border-crate-border bg-crate-surface p-5 transition-colors hover:border-crate-accent/30",
        className
      )}
    >
      <div className="flex items-center justify-between pb-2">
        <span className="text-xs font-medium uppercase tracking-wider text-crate-text-secondary">
          {title}
        </span>
        <Icon className="h-4 w-4 text-crate-text-tertiary" />
      </div>
      <div className="text-2xl font-bold text-crate-text-primary">
        {formatNumber(value)}
      </div>
      {growthRate !== undefined && (
        <p
          className={cn(
            "mt-1 text-xs",
            growthRate >= 0 ? "text-crate-success" : "text-crate-error"
          )}
        >
          {formatPercentage(growthRate)} 前月比
        </p>
      )}
      {description && (
        <p className="mt-1 text-xs text-crate-text-tertiary">{description}</p>
      )}
    </div>
  );
}
