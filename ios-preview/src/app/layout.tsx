import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "CRATE — iOS Preview",
  description: "iOS App Screen Preview for CRATE Music Radio",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="ja" className="h-full antialiased dark">
      <head>
        <link
          href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500&display=swap"
          rel="stylesheet"
        />
      </head>
      <body className="min-h-screen bg-crate-void text-crate-text-primary">
        {children}
      </body>
    </html>
  );
}
