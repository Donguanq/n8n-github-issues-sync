-- GitHub Issues Sync — PostgreSQL schema
-- Creates the table required by the n8n workflows.
-- Safe to run more than once on a fresh/compatible database.

CREATE TABLE IF NOT EXISTS public.github_issues_sync (
    repository      TEXT        NOT NULL,
    github_id       BIGINT      NOT NULL,
    issue_number    INTEGER     NOT NULL,
    title           TEXT        NOT NULL,
    state           TEXT        NOT NULL
        CHECK (state IN ('open', 'closed')),
    author_login    TEXT,
    created_at      TIMESTAMPTZ NOT NULL,
    updated_at      TIMESTAMPTZ NOT NULL,
    closed_at       TIMESTAMPTZ,
    html_url        TEXT        NOT NULL,
    comments_count  INTEGER     NOT NULL DEFAULT 0
        CHECK (comments_count >= 0),
    locked          BOOLEAN     NOT NULL DEFAULT FALSE,
    labels          JSONB       NOT NULL DEFAULT '[]'::JSONB
        CHECK (jsonb_typeof(labels) = 'array'),
    body            TEXT,
    sync_run_id     TEXT        NOT NULL,
    last_synced_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT github_issues_sync_pkey
        PRIMARY KEY (repository, github_id),
    CONSTRAINT github_issues_sync_repository_issue_number_key
        UNIQUE (repository, issue_number)
);

-- Supports the workflow's lookup of previously open issues that were not
-- included in the current synchronization run.
CREATE INDEX IF NOT EXISTS idx_github_issues_sync_open_run
    ON public.github_issues_sync (repository, state, sync_run_id);
