-- Wyzwalacz do aktualizacji dostępnych zasobów
CREATE OR REPLACE FUNCTION update_server_resources()
RETURNS TRIGGER AS $$
BEGIN
    -- Sprawdzenie dostępnych zasobów
    IF NEW.cpu > (SELECT available_cpu FROM server_resources WHERE id = NEW.server_resource_id) OR
       NEW.ram > (SELECT available_ram FROM server_resources WHERE id = NEW.server_resource_id) OR
       NEW.disk > (SELECT available_disk FROM server_resources WHERE id = NEW.server_resource_id) THEN
        RAISE EXCEPTION 'Niewystarczające zasoby na serwerze o ID: %', NEW.server_resource_id;
END IF;

    -- Aktualizacja dostępnych zasobów
UPDATE server_resources
SET
    available_cpu = available_cpu - NEW.cpu,
    available_ram = available_ram - NEW.ram,
    available_disk = available_disk - NEW.disk
WHERE id = NEW.server_resource_id;

RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Wyzwalacz aktualizujący zasoby po dodaniu maszyny wirtualnej
CREATE OR REPLACE TRIGGER after_vm_insert
AFTER INSERT ON virtual_machines
FOR EACH ROW
EXECUTE FUNCTION update_server_resources();

