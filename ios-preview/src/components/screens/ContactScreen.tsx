"use client";
import { useNavigation } from "../AppNavigator";
import { useState } from "react";

const subjects = ["Bug Report", "Feature Request", "Account Issue", "Apple Music Issue", "Other"];

export default function ContactScreen() {
  const { pop } = useNavigation();
  const [subject, setSubject] = useState("");
  const [body, setBody] = useState("");
  const [sent, setSent] = useState(false);

  const handleSend = () => {
    if (!subject || !body) return;
    setSent(true);
  };

  if (sent) {
    return (
      <div className="flex flex-col h-full bg-crate-void items-center justify-center px-8">
        <div className="w-[80px] h-[80px] rounded-full bg-crate-success/15 flex items-center justify-center mb-6">
          <svg width="36" height="36" viewBox="0 0 24 24" fill="none" className="text-crate-success">
            <path d="M20 6L9 17l-5-5" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"/>
          </svg>
        </div>
        <h2 className="text-[22px] font-bold">Message Sent</h2>
        <p className="text-[15px] text-crate-text-secondary text-center mt-2">
          Thank you for reaching out. We&apos;ll get back to you within 24 hours.
        </p>
        <button className="mt-8 px-8 py-3 bg-crate-accent rounded-[12px] text-[15px] font-medium text-white" onClick={() => pop()}>
          Done
        </button>
      </div>
    );
  }

  return (
    <div className="flex flex-col h-full bg-crate-void">
      {/* Nav */}
      <div className="flex items-center justify-between px-4 py-3 relative">
        <button className="w-8 h-8 flex items-center justify-center" onClick={() => pop()}>
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" className="text-crate-text-primary">
            <path d="M19 12H5M12 19l-7-7 7-7" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
          </svg>
        </button>
        <span className="absolute left-1/2 -translate-x-1/2 text-[11px] font-medium tracking-[2px] uppercase text-crate-text-tertiary">CONTACT</span>
        <div className="w-8" />
      </div>

      <div className="flex-1 overflow-y-auto phone-scroll px-4 pb-20">
        <h2 className="text-[20px] font-bold mt-2">How can we help?</h2>
        <p className="text-[14px] text-crate-text-secondary mt-1">Send us a message and we&apos;ll respond within 24 hours.</p>

        <div className="mt-6 space-y-5">
          {/* Subject */}
          <div>
            <label className="text-[11px] font-medium tracking-[2px] uppercase text-crate-text-muted ml-1">SUBJECT</label>
            <div className="flex flex-wrap gap-2 mt-2">
              {subjects.map(s => (
                <button
                  key={s}
                  className={`px-3 py-1.5 rounded-full text-[13px] border transition-colors ${
                    subject === s ? 'border-crate-accent bg-crate-accent/15 text-crate-accent' : 'border-crate-border text-crate-text-secondary'
                  }`}
                  onClick={() => setSubject(s)}
                >
                  {s}
                </button>
              ))}
            </div>
          </div>

          {/* Message */}
          <div>
            <label className="text-[11px] font-medium tracking-[2px] uppercase text-crate-text-muted ml-1">MESSAGE</label>
            <textarea
              value={body}
              onChange={(e) => setBody(e.target.value)}
              rows={6}
              className="w-full mt-2 px-4 py-3 bg-crate-surface border border-crate-border rounded-[10px] text-[15px] text-crate-text-primary outline-none focus:border-crate-accent transition-colors resize-none"
              placeholder="Describe your issue or suggestion..."
            />
          </div>

          {/* Attachment */}
          <div>
            <label className="text-[11px] font-medium tracking-[2px] uppercase text-crate-text-muted ml-1">ATTACHMENT (OPTIONAL)</label>
            <div className="mt-2 py-6 bg-crate-surface border border-dashed border-crate-border rounded-[10px] flex items-center justify-center cursor-pointer hover:border-crate-accent transition-colors">
              <div className="flex items-center gap-2 text-crate-text-muted">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
                  <path d="M21.44 11.05l-9.19 9.19a6 6 0 0 1-8.49-8.49l9.19-9.19a4 4 0 0 1 5.66 5.66l-9.2 9.19a2 2 0 0 1-2.83-2.83l8.49-8.48" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
                </svg>
                <span className="text-[13px]">Add screenshot</span>
              </div>
            </div>
          </div>
        </div>

        {/* Submit */}
        <button
          className={`w-full mt-6 py-3.5 rounded-[12px] text-[16px] font-semibold text-white transition-colors ${
            subject && body ? 'bg-crate-accent' : 'bg-crate-border cursor-not-allowed'
          }`}
          onClick={handleSend}
        >
          Send Message
        </button>
      </div>
    </div>
  );
}
