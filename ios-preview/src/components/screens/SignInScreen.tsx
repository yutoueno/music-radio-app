"use client";

export default function SignInScreen() {
  return (
    <div className="flex flex-col h-full bg-crate-void justify-center px-6">
      {/* Logo */}
      <div className="text-center mb-10">
        <h1 className="text-[28px] font-bold tracking-[4px]">CRATE</h1>
        <div className="w-12 h-[1px] bg-crate-accent/30 mx-auto mt-2" />
      </div>

      {/* Form */}
      <div className="flex flex-col gap-3">
        <input
          type="text"
          placeholder="Email"
          readOnly
          className="w-full px-4 py-3 bg-crate-elevated border border-crate-border rounded-[10px] text-[15px] text-crate-text-primary placeholder:text-crate-text-tertiary outline-none"
        />
        <input
          type="password"
          placeholder="Password"
          readOnly
          className="w-full px-4 py-3 bg-crate-elevated border border-crate-border rounded-[10px] text-[15px] text-crate-text-primary placeholder:text-crate-text-tertiary outline-none"
        />
      </div>

      <button className="w-full mt-5 py-3.5 bg-crate-accent rounded-[10px] text-[16px] font-semibold text-white">
        Sign In
      </button>

      <button className="mt-4 text-[13px] text-crate-text-tertiary text-center">
        Forgot password?
      </button>

      <div className="mt-8 text-center">
        <span className="text-[13px] text-crate-text-muted">Don&apos;t have an account? </span>
        <span className="text-[13px] text-crate-accent font-medium">Create Account</span>
      </div>
    </div>
  );
}
