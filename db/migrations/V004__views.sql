-- V004__views.sql
-- Operational views required for the CyberSafe LA Option B database scope.
-- These views use only approved tables and columns from the final Entity Relationship Diagram.

CREATE OR REPLACE VIEW v_active_engagements_by_status AS
SELECT
  status,
  COUNT(*) AS active_count,
  COUNT(*) FILTER (WHERE opened_date IS NOT NULL) AS opened_count,
  COUNT(*) FILTER (WHERE closed_date IS NOT NULL) AS closed_count
FROM engagement
WHERE deleted_at IS NULL
GROUP BY status
ORDER BY status;

CREATE OR REPLACE VIEW v_referral_conversion_by_partner AS
SELECT
  p.partner_id,
  p.name AS partner_name,
  COUNT(r.referral_id) AS referrals_total,
  COUNT(DISTINCT e.engagement_id) FILTER (WHERE e.engagement_id IS NOT NULL) AS converted_total,
  ROUND(
    COUNT(DISTINCT e.engagement_id) FILTER (WHERE e.engagement_id IS NOT NULL)::numeric
    / NULLIF(COUNT(r.referral_id), 0),
    2
  ) AS conversion_rate
FROM partner p
LEFT JOIN referral r
  ON r.partner_id = p.partner_id
 AND r.deleted_at IS NULL
LEFT JOIN engagement e
  ON e.business_id = r.business_id
 AND e.deleted_at IS NULL
WHERE p.deleted_at IS NULL
GROUP BY p.partner_id, p.name
ORDER BY p.name;

CREATE OR REPLACE VIEW v_consultant_workload AS
SELECT
  c.consultant_id,
  c.cohort_id,
  co.term,
  co.academic_year,
  c.competency_level,
  COUNT(a.assignment_id) AS assignment_count,
  COALESCE(SUM(a.hours_commitment), 0) AS total_hours_commitment
FROM consultant c
JOIN cohort co
  ON co.cohort_id = c.cohort_id
LEFT JOIN assignment a
  ON a.consultant_id = c.consultant_id
 AND a.deleted_at IS NULL
WHERE c.deleted_at IS NULL
GROUP BY c.consultant_id, c.cohort_id, co.term, co.academic_year, c.competency_level
ORDER BY c.consultant_id;

CREATE OR REPLACE VIEW v_questionnaire_risk_summary AS
SELECT
  CASE
    WHEN score_summary ILIKE '%Critical%' THEN 'Critical'
    WHEN score_summary ILIKE '%High%' THEN 'High'
    WHEN score_summary ILIKE '%Medium%' THEN 'Medium'
    WHEN score_summary ILIKE '%Low%' THEN 'Low'
    ELSE 'Unspecified'
  END AS risk_band,
  COUNT(*) AS response_count,
  MIN(submitted_at) AS earliest_submission,
  MAX(submitted_at) AS latest_submission
FROM questionnaire_response
WHERE deleted_at IS NULL
GROUP BY risk_band
ORDER BY risk_band;

GRANT SELECT ON v_active_engagements_by_status TO cybersafe_read, cybersafe_app;
GRANT SELECT ON v_referral_conversion_by_partner TO cybersafe_read, cybersafe_app;
GRANT SELECT ON v_consultant_workload TO cybersafe_read, cybersafe_app;
GRANT SELECT ON v_questionnaire_risk_summary TO cybersafe_read, cybersafe_app;
