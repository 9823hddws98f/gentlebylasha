import { LoaderCircle } from "lucide-react";
import type { ComponentProps, InputHTMLAttributes, ReactNode, SelectHTMLAttributes } from "react";

type Variant = "primary" | "secondary" | "ghost" | "danger";

const variants: Record<Variant, string> = {
  primary:
    "bg-ink text-white shadow-[0_1px_2px_rgb(20_26_46/0.2)] hover:bg-night-raised disabled:bg-ink-faint",
  secondary:
    "bg-surface text-ink border border-line-strong hover:border-ink-faint hover:bg-paper disabled:text-ink-faint",
  ghost: "text-ink-soft hover:bg-paper hover:text-ink disabled:text-ink-faint",
  danger: "text-ember hover:bg-ember-wash disabled:text-ink-faint",
};

export function Button({
  variant = "secondary",
  busy = false,
  icon,
  children,
  className = "",
  ...props
}: ComponentProps<"button"> & { variant?: Variant; busy?: boolean; icon?: ReactNode }) {
  return (
    <button
      {...props}
      disabled={props.disabled || busy}
      className={`inline-flex h-9 items-center justify-center gap-2 rounded-lg px-3.5 text-sm font-medium whitespace-nowrap transition-[background-color,border-color,color,transform] duration-150 ease-out-expo active:scale-[0.97] disabled:cursor-not-allowed disabled:active:scale-100 ${variants[variant]} ${className}`}
    >
      {busy ? <LoaderCircle className="size-4 animate-spin" aria-hidden /> : icon}
      {children}
    </button>
  );
}

const fieldBase =
  "h-9 w-full rounded-lg border border-line-strong bg-surface px-3 text-sm text-ink placeholder:text-ink-faint transition-[border-color,box-shadow] duration-150 hover:border-ink-faint focus:border-dusk focus:shadow-[0_0_0_3px_rgb(54_93_203/0.15)] focus:outline-none disabled:bg-paper";

export function Input({ className = "", ...props }: InputHTMLAttributes<HTMLInputElement>) {
  return <input {...props} className={`${fieldBase} ${className}`} />;
}

export function Select({ className = "", ...props }: SelectHTMLAttributes<HTMLSelectElement>) {
  return <select {...props} className={`${fieldBase} pr-8 ${className}`} />;
}

export function Label({ children, htmlFor }: { children: ReactNode; htmlFor?: string }) {
  return (
    <label htmlFor={htmlFor} className="mb-1.5 block text-[13px] font-medium text-ink-soft">
      {children}
    </label>
  );
}
