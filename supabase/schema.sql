-- Costume Contest schema
-- Run this once in Supabase: Dashboard -> SQL Editor -> New query -> paste -> Run.
-- Also enable anonymous sign-ins: Authentication -> Sign In / Providers -> "Allow anonymous sign-ins".

create table if not exists public.entries (
  id          uuid primary key default gen_random_uuid(),
  name        text not null check (char_length(name) between 1 and 60),
  costume     text not null check (char_length(costume) between 1 and 80),
  description text not null default '' check (char_length(description) <= 200),
  created_by  uuid not null default auth.uid(),
  created_at  timestamptz not null default now()
);

-- One row per visitor = one vote per visitor. Changing your vote updates the row.
create table if not exists public.votes (
  voter_id   uuid primary key default auth.uid(),
  entry_id   uuid not null references public.entries(id) on delete cascade,
  updated_at timestamptz not null default now()
);

alter table public.entries enable row level security;
alter table public.votes   enable row level security;

-- Everyone can see the lineup and the vote tally.
drop policy if exists "entries readable" on public.entries;
create policy "entries readable" on public.entries
  for select to anon, authenticated using (true);

drop policy if exists "votes readable" on public.votes;
create policy "votes readable" on public.votes
  for select to anon, authenticated using (true);

-- Visitors (anonymous sessions count) can add entries as themselves and remove their own.
drop policy if exists "add own entry" on public.entries;
create policy "add own entry" on public.entries
  for insert to authenticated with check (created_by = auth.uid());

drop policy if exists "remove own entry" on public.entries;
create policy "remove own entry" on public.entries
  for delete to authenticated using (created_by = auth.uid());

-- Visitors can only cast, move or withdraw their own vote.
drop policy if exists "cast own vote" on public.votes;
create policy "cast own vote" on public.votes
  for insert to authenticated with check (voter_id = auth.uid());

drop policy if exists "move own vote" on public.votes;
create policy "move own vote" on public.votes
  for update to authenticated using (voter_id = auth.uid()) with check (voter_id = auth.uid());

drop policy if exists "withdraw own vote" on public.votes;
create policy "withdraw own vote" on public.votes
  for delete to authenticated using (voter_id = auth.uid());

-- Live updates for everyone watching the page.
do $$
begin
  begin alter publication supabase_realtime add table public.entries; exception when duplicate_object then null; end;
  begin alter publication supabase_realtime add table public.votes;   exception when duplicate_object then null; end;
end $$;
