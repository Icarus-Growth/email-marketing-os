-- SQL editor paste 10 of 15: 0011_open_cards_archive.sql
-- Paste all of this into the Supabase SQL editor and press Run.
-- Wait for "Success" before you paste the next file.

-- =============================================================================
-- 0011  The open cards view leaves out archived cards and archived clients
--
-- The same view as in 0004, with two more conditions on each board: the card is
-- not archived, and its client is not archived. The dashboard views read it.
-- A new board added to this view needs the same two conditions.
-- =============================================================================

create or replace view public.v_open_cards with (security_invoker = true) as
select 'tasks'::text as board, 'Tasks'::text as board_label, id as card_id, task_name as card_name,
       client_id, stage::text as stage, split_part(stage::text, ' ', 1)::int as stage_number,
       assignee_id, reviewer_id, due_date, coalesce(stage_changed_at, created_at) as stage_changed_at, is_example
from public.tasks x where (stage not in ('100 - Complete', '-1 - Rejected'))
  and x.archived_at is null
  and not exists (select 1 from public.clients cl where cl.id = x.client_id and cl.archived_at is not null)
union all
select 'flows', 'Flows', id, flow_name,
       client_id, stage::text, split_part(stage::text, ' ', 1)::int,
       assignee_id, reviewer_id, due_date, coalesce(stage_changed_at, created_at), is_example
from public.flows x where (stage <> '60 - Live')
  and x.archived_at is null
  and not exists (select 1 from public.clients cl where cl.id = x.client_id and cl.archived_at is not null)
union all
select 'campaign_calendars', 'Campaigns', id, calendar_name,
       client_id, stage::text, split_part(stage::text, ' ', 1)::int,
       assignee_id, reviewer_id, due_date, coalesce(stage_changed_at, created_at), is_example
from public.campaign_calendars x where (stage not in ('60 - Scheduled', '100 - Done'))
  and x.archived_at is null
  and not exists (select 1 from public.clients cl where cl.id = x.client_id and cl.archived_at is not null);
comment on view public.v_open_cards is 'Every open card on every board, in one shape. Finished and archived cards, and the cards of archived clients, are left out.';
