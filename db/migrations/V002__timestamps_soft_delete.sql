-- V002__timestamps_soft_delete.sql
-- Adds updated_at trigger behavior to every approved CyberSafe LA table.
-- created_at and deleted_at columns are already created in V001.

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DO $$
DECLARE
  target_table TEXT;
BEGIN
  FOREACH target_table IN ARRAY ARRAY[
    'business',
    'contact',
    'cohort',
    'consultant',
    'faculty_advisor',
    'industry_mentor',
    'assignment',
    'mou',
    'referral',
    'partner',
    'engagement',
    'questionnaire_response',
    'knowledge_base_entry',
    'audit_log_entry'
  ] LOOP
    EXECUTE format('DROP TRIGGER IF EXISTS %I ON %I;',
      'trg_' || target_table || '_updated_at', target_table);
    EXECUTE format(
      'CREATE TRIGGER %I BEFORE UPDATE ON %I FOR EACH ROW EXECUTE FUNCTION set_updated_at();',
      'trg_' || target_table || '_updated_at', target_table);
  END LOOP;
END $$;
