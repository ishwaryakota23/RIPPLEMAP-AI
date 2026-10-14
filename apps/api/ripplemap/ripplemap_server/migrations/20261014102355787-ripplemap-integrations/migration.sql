BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "analysis_job" (
    "id" bigserial PRIMARY KEY,
    "jobKey" text NOT NULL,
    "sessionId" text NOT NULL,
    "owner" text NOT NULL,
    "repository" text NOT NULL,
    "pullRequestNumber" bigint NOT NULL,
    "status" text NOT NULL,
    "reportJson" text,
    "errorMessage" text,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "analysis_job_key_idx" ON "analysis_job" USING btree ("jobKey");
CREATE INDEX "analysis_job_session_id_idx" ON "analysis_job" USING btree ("sessionId");
CREATE INDEX "analysis_job_created_at_idx" ON "analysis_job" USING btree ("createdAt");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "github_connection" (
    "id" bigserial PRIMARY KEY,
    "sessionId" text NOT NULL,
    "githubLogin" text NOT NULL,
    "encryptedAccessToken" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "github_connection_session_id_idx" ON "github_connection" USING btree ("sessionId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "webhook_delivery" (
    "id" bigserial PRIMARY KEY,
    "deliveryId" text NOT NULL,
    "eventType" text NOT NULL,
    "receivedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "webhook_delivery_id_idx" ON "webhook_delivery" USING btree ("deliveryId");


--
-- MIGRATION VERSION FOR ripplemap
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('ripplemap', '20261014102355787-ripplemap-integrations', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261014102355787-ripplemap-integrations', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260824182259319', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182259319', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260924105404509', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260924105404509', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260924105232991', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260924105232991', "timestamp" = now();


COMMIT;
