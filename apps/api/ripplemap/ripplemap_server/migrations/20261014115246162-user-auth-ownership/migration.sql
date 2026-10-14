BEGIN;

--
-- ACTION ALTER TABLE
--
DROP INDEX "analysis_job_session_id_idx";
ALTER TABLE "analysis_job" ADD COLUMN "authUserId" text;
ALTER TABLE "analysis_job" ALTER COLUMN "sessionId" DROP NOT NULL;
CREATE INDEX "analysis_job_auth_user_id_idx" ON "analysis_job" USING btree ("authUserId");
--
-- ACTION ALTER TABLE
--
DROP INDEX "github_connection_session_id_idx";
ALTER TABLE "github_connection" ADD COLUMN "authUserId" text;
ALTER TABLE "github_connection" ALTER COLUMN "sessionId" DROP NOT NULL;
CREATE UNIQUE INDEX "github_connection_auth_user_id_idx" ON "github_connection" USING btree ("authUserId");

--
-- MIGRATION VERSION FOR ripplemap
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('ripplemap', '20261014115246162-user-auth-ownership', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261014115246162-user-auth-ownership', "timestamp" = now();

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
