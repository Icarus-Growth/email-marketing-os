-- SQL editor paste 4 of 17: 0004_boards.sql
-- Paste all of this into the Supabase SQL editor and press Run.
-- Wait for "Success" before you paste the next file.

-- =============================================================================
-- 0004  Boards: email marketing
--
-- Boards on the Tasks screen: Tasks (made in 0001), Flows and Campaigns.
-- A Campaigns card is one client's campaign calendar for one month: the whole
-- batch moves as one card, because the designers set the pace.
-- emails has no board. Each email shows as a checklist inside its flow or
-- calendar card.
-- =============================================================================

-- Email marketing columns on the client (wide-table rule) ---------------------
alter table public.clients
  add column copywriter_id        uuid references public.team(id) on delete set null,
  add column designer_id          uuid references public.team(id) on delete set null,
  add column builder_id           uuid references public.team(id) on delete set null,
  add column store_url            text,
  add column email_platform       text not null default 'Klaviyo',
  add column platform_access      boolean not null default false,
  add column research_doc_url     text,
  add column brand_assets_url     text;
comment on column public.clients.builder_id is 'The person who builds the emails in the email platform.';
comment on column public.clients.email_platform is 'The email platform, as a value. Never a key or a login.';
comment on column public.clients.platform_access is 'Ticked when the agency has access to the client''s email platform.';

-- Flows board -----------------------------------------------------------------
create type public.flow_stage as enum (
  '0 - Backlog',
  '10 - Brief In Progress',
  '19 - Brief Amendments',
  '20 - Copy',
  '30 - Design',
  '39 - Design Amendments',
  '40 - Design QA',
  '50 - Build In Email Platform',
  '60 - Live'
);

create table public.flows (
  id                   uuid primary key default gen_random_uuid(),
  flow_name            text not null,
  client_id            uuid not null references public.clients(id) on delete cascade,
  flow_type            text,
  stage                public.flow_stage not null default '0 - Backlog',
  stage_changed_at     timestamptz,
  stage_changed_by_id  uuid references public.team(id) on delete set null,
  assignee_id          uuid references public.team(id) on delete set null,
  reviewer_id          uuid references public.team(id) on delete set null,
  brief_url            text,
  copy_doc_url         text,
  design_url           text,
  feedback_notes       text,
  due_date             date,
  live_on              date,
  notes                text,
  is_example           boolean not null default false,
  created_at           timestamptz not null default now(),
  updated_at           timestamptz not null default now()
);
comment on table public.flows is 'One flow for one client. The "Flows" board.';
comment on column public.flows.flow_type is 'For example: Welcome, Abandoned Cart, Abandoned Checkout, Browse Abandon, Post-Purchase, Winback, Sunset.';
create index flows_client_idx on public.flows (client_id);

-- Campaigns board: one monthly campaign calendar per card ---------------------
create type public.calendar_stage as enum (
  '0 - Backlog',
  '10 - Calendar In Progress',
  '19 - Calendar Amendments',
  '20 - Copy',
  '30 - Design',
  '39 - Design Amendments',
  '40 - Design QA',
  '50 - Build In Email Platform',
  '60 - Scheduled',
  '100 - Done'
);

create table public.campaign_calendars (
  id                   uuid primary key default gen_random_uuid(),
  calendar_name        text not null,
  client_id            uuid not null references public.clients(id) on delete cascade,
  calendar_month       date not null,
  stage                public.calendar_stage not null default '0 - Backlog',
  stage_changed_at     timestamptz,
  stage_changed_by_id  uuid references public.team(id) on delete set null,
  assignee_id          uuid references public.team(id) on delete set null,
  reviewer_id          uuid references public.team(id) on delete set null,
  calendar_url         text,
  copy_doc_url         text,
  design_url           text,
  feedback_notes       text,
  due_date             date,
  notes                text,
  is_example           boolean not null default false,
  created_at           timestamptz not null default now(),
  updated_at           timestamptz not null default now(),
  unique (client_id, calendar_month)
);
comment on table public.campaign_calendars is 'One client''s campaign calendar for one month: the whole batch. The "Campaigns" board.';
comment on column public.campaign_calendars.calendar_month is 'The first day of the month the calendar covers.';
create index campaign_calendars_client_idx on public.campaign_calendars (client_id);

-- Emails: no board, a checklist inside a flow or calendar card -----------------
create type public.email_status as enum ('To Write', 'Copy Done', 'Designed', 'Built');

create table public.emails (
  id                uuid primary key default gen_random_uuid(),
  email_name        text not null,
  client_id         uuid not null references public.clients(id) on delete cascade,
  flow_id           uuid references public.flows(id) on delete cascade,
  calendar_id       uuid references public.campaign_calendars(id) on delete cascade,
  status            public.email_status not null default 'To Write',
  position          int not null default 1,
  subject_line      text,
  preview_text      text,
  send_date         date,
  copy_url          text,
  design_url        text,
  offer             text,
  ab_test_result    text,
  is_best_email     boolean not null default false,
  notes             text,
  is_example        boolean not null default false,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  check (flow_id is not null or calendar_id is not null)
);
comment on table public.emails is 'One email. It belongs to a flow or to a monthly campaign calendar.';
comment on column public.emails.position is 'The order of the email inside its flow or calendar.';
create index emails_flow_idx on public.emails (flow_id);
create index emails_calendar_idx on public.emails (calendar_id);

create trigger flows_touch_updated_at before update on public.flows
  for each row execute function public.touch_updated_at();
create trigger campaign_calendars_touch_updated_at before update on public.campaign_calendars
  for each row execute function public.touch_updated_at();
create trigger emails_touch_updated_at before update on public.emails
  for each row execute function public.touch_updated_at();
select public.attach_stage_log('flows');
select public.attach_stage_log('campaign_calendars');

-- Every open card on every board, in one shape. The dashboard reads this.
create view public.v_open_cards with (security_invoker = true) as
select 'tasks'::text as board, 'Tasks'::text as board_label, id as card_id, task_name as card_name,
       client_id, stage::text as stage, split_part(stage::text, ' ', 1)::int as stage_number,
       assignee_id, reviewer_id, due_date, coalesce(stage_changed_at, created_at) as stage_changed_at, is_example
from public.tasks where stage not in ('100 - Complete', '-1 - Rejected')
union all
select 'flows', 'Flows', id, flow_name,
       client_id, stage::text, split_part(stage::text, ' ', 1)::int,
       assignee_id, reviewer_id, due_date, coalesce(stage_changed_at, created_at), is_example
from public.flows where stage <> '60 - Live'
union all
select 'campaign_calendars', 'Campaigns', id, calendar_name,
       client_id, stage::text, split_part(stage::text, ' ', 1)::int,
       assignee_id, reviewer_id, due_date, coalesce(stage_changed_at, created_at), is_example
from public.campaign_calendars where stage not in ('60 - Scheduled', '100 - Done');
comment on view public.v_open_cards is 'Every open card on every board, in one shape. Live, scheduled and done cards are left out.';
