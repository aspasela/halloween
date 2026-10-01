-- Run once in Supabase (SQL Editor -> New query -> paste -> Run) if you already ran schema.sql before.
-- Adds the voter's name to each vote so the results page can show who voted for whom.
alter table public.votes
  add column if not exists voter_name text not null default ''
  check (char_length(voter_name) <= 60);
