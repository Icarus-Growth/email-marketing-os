/* What this agency is: an email marketing agency.
 *
 * The boards, their stage ladders, the fields on a card, the agency's own columns on the client
 * page and the weekly numbers. Change a stage here AND in the database, then run
 * `python3 tests/config_matches_db.py`. */
import type { AgencyConfig, ChecklistDef, Ladders } from './config';

/** The agency's own database lists. They must match the migrations exactly. */
export const LADDERS = {
  flow_stage: [
    '0 - Backlog',
    '10 - Brief In Progress',
    '19 - Brief Amendments',
    '20 - Copy',
    '30 - Design',
    '39 - Design Amendments',
    '40 - Design QA',
    '50 - Build In Email Platform',
    '60 - Live',
    '100 - Retired',
  ],
  calendar_stage: [
    '0 - Backlog',
    '10 - Calendar In Progress',
    '19 - Calendar Amendments',
    '20 - Copy',
    '30 - Design',
    '39 - Design Amendments',
    '40 - Design QA',
    '50 - Build In Email Platform',
    '60 - Scheduled',
    '100 - Done',
  ],
  email_status: ['To Write', 'Copy Done', 'Designed', 'Built'],
} as const satisfies Ladders;

/** The emails inside a card: a checklist, no board. */
function emails(parentKey: string): ChecklistDef {
  return { table: 'emails', label: 'Emails', parentKey, nameKey: 'email_name', statusKey: 'status', statusList: 'email_status', orderKey: 'position' };
}

export const AGENCY: AgencyConfig = {
  agency: 'Email Marketing',
  boards: [
    {
      table: 'flows',
      label: 'Flows',
      item: 'flow',
      desc: 'One card is one flow for one client, from brief to live. A live flow runs on its own: it stays on this board but not on My Work, and is never late or stuck. A flow that is switched off or replaced moves to "100 - Retired". Its emails are a checklist inside the card.',
      nameKey: 'flow_name',
      stageKey: 'stage',
      ladder: 'flow_stage',
      closed: ['100 - Retired'],
      live: ['60 - Live'],
      liveOnMyWork: false,
      clientRequired: true,
      card: ['client_id', 'assignee_id', 'due_date'],
      sections: [
        { title: 'Basic details', desc: 'What the flow is, for which client, and who works on it.', fields: [
          { key: 'flow_name', label: 'Flow', type: 'text', required: true },
          { key: 'client_id', label: 'Client', type: 'client', required: true },
          { key: 'flow_type', label: 'Flow type', type: 'text', desc: 'For example Welcome, Abandoned Cart, Post-Purchase, Winback.' },
          { key: 'assignee_id', label: 'Assignee', type: 'person', desc: 'Who must act now.' },
          { key: 'reviewer_id', label: 'Reviewer', type: 'person', desc: 'Who checks the brief and the design.' },
        ] },
        { title: 'Flow details', desc: 'For the copywriter, the designer and the builder: the brief, the copy and the design.', fields: [
          { key: 'due_date', label: 'Due date', type: 'date' },
          { key: 'brief', label: 'Brief', type: 'document', link: 'brief_url' },
          { key: 'copy_doc', label: 'Copy document', type: 'document', link: 'copy_doc_url', check: 'email-copy', desc: 'Write "Subject:" and "Preview text:" lines: the editor checks their length.' },
          { key: 'design_url', label: 'Design', type: 'url' },
          { key: 'live_on', label: 'Live on', type: 'date' },
        ] },
        { title: 'Feedback and notes', desc: 'What the reviewer or the client asked to change.', fields: [
          { key: 'feedback_notes', label: 'Feedback', type: 'longtext' },
          { key: 'notes', label: 'Notes', type: 'longtext' },
        ] },
      ],
      create: ['flow_name', 'client_id', 'flow_type', 'assignee_id'],
      checklist: emails('flow_id'),
    },
    {
      table: 'campaign_calendars',
      label: 'Campaigns',
      item: 'campaign calendar',
      desc: 'One card is one client\'s campaign calendar for one month. The whole batch moves as one card.',
      nameKey: 'calendar_name',
      stageKey: 'stage',
      ladder: 'calendar_stage',
      closed: ['100 - Done'],
      live: ['60 - Scheduled'],
      clientRequired: true,
      card: ['client_id', 'assignee_id', 'due_date'],
      sections: [
        { title: 'Basic details', desc: 'Which client and month the calendar covers, and who works on it.', fields: [
          { key: 'calendar_name', label: 'Calendar', type: 'text', required: true },
          { key: 'client_id', label: 'Client', type: 'client', required: true },
          { key: 'calendar_month', label: 'Month', type: 'month', required: true },
          { key: 'assignee_id', label: 'Assignee', type: 'person', desc: 'Who must act now.' },
          { key: 'reviewer_id', label: 'Reviewer', type: 'person', desc: 'Who checks the calendar and the design.' },
        ] },
        { title: 'Calendar details', desc: 'For the copywriter, the designer and the builder: the plan, the copy and the design.', fields: [
          { key: 'due_date', label: 'Due date', type: 'date' },
          { key: 'calendar_url', label: 'Calendar', type: 'url' },
          { key: 'copy_doc', label: 'Copy document', type: 'document', link: 'copy_doc_url', check: 'email-copy' },
          { key: 'design_url', label: 'Design', type: 'url' },
        ] },
        { title: 'Feedback and notes', desc: 'What the reviewer or the client asked to change.', fields: [
          { key: 'feedback_notes', label: 'Feedback', type: 'longtext' },
          { key: 'notes', label: 'Notes', type: 'longtext' },
        ] },
      ],
      create: ['calendar_name', 'client_id', 'calendar_month', 'assignee_id'],
      checklist: emails('calendar_id'),
    },
  ],
  lists: [],
  clientSections: [
    { title: 'People', desc: 'Who looks after this client in each role.', fields: [
      { key: 'account_manager_id', label: 'Account manager', type: 'person' },
      { key: 'copywriter_id', label: 'Copywriter', type: 'person' },
      { key: 'designer_id', label: 'Designer', type: 'person' },
      { key: 'builder_id', label: 'Email builder', type: 'person', desc: 'Who builds the emails in the email platform.' },
    ] },
    { title: 'Email marketing', desc: 'The store, the email platform and what the team works from.', fields: [
      { key: 'store_url', label: 'Store', type: 'url' },
      { key: 'email_platform', label: 'Email platform', type: 'text' },
      { key: 'platform_access', label: 'We have platform access', type: 'bool' },
      { key: 'research_doc', label: 'Research document', type: 'document', link: 'research_doc_url' },
      { key: 'brand_assets_url', label: 'Brand assets', type: 'url' },
    ] },
  ],
  metrics: [
    { key: 'attributed_revenue', label: 'Attributed revenue', format: 'money' },
    { key: 'list_size', label: 'List size', format: 'int' },
    { key: 'open_rate', label: 'Open rate', format: 'percent' },
    { key: 'click_rate', label: 'Click rate', format: 'percent' },
    { key: 'placed_order_rate', label: 'Placed-order rate', format: 'percent' },
  ],
};
