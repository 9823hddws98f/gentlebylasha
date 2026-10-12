"use client";

import { AudioLines, KeyRound, LogOut, Users } from "lucide-react";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { useEffect } from "react";
import { signOut, useAuth } from "@/lib/auth";

const nav = [
  { href: "/codes", label: "Toegangscodes", icon: KeyRound },
  { href: "/tracks", label: "Tracks", icon: AudioLines },
  { href: "/users", label: "Gebruikers", icon: Users },
];

export default function AdminLayout({ children }: { children: React.ReactNode }) {
  const { user, isAdmin, loading } = useAuth();
  const router = useRouter();
  const pathname = usePathname();

  useEffect(() => {
    if (!loading && !isAdmin) router.replace("/login");
  }, [loading, isAdmin, router]);

  if (loading || !isAdmin) {
    return <div className="min-h-screen bg-paper" aria-busy="true" />;
  }

  return (
    <div className="min-h-screen md:grid md:grid-cols-[232px_1fr]">
      <aside className="flex items-center justify-between gap-4 bg-night px-4 py-3 md:sticky md:top-0 md:h-screen md:flex-col md:items-stretch md:justify-start md:px-4 md:py-6">
        {/* eslint-disable-next-line @next/next/no-img-element */}
        <img src="/gentle_logo.svg" alt="Gentle" width={92} height={45} className="h-8 w-auto md:mb-10 md:ml-2 md:self-start" />

        <nav className="flex gap-1 md:flex-col">
          {nav.map(({ href, label, icon: Icon }) => {
            const active = pathname.startsWith(href);
            return (
              <Link
                key={href}
                href={href}
                aria-current={active ? "page" : undefined}
                className={`flex items-center gap-2.5 rounded-lg px-3 py-2 text-sm transition-colors ${
                  active ? "bg-night-raised text-white" : "text-night-ink hover:bg-night-raised/60 hover:text-white"
                }`}
              >
                <Icon className="size-4" aria-hidden />
                <span className="hidden sm:inline">{label}</span>
              </Link>
            );
          })}
        </nav>

        <div className="flex items-center gap-2 md:mt-auto md:flex-col md:items-stretch md:gap-1 md:border-t md:border-night-raised md:pt-4">
          <p className="hidden truncate px-3 text-xs text-night-ink/70 md:block" title={user?.email ?? ""}>
            {user?.email}
          </p>
          <button
            onClick={() => signOut()}
            className="flex items-center gap-2.5 rounded-lg px-3 py-2 text-sm text-night-ink transition-colors hover:bg-night-raised/60 hover:text-white"
          >
            <LogOut className="size-4" aria-hidden />
            <span className="hidden sm:inline">Uitloggen</span>
          </button>
        </div>
      </aside>

      <main className="min-w-0 px-4 py-8 sm:px-8 md:px-10 md:py-10">{children}</main>
    </div>
  );
}
