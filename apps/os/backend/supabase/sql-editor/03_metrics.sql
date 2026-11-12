-- SQL editor paste 3 of 19: 0003_metrics.sql
-- Paste all of this into the Supabase SQL editor and press Run.
-- Wait for "Success" before you paste the next file.

-- =============================================================================
-- 0003  Report numbers: email marketing
--
-- daily_metrics:  one client on one day.
-- weekly_metrics: one client in one week (week_start is a Monday).
-- They stay empty until you connect your email platform. The platform is a
-- value in the "source" column, never a column name.
-- Rates are worked out by the database from the counts.
-- =============================================================================

create table public.daily_metrics (
  id                   uuid primary key default gen_random_uuid(),
  client_id            uuid not null references public.clients(id) on delete cascade,
  metric_date          date not null,
  attributed_revenue   numeric(14,2) not null default 0,
  emails_delivered     int not null default 0,
  opens                int not null default 0,
  clicks               int not null default 0,
  placed_orders        int not null default 0,
  list_size            int,
  open_rate            numeric generated always as (round(opens::numeric / nullif(emails_delivered, 0), 4)) stored,
  click_rate           numeric generated always as (round(clicks::numeric / nullif(emails_delivered, 0), 4)) stored,
  placed_order_rate    numeric generated always as (round(placed_orders::numeric / nullif(emails_delivered, 0), 4)) stored,
  source               text,
  is_example           boolean not null default false,
  created_at           timestamptz not null default now(),
  updated_at           timestamptz not null default now(),
  unique (client_id, metric_date)
);
comment on table public.daily_metrics is 'One client on one day. Email marketing numbers. list_size is the total at the end of the day.';

create table public.weekly_metrics (
  id                   uuid primary key default gen_random_uuid(),
  client_id            uuid not null references public.clients(id) on delete cascade,
  week_start           date not null,
  attributed_revenue   numeric(14,2) not null default 0,
  emails_delivered     int not null default 0,
  opens                int not null default 0,
  clicks               int not null default 0,
  placed_orders        int not null default 0,
  list_size            int,
  open_rate            numeric generated always as (round(opens::numeric / nullif(emails_delivered, 0), 4)) stored,
  click_rate           numeric generated always as (round(clicks::numeric / nullif(emails_delivered, 0), 4)) stored,
  placed_order_rate    numeric generated always as (round(placed_orders::numeric / nullif(emails_delivered, 0), 4)) stored,
  note                 text,
  is_example           boolean not null default false,
  created_at           timestamptz not null default now(),
  updated_at           timestamptz not null default now(),
  unique (client_id, week_start)
);
comment on table public.weekly_metrics is 'One client in one week. The daily numbers summed, plus a short note.';

create trigger daily_metrics_touch_updated_at before update on public.daily_metrics
  for each row execute function public.touch_updated_at();
create trigger weekly_metrics_touch_updated_at before update on public.weekly_metrics
  for each row execute function public.touch_updated_at();
