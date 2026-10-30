-- Interview question: "Do you keep a 'best emails' library?"
-- YES: adds a library with one row per winning email per month, and why it won.
-- NO:  skip this file. The "is_best_email" tick on each email is enough.

create table public.best_emails (
  id            uuid primary key default gen_random_uuid(),
  entry_name    text not null,
  client_id     uuid not null references public.clients(id) on delete cascade,
  email_id      uuid references public.emails(id) on delete set null,
  best_month    date not null,
  why_it_won    text,
  revenue       numeric(14,2),
  screenshot_url text,
  is_example    boolean not null default false,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);
comment on table public.best_emails is 'One winning email in one month. best_month is the first day of the month.';
create trigger best_emails_touch_updated_at before update on public.best_emails
  for each row execute function public.touch_updated_at();
select public.lock_table('best_emails');
