"use client";
import { ReactNode } from "react";

export default function IPhoneFrame({
  children,
  label
}: {
  children: ReactNode;
  label: string;
}) {
  return (
    <div className="flex flex-col items-center gap-3">
      {/* Screen label */}
      <span className="text-xs font-medium tracking-[2px] uppercase text-crate-text-tertiary">
        {label}
      </span>

      {/* iPhone shell */}
      <div className="relative w-[375px] h-[812px] rounded-[50px] border-[3px] border-crate-border bg-crate-void shadow-2xl overflow-hidden">
        {/* Dynamic Island / Notch */}
        <div className="absolute top-0 left-0 right-0 z-50 flex justify-center pt-[10px]">
          <div className="w-[126px] h-[35px] bg-black rounded-full" />
        </div>

        {/* Status bar */}
        <div className="absolute top-0 left-0 right-0 z-40 h-[54px] flex items-end justify-between px-8 pb-1">
          <span className="text-[12px] font-semibold text-crate-text-primary">9:41</span>
          <div className="flex items-center gap-1">
            <svg width="16" height="12" viewBox="0 0 16 12" fill="currentColor" className="text-crate-text-primary">
              <rect x="0" y="8" width="3" height="4" rx="0.5"/>
              <rect x="4.5" y="5" width="3" height="7" rx="0.5"/>
              <rect x="9" y="2" width="3" height="10" rx="0.5"/>
              <rect x="13.5" y="0" width="2.5" height="12" rx="0.5" opacity="0.3"/>
            </svg>
            <svg width="15" height="11" viewBox="0 0 15 11" fill="currentColor" className="text-crate-text-primary">
              <path d="M7.5 3.5C9.1 3.5 10.5 4.1 11.6 5.1L13 3.7C11.5 2.3 9.6 1.5 7.5 1.5C5.4 1.5 3.5 2.3 2 3.7L3.4 5.1C4.5 4.1 5.9 3.5 7.5 3.5Z" opacity="0.3"/>
              <path d="M7.5 6.5C8.6 6.5 9.5 6.9 10.2 7.5L11.6 6.1C10.5 5.1 9.1 4.5 7.5 4.5C5.9 4.5 4.5 5.1 3.4 6.1L4.8 7.5C5.5 6.9 6.4 6.5 7.5 6.5Z"/>
              <circle cx="7.5" cy="10" r="1.5"/>
            </svg>
            <svg width="25" height="12" viewBox="0 0 25 12" fill="none" className="text-crate-text-primary">
              <rect x="0.5" y="0.5" width="21" height="11" rx="2" stroke="currentColor" strokeWidth="1"/>
              <rect x="22" y="3.5" width="2.5" height="5" rx="1" fill="currentColor" opacity="0.3"/>
              <rect x="2" y="2" width="14" height="8" rx="1" fill="currentColor"/>
            </svg>
          </div>
        </div>

        {/* Screen content */}
        <div className="absolute inset-0 pt-[54px] pb-[34px] overflow-y-auto phone-scroll">
          {children}
        </div>

        {/* Home indicator */}
        <div className="absolute bottom-[8px] left-1/2 -translate-x-1/2 w-[134px] h-[5px] bg-crate-text-primary/30 rounded-full" />
      </div>
    </div>
  );
}
