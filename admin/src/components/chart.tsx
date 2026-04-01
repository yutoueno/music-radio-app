"use client";

import {
  LineChart,
  Line,
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  Legend,
} from "recharts";

interface LineChartCardProps {
  title: string;
  data: Array<Record<string, string | number>>;
  dataKey: string;
  xAxisKey?: string;
  color?: string;
  height?: number;
}

export function LineChartCard({
  title,
  data,
  dataKey,
  xAxisKey = "date",
  color = "#7C83FF",
  height = 300,
}: LineChartCardProps) {
  return (
    <div className="rounded-xl border border-crate-border bg-crate-surface">
      <div className="border-b border-crate-border px-5 py-4">
        <h3 className="text-sm font-semibold text-crate-text-primary">{title}</h3>
      </div>
      <div className="p-5">
        <ResponsiveContainer width="100%" height={height}>
          <LineChart data={data}>
            <CartesianGrid strokeDasharray="3 3" stroke="#222222" />
            <XAxis
              dataKey={xAxisKey}
              tick={{ fontSize: 12, fill: "#555555" }}
              axisLine={{ stroke: "#222222" }}
              tickLine={{ stroke: "#222222" }}
            />
            <YAxis
              tick={{ fontSize: 12, fill: "#555555" }}
              axisLine={{ stroke: "#222222" }}
              tickLine={{ stroke: "#222222" }}
            />
            <Tooltip
              contentStyle={{
                backgroundColor: "#1A1A1A",
                border: "1px solid #222222",
                borderRadius: "8px",
                fontSize: "12px",
                color: "#F0F0F0",
              }}
              labelStyle={{ color: "#888888" }}
            />
            <Line
              type="monotone"
              dataKey={dataKey}
              stroke={color}
              strokeWidth={2}
              dot={false}
              activeDot={{ r: 4, fill: color, stroke: "#0A0A0A", strokeWidth: 2 }}
            />
          </LineChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}

interface MultiLineChartCardProps {
  title: string;
  data: Array<Record<string, string | number>>;
  lines: Array<{ dataKey: string; color: string; name: string }>;
  xAxisKey?: string;
  height?: number;
}

export function MultiLineChartCard({
  title,
  data,
  lines,
  xAxisKey = "date",
  height = 300,
}: MultiLineChartCardProps) {
  return (
    <div className="rounded-xl border border-crate-border bg-crate-surface">
      <div className="border-b border-crate-border px-5 py-4">
        <h3 className="text-sm font-semibold text-crate-text-primary">{title}</h3>
      </div>
      <div className="p-5">
        <ResponsiveContainer width="100%" height={height}>
          <LineChart data={data}>
            <CartesianGrid strokeDasharray="3 3" stroke="#222222" />
            <XAxis
              dataKey={xAxisKey}
              tick={{ fontSize: 12, fill: "#555555" }}
              axisLine={{ stroke: "#222222" }}
              tickLine={{ stroke: "#222222" }}
            />
            <YAxis
              tick={{ fontSize: 12, fill: "#555555" }}
              axisLine={{ stroke: "#222222" }}
              tickLine={{ stroke: "#222222" }}
            />
            <Tooltip
              contentStyle={{
                backgroundColor: "#1A1A1A",
                border: "1px solid #222222",
                borderRadius: "8px",
                fontSize: "12px",
                color: "#F0F0F0",
              }}
              labelStyle={{ color: "#888888" }}
            />
            <Legend
              wrapperStyle={{ color: "#888888", fontSize: "12px" }}
            />
            {lines.map((line) => (
              <Line
                key={line.dataKey}
                type="monotone"
                dataKey={line.dataKey}
                stroke={line.color}
                strokeWidth={2}
                name={line.name}
                dot={false}
                activeDot={{ r: 4 }}
              />
            ))}
          </LineChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}

interface BarChartCardProps {
  title: string;
  data: Array<Record<string, string | number>>;
  dataKey: string;
  xAxisKey?: string;
  color?: string;
  height?: number;
}

export function BarChartCard({
  title,
  data,
  dataKey,
  xAxisKey = "name",
  color = "#7C83FF",
  height = 300,
}: BarChartCardProps) {
  return (
    <div className="rounded-xl border border-crate-border bg-crate-surface">
      <div className="border-b border-crate-border px-5 py-4">
        <h3 className="text-sm font-semibold text-crate-text-primary">{title}</h3>
      </div>
      <div className="p-5">
        <ResponsiveContainer width="100%" height={height}>
          <BarChart data={data}>
            <CartesianGrid strokeDasharray="3 3" stroke="#222222" />
            <XAxis
              dataKey={xAxisKey}
              tick={{ fontSize: 12, fill: "#555555" }}
              axisLine={{ stroke: "#222222" }}
              tickLine={{ stroke: "#222222" }}
            />
            <YAxis
              tick={{ fontSize: 12, fill: "#555555" }}
              axisLine={{ stroke: "#222222" }}
              tickLine={{ stroke: "#222222" }}
            />
            <Tooltip
              contentStyle={{
                backgroundColor: "#1A1A1A",
                border: "1px solid #222222",
                borderRadius: "8px",
                fontSize: "12px",
                color: "#F0F0F0",
              }}
              labelStyle={{ color: "#888888" }}
              cursor={{ fill: "rgba(124, 131, 255, 0.05)" }}
            />
            <Bar dataKey={dataKey} fill={color} radius={[4, 4, 0, 0]} />
          </BarChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}
