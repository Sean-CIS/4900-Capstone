$ErrorActionPreference = "Continue"

Write-Host "1. Docker Compose container status"
docker compose ps

Write-Host "2. PostgreSQL readiness"
docker compose exec db pg_isready -U cybersafe_admin -d cybersafe_la

Write-Host "3. Flyway migration history"
docker compose exec db psql -U cybersafe_admin -d cybersafe_la -c "SELECT installed_rank, version, description, success FROM flyway_schema_history ORDER BY installed_rank;"

Write-Host "4. Table list"
docker compose exec db psql -U cybersafe_admin -d cybersafe_la -c "\dt"

Write-Host "5. Seed row counts"
docker compose exec db psql -U cybersafe_admin -d cybersafe_la -c "SELECT 'business' AS table_name, COUNT(*) FROM business UNION ALL SELECT 'contact', COUNT(*) FROM contact UNION ALL SELECT 'engagement', COUNT(*) FROM engagement UNION ALL SELECT 'questionnaire_response', COUNT(*) FROM questionnaire_response UNION ALL SELECT 'knowledge_base_entry', COUNT(*) FROM knowledge_base_entry;"

Write-Host "6. Operational views"
docker compose exec db psql -U cybersafe_admin -d cybersafe_la -c "SELECT * FROM v_active_engagements_by_status;"
docker compose exec db psql -U cybersafe_admin -d cybersafe_la -c "SELECT * FROM v_referral_conversion_by_partner;"
docker compose exec db psql -U cybersafe_admin -d cybersafe_la -c "SELECT * FROM v_consultant_workload LIMIT 10;"
docker compose exec db psql -U cybersafe_admin -d cybersafe_la -c "SELECT * FROM v_questionnaire_risk_summary;"

Write-Host "7. Expected failure: cybersafe_read cannot insert"
docker compose exec db psql -U cybersafe_admin -d cybersafe_la -v ON_ERROR_STOP=0 -c "SET ROLE cybersafe_read; INSERT INTO business (name, naics, employee_count, ccpa_flag) VALUES ('Should Fail', '541213', 1, false);"

Write-Host "8. Expected success: cybersafe_app can insert an audit row"
docker compose exec db psql -U cybersafe_admin -d cybersafe_la -v ON_ERROR_STOP=1 -c "SET ROLE cybersafe_app; INSERT INTO audit_log_entry (actor_role, entity_name, action_type) VALUES ('cybersafe_app', 'audit_log_entry', 'PERMISSION_TEST');"

Write-Host "9. Expected failure: cybersafe_app cannot update audit rows"
docker compose exec db psql -U cybersafe_admin -d cybersafe_la -v ON_ERROR_STOP=0 -c "SET ROLE cybersafe_app; UPDATE audit_log_entry SET actor_role = 'bad_update' WHERE audit_log_id = 1;"

Write-Host "10. REST API JSON check"
curl.exe http://localhost:3000/business?limit=1
