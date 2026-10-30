-- =============================================================================
-- Example rows. Every row here is fake and has is_example = true.
-- Remove them all with docs/examples/delete_examples.sql.
-- Example people cannot sign in (can_sign_in = false).
-- =============================================================================

insert into public.team (id, full_name, email, job_title, access, can_sign_in, capacity, is_example) values
  ('aaaaaaaa-0000-4000-8000-000000000001', 'Alex Example',  'alex@example.com',  'Account Manager', 'Member', false, 8, true),
  ('aaaaaaaa-0000-4000-8000-000000000002', 'Sam Example',   'sam@example.com',   'Specialist',      'Member', false, 6, true),
  ('aaaaaaaa-0000-4000-8000-000000000003', 'Jordan Example','jordan@example.com','Specialist',      'Member', false, 2, true);

insert into public.clients (id, client_name, status, website, contact_name, contact_email, start_date,
                            onboarding_stage, account_manager_id, notes, is_example) values
  ('cccccccc-0000-4000-8000-000000000001', 'Example Client A', 'Active', 'https://example.com', 'Pat Example', 'pat@example.com',
   current_date - 60, '100 - Onboarded', 'aaaaaaaa-0000-4000-8000-000000000001', 'Example row.', true),
  ('cccccccc-0000-4000-8000-000000000002', 'Example Client B', 'Active', 'https://example.org', 'Lee Example', 'lee@example.org',
   current_date - 20, '50 - Call Taken', 'aaaaaaaa-0000-4000-8000-000000000001', 'Example row.', true),
  ('cccccccc-0000-4000-8000-000000000003', 'Example Client C', 'Active', 'https://example.net', 'Kim Example', 'kim@example.net',
   current_date - 2, '10 - Contract Sent', 'aaaaaaaa-0000-4000-8000-000000000002', 'Example row.', true);

-- Onboarding that has not moved for a while, so the dashboard has something to show.
update public.clients set onboarding_stage_changed_at = now() - interval '9 days'
where id = 'cccccccc-0000-4000-8000-000000000002';

insert into public.tasks (task_name, client_id, stage, assignee_id, due_date, is_example) values
  ('Example: send the welcome pack',        'cccccccc-0000-4000-8000-000000000003', '10 - In Progress', 'aaaaaaaa-0000-4000-8000-000000000001', current_date + 1, true),
  ('Example: book the onboarding call',     'cccccccc-0000-4000-8000-000000000002', '9 - Blocked',      'aaaaaaaa-0000-4000-8000-000000000001', current_date - 2, true),
  ('Example: tidy the shared drive',        null,                                   '0 - Backlog',      'aaaaaaaa-0000-4000-8000-000000000003', null,             true),
  ('Example: monthly check-in notes',       'cccccccc-0000-4000-8000-000000000001', '30 - In Review',   'aaaaaaaa-0000-4000-8000-000000000002', current_date,     true);

insert into public.calls (client_id, title, call_type, call_at, summary, action_items, is_example) values
  ('cccccccc-0000-4000-8000-000000000001', 'Example: monthly check-in', 'Check-In',   now() - interval '7 days',
   'Example summary. The client is happy with the results so far.', 'Send the next month''s plan.', true),
  ('cccccccc-0000-4000-8000-000000000002', 'Example: onboarding call',  'Onboarding', now() - interval '3 days',
   'Example summary. Access was given during the call.', 'Start the first piece of work.', true),
  ('cccccccc-0000-4000-8000-000000000003', 'Example: sales call',       'Sales',      now() - interval '10 days',
   'Example summary. The client signed up after the call.', 'Send the contract.', true);

insert into public.onboarding_forms (client_id, submitted_by_name, submitted_by_email, company_name, answers, is_example) values
  ('cccccccc-0000-4000-8000-000000000002', 'Lee Example', 'lee@example.org', 'Example Client B',
   '{"what_do_you_sell": "Example answer.", "who_do_you_sell_to": "Example answer."}'::jsonb, true);

update public.clients set form_received_at = now() - interval '4 days'
where id = 'cccccccc-0000-4000-8000-000000000002';

-- Email marketing examples ------------------------------------------------------
update public.clients set copywriter_id = 'aaaaaaaa-0000-4000-8000-000000000002',
       designer_id = 'aaaaaaaa-0000-4000-8000-000000000003', builder_id = 'aaaaaaaa-0000-4000-8000-000000000002',
       store_url = 'https://shop.example.com'
where is_example;

insert into public.flows (id, flow_name, client_id, flow_type, stage, assignee_id, reviewer_id, due_date, is_example) values
  ('ffffffff-0000-4000-8000-000000000001', 'Example: welcome flow',        'cccccccc-0000-4000-8000-000000000001', 'Welcome',        '60 - Live',             'aaaaaaaa-0000-4000-8000-000000000002', 'aaaaaaaa-0000-4000-8000-000000000001', current_date - 20, true),
  ('ffffffff-0000-4000-8000-000000000002', 'Example: abandoned cart flow', 'cccccccc-0000-4000-8000-000000000001', 'Abandoned Cart', '30 - Design',           'aaaaaaaa-0000-4000-8000-000000000003', 'aaaaaaaa-0000-4000-8000-000000000001', current_date + 2,  true),
  ('ffffffff-0000-4000-8000-000000000003', 'Example: post-purchase flow',  'cccccccc-0000-4000-8000-000000000002', 'Post-Purchase',  '39 - Design Amendments','aaaaaaaa-0000-4000-8000-000000000003', 'aaaaaaaa-0000-4000-8000-000000000001', current_date - 1,  true);

insert into public.campaign_calendars (id, calendar_name, client_id, calendar_month, stage, assignee_id, reviewer_id, due_date, is_example) values
  ('eeeeeeee-0000-4000-8000-000000000001', 'Example: next month''s calendar', 'cccccccc-0000-4000-8000-000000000001',
   (date_trunc('month', current_date) + interval '1 month')::date, '20 - Copy', 'aaaaaaaa-0000-4000-8000-000000000002', 'aaaaaaaa-0000-4000-8000-000000000001', current_date + 5, true),
  ('eeeeeeee-0000-4000-8000-000000000002', 'Example: this month''s calendar', 'cccccccc-0000-4000-8000-000000000002',
   date_trunc('month', current_date)::date, '40 - Design QA', 'aaaaaaaa-0000-4000-8000-000000000001', 'aaaaaaaa-0000-4000-8000-000000000001', current_date, true);

insert into public.emails (email_name, client_id, flow_id, calendar_id, status, position, subject_line, is_example) values
  ('Example: welcome 1',  'cccccccc-0000-4000-8000-000000000001', 'ffffffff-0000-4000-8000-000000000001', null, 'Built',     1, 'Example subject', true),
  ('Example: welcome 2',  'cccccccc-0000-4000-8000-000000000001', 'ffffffff-0000-4000-8000-000000000001', null, 'Built',     2, 'Example subject', true),
  ('Example: cart 1',     'cccccccc-0000-4000-8000-000000000001', 'ffffffff-0000-4000-8000-000000000002', null, 'Copy Done', 1, 'Example subject', true),
  ('Example: sale email', 'cccccccc-0000-4000-8000-000000000001', null, 'eeeeeeee-0000-4000-8000-000000000001', 'To Write', 1, null, true),
  ('Example: news email', 'cccccccc-0000-4000-8000-000000000001', null, 'eeeeeeee-0000-4000-8000-000000000001', 'To Write', 2, null, true);

insert into public.daily_metrics (client_id, metric_date, attributed_revenue, emails_delivered, opens, clicks, placed_orders, list_size, source, is_example) values
  ('cccccccc-0000-4000-8000-000000000001', current_date - 3, 820.00,  4000, 1500, 90,  12, 21000, 'Klaviyo', true),
  ('cccccccc-0000-4000-8000-000000000001', current_date - 2, 310.00,  1200, 470,  25,  4,  21040, 'Klaviyo', true),
  ('cccccccc-0000-4000-8000-000000000001', current_date - 1, 1240.00, 5200, 2000, 130, 18, 21110, 'Klaviyo', true);

insert into public.weekly_metrics (client_id, week_start, attributed_revenue, emails_delivered, opens, clicks, placed_orders, list_size, note, is_example) values
  ('cccccccc-0000-4000-8000-000000000001', date_trunc('week', current_date)::date - 7, 5200.00, 19000, 7100, 420, 61, 20950, 'Example note.', true);

-- Example documents (0013, 0014): one on a card, one on a client page.
insert into public.documents (client_id, board, card_id, field_key, body_md, word_count, updated_by)
select c.client_id, 'flows', c.id, 'copy_doc', d.body, coalesce(array_length(regexp_split_to_array(btrim(d.body), '\s+'), 1), 0), 'aaaaaaaa-0000-4000-8000-000000000001'
from public.flows c, (values ($doc$## Welcome 1

Subject: welcome in

Preview: here is what happens next

Thanks for joining. Here is a small gift to start.$doc$)) d(body)
where c.flow_name = 'Example: welcome flow' and c.is_example;

insert into public.documents (client_id, field_key, body_md, word_count, updated_by)
select 'cccccccc-0000-4000-8000-000000000001', 'research_doc', d.body, coalesce(array_length(regexp_split_to_array(btrim(d.body), '\s+'), 1), 0), 'aaaaaaaa-0000-4000-8000-000000000001'
from (values ($doc$# Research

- Best sellers: the starter kit and the refill pack
- Top reason people buy: it saves time
- Top reason they wait: price$doc$)) d(body);
