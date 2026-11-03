# APS Digital Care website starter

A responsive Next.js website starter for APS Digital Care with a custom SVG logo, service showcase, project concept gallery, interactive estimate calculator, contact form, appointment request, newsletter form, FAQ-style chat assistant, admin sign-in shell and client portal sign-in shell.

## Run locally

1. Install Node.js 18.17+.
2. Extract this project and run `npm install`.
3. Copy `.env.example` to `.env.local`.
4. Add your Supabase project URL and publishable (or anon) key.
5. In Supabase SQL Editor, run `supabase/schema.sql`.
6. Run `npm run dev` and open http://localhost:3000.

## Supabase setup

Create a Supabase project at https://supabase.com. Set:
- `NEXT_PUBLIC_SUPABASE_URL`
- `NEXT_PUBLIC_SUPABASE_ANON_KEY` (publishable/anon key only)

Never put the Supabase `service_role` secret in browser code or commit it to Git.

The contact, booking and newsletter forms insert rows into `inquiries`, `bookings` and `newsletter_subscribers`. The admin and client portal pages use Supabase email/password authentication. Create accounts through Supabase Auth and grant an admin role manually in `profiles` only after verifying the account.

## Important launch checklist

- Replace the sample email, phone, location and WhatsApp link in `app/page.tsx` with verified business details.
- Add real portfolio projects, approved testimonials, team profiles and blog content. The sample project tiles are explicitly marked as concepts.
- Configure Supabase Auth email templates, redirect URLs and password reset.
- Review and test RLS policies for your specific admin/employee workflow before enabling any management CRUD. Do not expose service-role credentials.
- Add server-side AI provider integration for a production AI chatbot; the included assistant is a functional FAQ/demo widget, not a generative AI service.
- Connect a calendar provider for live appointment slots if needed; the current form records appointment requests.
- Add a compliant privacy policy, terms, cookie notice if applicable, analytics consent and spam protection/rate limiting before public launch.
- Deploy to Vercel and configure the same environment variables there.

## Included routes
- `/` main marketing website
- `/admin` admin authentication shell
- `/portal` client authentication shell
