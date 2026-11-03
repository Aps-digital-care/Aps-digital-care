import type { Metadata } from "next";
import "./globals.css";
export const metadata: Metadata = {
  title: "APS Digital Care | Innovate. Build. Grow.",
  description: "APS Digital Care delivers web development, mobile apps, cloud solutions, AI automation and digital experiences.",
  keywords: ["APS Digital Care","web development","software development","digital solutions"]
};
export default function RootLayout({children}:{children:React.ReactNode}) {
  return <html lang="en"><body>{children}</body></html>;
}
