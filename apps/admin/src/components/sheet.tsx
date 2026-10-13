"use client";

import { X } from "lucide-react";
import { useEffect, useRef } from "react";
import { Button } from "./ui";

/** Side sheet for editing one item. Open while `open` is true. */
export function Sheet({
  open,
  title,
  onClose,
  children,
  footer,
  wide = false,
}: {
  open: boolean;
  title: string;
  onClose: () => void;
  children: React.ReactNode;
  footer: React.ReactNode;
  wide?: boolean;
}) {
  const dialog = useRef<HTMLDialogElement>(null);

  useEffect(() => {
    const d = dialog.current;
    if (!d) return;
    if (open && !d.open) d.showModal();
    if (!open && d.open) d.close();
  }, [open]);

  return (
    <dialog
      ref={dialog}
      aria-label={title}
      onClose={onClose}
      onClick={(e) => e.target === dialog.current && onClose()}
      className={`m-0 ml-auto h-dvh max-h-none w-full ${wide ? "max-w-2xl" : "max-w-md"} bg-surface p-0 text-ink shadow-[-24px_0_60px_-24px_rgb(16_22_42/0.35)] backdrop:bg-night/40 open:animate-[sheet_380ms_var(--ease-out-expo)]`}
    >
      <div className="flex h-full flex-col">
        <header className="flex items-start justify-between border-b border-line px-6 py-5">
          <h2 className="font-display text-xl font-medium">{title}</h2>
          <Button
            type="button"
            variant="ghost"
            aria-label="Sluiten"
            className="-mr-2 px-2"
            onClick={onClose}
            icon={<X className="size-4" aria-hidden />}
          />
        </header>
        <div className="flex-1 space-y-5 overflow-y-auto px-6 py-6">{children}</div>
        <footer className="flex items-center justify-end gap-2 border-t border-line px-6 py-4">{footer}</footer>
      </div>
    </dialog>
  );
}
