-- V003__roles_permissions.sql
-- Creates the required CyberSafe LA PostgreSQL roles.
-- cybersafe_read is SELECT only.
-- cybersafe_app is read/write on non-audit tables and INSERT only on audit_log_entry.

DO $$
BEGIN
  CREATE ROLE cybersafe_read NOLOGIN;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  CREATE ROLE cybersafe_app NOLOGIN;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

GRANT USAGE ON SCHEMA public TO cybersafe_read, cybersafe_app;

GRANT SELECT ON ALL TABLES IN SCHEMA public TO cybersafe_read;
REVOKE INSERT, UPDATE, DELETE, TRUNCATE ON ALL TABLES IN SCHEMA public FROM cybersafe_read;

GRANT SELECT, INSERT, UPDATE ON
  business,
  contact,
  cohort,
  consultant,
  faculty_advisor,
  industry_mentor,
  assignment,
  mou,
  referral,
  partner,
  engagement,
  questionnaire_response,
  knowledge_base_entry
TO cybersafe_app;

GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO cybersafe_app;

REVOKE ALL ON TABLE audit_log_entry FROM cybersafe_app;
GRANT INSERT ON TABLE audit_log_entry TO cybersafe_app;

ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO cybersafe_read;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE ON TABLES TO cybersafe_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT ON SEQUENCES TO cybersafe_app;

GRANT cybersafe_read TO cybersafe_admin;
GRANT cybersafe_app TO cybersafe_admin;
