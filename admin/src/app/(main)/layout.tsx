"use client";

import { useRequireAuth } from "@/hooks/use-auth";
import { Sidebar } from "@/components/sidebar";
import { Header } from "@/components/header";

export default function MainLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const { isAuthenticated } = useRequireAuth();

  return (
    <div className="flex h-screen bg-crate-void">
      <Sidebar />
      <div className="flex min-w-0 flex-1 flex-col overflow-hidden">
        <Header />
        <main className="flex-1 overflow-y-auto bg-crate-void p-6">
          {children}
        </main>
      </div>
    </div>
  );
}
