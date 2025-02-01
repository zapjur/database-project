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

-- Funkcja do pobierania dostępnych zasobów serwera na podstawie ID
CREATE OR REPLACE FUNCTION get_available_resources(server_id INT)
RETURNS TABLE (available_cpu INT, available_ram INT, available_disk INT) AS $$
BEGIN
RETURN QUERY
SELECT sr.available_cpu, sr.available_ram, sr.available_disk
FROM server_resources sr
WHERE sr.id = server_id;
END;
$$ LANGUAGE plpgsql;

-- Funkcja do zwracania listy maszyn wirtualnych przypisanych do użytkownika
CREATE OR REPLACE FUNCTION get_user_vms(user_id_param INT)
RETURNS TABLE (vm_id INT, name VARCHAR, os VARCHAR, cpu INT, ram INT, disk INT) AS $$
BEGIN
RETURN QUERY
SELECT v.id, v.name, v.os, v.cpu, v.ram, v.disk
FROM virtual_machines v
WHERE v.user_id = user_id_param;
END;
$$ LANGUAGE plpgsql;

-- Funkcja do zwracania liczby maszyn wirtualnych przypisanych do użytkownika
CREATE OR REPLACE FUNCTION count_user_vms(user_id_param INT)
RETURNS INT AS $$
DECLARE
vm_count INT;
BEGIN
SELECT COUNT(*) INTO vm_count
FROM virtual_machines v
WHERE v.user_id = user_id_param;

RETURN vm_count;
END;
$$ LANGUAGE plpgsql;

-- Funkcja do pobierania historii wdrożeń dla danej maszyny wirtualnej
CREATE OR REPLACE FUNCTION get_vm_deployment_history(vm_id INT)
RETURNS TABLE (deployment_date TIMESTAMP, version VARCHAR, status VARCHAR) AS $$
BEGIN
RETURN QUERY
SELECT dh.deployment_date, dh.version, dh.status
FROM deployment_history dh
WHERE dh.virtual_machine_id = vm_id;
END;
$$ LANGUAGE plpgsql;

-- Funkcja do sprawdzania statusu ostatniego wdrożenia danej maszyny
CREATE OR REPLACE FUNCTION get_latest_vm_deployment(vm_id INT)
RETURNS TABLE (deployment_date TIMESTAMP, version VARCHAR, status VARCHAR) AS $$
BEGIN
RETURN QUERY
SELECT dh.deployment_date, dh.version, dh.status
FROM deployment_history dh
WHERE dh.virtual_machine_id = vm_id
ORDER BY dh.deployment_date DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- Funkcja do pobrania wszystkich aktywnych kluczy API użytkownika
CREATE OR REPLACE FUNCTION get_user_api_keys(user_id_param INT)
RETURNS TABLE (api_key TEXT, created_at TIMESTAMP, expires_at TIMESTAMP) AS $$
BEGIN
RETURN QUERY
SELECT ak.api_key, ak.created_at, ak.expires_at
FROM api_keys ak
WHERE ak.user_id = user_id_param AND ak.expires_at > NOW();
END;
$$ LANGUAGE plpgsql;

-- Funkcja do sprawdzania, czy użytkownik posiada aktywną subskrypcję
CREATE OR REPLACE FUNCTION check_user_billing_status(user_id_param INT)
RETURNS VARCHAR AS $$
DECLARE
billing_status VARCHAR;
BEGIN
SELECT status INTO billing_status
FROM billing b
WHERE b.user_id = user_id_param
ORDER BY b.billing_date DESC
    LIMIT 1;

RETURN COALESCE(billing_status, 'no_records');
END;
$$ LANGUAGE plpgsql;

-- Funkcja do sprawdzania liczby powiadomień nieprzeczytanych przez użytkownika
CREATE OR REPLACE FUNCTION count_unread_notifications(user_id_param INT)
RETURNS INT AS $$
DECLARE
unread_count INT;
BEGIN
SELECT COUNT(*) INTO unread_count
FROM notifications n
WHERE n.user_id = user_id_param AND n.read_status = FALSE;

RETURN unread_count;
END;
$$ LANGUAGE plpgsql;

