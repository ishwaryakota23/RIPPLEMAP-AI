BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "analysis_review" (
    "id" bigserial PRIMARY KEY,
    "authUserId" text NOT NULL,
    "jobKey" text NOT NULL,
    "decision" text NOT NULL,
    "note" text,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "analysis_review_user_job_idx" ON "analysis_review" USING btree ("authUserId", "jobKey");
CREATE INDEX "analysis_review_user_idx" ON "analysis_review" USING btree ("authUserId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "user_settings" (
    "id" bigserial PRIMARY KEY,
    "authUserId" text NOT NULL,
    "selectedRepository" text,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "user_settings_auth_user_id_idx" ON "user_settings" USING btree ("authUserId");


--
-- MIGRATION VERSION FOR ripplemap
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('ripplemap', '20261014122536492-account-settings-reviews', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261014122536492-account-settings-reviews', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260824182259319', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182259319', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260924105232991', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260924105232991', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260924105404509', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260924105404509', "timestamp" = now();


COMMIT;
