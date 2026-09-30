# Halloween Costume Contest

A small site where people add their name and costume, and visitors vote for the best one. Each visitor gets one vote and can move it. The page updates live as entries and votes come in.

It's a static site (runs on GitHub Pages) with Supabase storing entries and votes.

## Setup (about 10 minutes)

1. **Create a Supabase project** at https://supabase.com (free tier is fine).
2. **Create the tables.** In Supabase, open *SQL Editor → New query*, paste the contents of `supabase/schema.sql`, and click *Run*.
3. **Turn on anonymous sign-ins.** *Authentication → Sign In / Providers → Allow anonymous sign-ins*. This gives each visitor's browser an identity, which is how "one vote per visitor" works without making anyone sign up.
4. **Add your keys.** In *Project Settings → API*, copy the Project URL and the `anon` (publishable) key into `config.js`. This key is meant to be public; the row-level security rules in `schema.sql` keep people from changing anyone else's entry or vote.
5. **Publish with GitHub Pages.** In the repo on GitHub: *Settings → Pages → Build and deployment → Deploy from a branch*, pick `main` and `/ (root)`, and save. The site appears at `https://<your-username>.github.io/<repo>/` within a minute or two.

## Running the contest

- **Remove an entry or reset votes:** use Supabase's *Table Editor* on the `entries` or `votes` table. Deleting an entry also deletes its votes.
- **Close voting:** in the SQL Editor run
  `drop policy "cast own vote" on public.votes; drop policy "move own vote" on public.votes; drop policy "withdraw own vote" on public.votes;`
  The tally stays visible, but nobody can change it.
- **Fairness note:** one vote per visitor means one per browser. Someone could vote again from a private window or another device. That's fine for a party. For a stricter contest you'd need real sign-in (e.g. email magic links).

## Files

- `index.html` – the page
- `config.js` – your Supabase URL and key
- `supabase/schema.sql` – tables and access rules
