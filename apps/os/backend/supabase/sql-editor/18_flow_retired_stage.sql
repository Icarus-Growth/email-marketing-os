-- SQL editor paste 18 of 19: 0022_flow_retired_stage.sql
-- Paste all of this into the Supabase SQL editor and press Run.
-- Wait for "Success" before you paste the next file.

-- =============================================================================
-- 0022  Email marketing: flows get a finished stage, "100 - Retired"
--
-- Before: a flow's last stage was "60 - Live", so a flow could never finish.
-- Now: "100 - Retired" is the last stage. A retired flow is finished: it
-- leaves the open cards, like any "100" stage. A live flow stays open on the
-- Flows board, but not on My Work (0023) and never in the stuck or late lists.
-- The new stage is added on its own here, because Postgres cannot use a new
-- list value in the same change that adds it.
-- Safe to run twice.
-- =============================================================================

alter type public.flow_stage add value if not exists '100 - Retired' after '60 - Live';
