-- V005__seed_data.sql
-- Fake, repeatable seed data for the CyberSafe LA Docker demonstration.
-- Never place real small-business data, real phone numbers, real addresses, passwords,
-- protected health information, cardholder data, or client credentials in this file.

INSERT INTO partner (name, partner_type)
VALUES
  ('LA SBDC Demo Partner', 'Referral Partner'),
  ('East LA Chamber Demo Partner', 'Community Partner'),
  ('SBA Demo Office', 'Federal Agency'),
  ('CISA Region 9 Demo Liaison', 'Federal Agency'),
  ('Google Clinics Fund Demo Liaison', 'Sponsor');

INSERT INTO business (name, naics, employee_count, address, ccpa_flag)
SELECT
  'CyberSafe Demo Business ' || LPAD(i::text, 2, '0'),
  CASE (i % 5)
    WHEN 0 THEN '445110'
    WHEN 1 THEN '541213'
    WHEN 2 THEN '621210'
    WHEN 3 THEN '722511'
    ELSE '813410'
  END,
  3 + (i % 30),
  'Demo service area address ' || i,
  (i % 4 = 0)
FROM generate_series(1, 20) AS s(i);

INSERT INTO contact (business_id, name, role, email, phone, outreach_opt_in)
SELECT
  i,
  'Demo Contact ' || LPAD(i::text, 2, '0'),
  CASE WHEN i % 2 = 0 THEN 'Owner' ELSE 'Office Manager' END,
  'contact' || i || '@example.com',
  '555-01' || LPAD(i::text, 2, '0'),
  (i % 3 = 0)
FROM generate_series(1, 20) AS s(i);

INSERT INTO cohort (term, academic_year)
VALUES
  ('Summer', '2026'),
  ('Spring', '2027');

INSERT INTO consultant (cohort_id, competency_level, specialization)
SELECT
  CASE WHEN i <= 5 THEN 1 ELSE 2 END,
  CASE (i % 3)
    WHEN 0 THEN 'Expert'
    WHEN 1 THEN 'Foundation'
    ELSE 'Professional'
  END,
  CASE (i % 4)
    WHEN 0 THEN 'Identity and Access Management'
    WHEN 1 THEN 'Phishing Awareness'
    WHEN 2 THEN 'Network Basics'
    ELSE 'Compliance Orientation'
  END
FROM generate_series(1, 10) AS s(i);

INSERT INTO faculty_advisor (department, expertise_area, advising_capacity)
VALUES
  ('Information Systems', 'Database systems and governance', 8),
  ('Information Systems', 'Cybersecurity policy and risk', 6),
  ('Information Systems', 'Systems analysis and design', 5);

INSERT INTO industry_mentor (expertise_area, assigned_client_cohort)
VALUES
  ('Identity and Access Management', 'Tier 1 clients'),
  ('Incident Response Planning', 'Professional services clients'),
  ('Cloud Security', 'Workspace clients'),
  ('Compliance Orientation', 'Healthcare and payment clients'),
  ('Network Security', 'Retail and food service clients');

INSERT INTO mou (business_id, pdf_url, version, signature_date, scope_statement)
SELECT
  i,
  'secure-repository/mou/demo-business-' || LPAD(i::text, 2, '0') || '.pdf',
  'v1.0',
  DATE '2026-06-01' + i,
  'Demo advisory-only cybersecurity scope. No credentials, protected health information, or cardholder data stored.'
FROM generate_series(1, 20) AS s(i);

INSERT INTO referral (partner_id, business_id, referral_date, conversion_outcome)
SELECT
  ((i - 1) % 5) + 1,
  i,
  DATE '2026-05-25' + i,
  CASE WHEN i % 4 = 0 THEN 'declined' ELSE 'engaged' END
FROM generate_series(1, 20) AS s(i);

INSERT INTO engagement (business_id, faculty_advisor_id, mou_id, status, opened_date, closed_date)
SELECT
  i,
  ((i - 1) % 3) + 1,
  i,
  CASE (i % 6)
    WHEN 0 THEN 'Closed'
    WHEN 1 THEN 'Intake'
    WHEN 2 THEN 'MOU Execution'
    WHEN 3 THEN 'Assessment'
    WHEN 4 THEN 'Reporting'
    ELSE 'Follow-Up'
  END,
  DATE '2026-06-15' + i,
  CASE WHEN i % 6 = 0 THEN DATE '2026-07-15' + i ELSE NULL END
FROM generate_series(1, 20) AS s(i);

INSERT INTO assignment (engagement_id, consultant_id, mentor_id, role, hours_commitment)
SELECT
  i,
  ((i - 1) % 10) + 1,
  CASE WHEN i % 4 = 0 THEN NULL ELSE ((i - 1) % 5) + 1 END,
  CASE WHEN i % 3 = 0 THEN 'Lead Consultant' ELSE 'Supporting Consultant' END,
  2 + (i % 6)
FROM generate_series(1, 20) AS s(i);

INSERT INTO questionnaire_response (business_id, engagement_id, submitted_at, score_summary)
SELECT
  i,
  i,
  TIMESTAMP '2026-06-15 10:00:00' + (i * INTERVAL '1 hour'),
  json_build_object(
    'risk_band', CASE (i % 4) WHEN 0 THEN 'High' WHEN 1 THEN 'Low' WHEN 2 THEN 'Medium' ELSE 'Critical' END,
    'answers_captured', 10,
    'pci_indicator', (i % 5 = 0),
    'hipaa_indicator', (i % 6 = 0),
    'note', 'Fake questionnaire snapshot for Docker demonstration only'
  )::text
FROM generate_series(1, 20) AS s(i);

INSERT INTO knowledge_base_entry (
  engagement_id,
  domain,
  finding_title,
  finding_description,
  severity,
  recommended_remediat,
  dbir_reference,
  framework_reference
)
SELECT
  i,
  CASE (i % 6)
    WHEN 0 THEN 'Account and Identity'
    WHEN 1 THEN 'Endpoint and Updates'
    WHEN 2 THEN 'Network and Wi-Fi'
    WHEN 3 THEN 'Data Protection and Backups'
    WHEN 4 THEN 'Third-Party and Vendor Risk'
    ELSE 'Awareness and Response'
  END,
  'Demo finding ' || LPAD(i::text, 2, '0'),
  'Fake finding description for repeatable seed data. Do not insert real client evidence here.',
  CASE (i % 5)
    WHEN 0 THEN 'Critical'
    WHEN 1 THEN 'High'
    WHEN 2 THEN 'Medium'
    WHEN 3 THEN 'Low'
    ELSE 'Informational'
  END,
  'Demo remediation language written in plain terms for a small business owner.',
  '2025 DBIR demo reference',
  'NSA/CISA IAM demo reference'
FROM generate_series(1, 20) AS s(i);

INSERT INTO audit_log_entry (actor_role, entity_name, action_type)
SELECT
  'seed_script',
  CASE (i % 5)
    WHEN 0 THEN 'business'
    WHEN 1 THEN 'contact'
    WHEN 2 THEN 'engagement'
    WHEN 3 THEN 'questionnaire_response'
    ELSE 'knowledge_base_entry'
  END,
  CASE (i % 3)
    WHEN 0 THEN 'INSERT'
    WHEN 1 THEN 'UPDATE'
    ELSE 'PERMISSION_TEST'
  END
FROM generate_series(1, 12) AS s(i);
