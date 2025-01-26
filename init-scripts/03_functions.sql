-- Funkcja do analizy SLA
CREATE OR REPLACE FUNCTION check_sla_threshold(threshold DECIMAL)
RETURNS TABLE (sla_id INT, service_level VARCHAR, uptime_guarantee DECIMAL) AS $$
BEGIN
RETURN QUERY
SELECT s.id, s.service_level, s.uptime_guarantee
FROM sla s
WHERE s.uptime_guarantee < threshold;
END;
$$ LANGUAGE plpgsql;

