CREATE OR REPLACE FUNCTION update_server_resources_after_insert()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.cpu > (SELECT available_cpu FROM server_resources WHERE id = NEW.server_resource_id) OR
       NEW.ram > (SELECT available_ram FROM server_resources WHERE id = NEW.server_resource_id) OR
       NEW.disk > (SELECT available_disk FROM server_resources WHERE id = NEW.server_resource_id) THEN
        RAISE EXCEPTION 'Niewystarczające zasoby na serwerze o ID: %', NEW.server_resource_id;
    END IF;

    UPDATE server_resources
    SET
        available_cpu = available_cpu - NEW.cpu,
        available_ram = available_ram - NEW.ram,
        available_disk = available_disk - NEW.disk
    WHERE id = NEW.server_resource_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER after_vm_insert
AFTER INSERT ON virtual_machines
FOR EACH ROW
EXECUTE FUNCTION update_server_resources_after_insert();

CREATE OR REPLACE FUNCTION restore_server_resources_after_delete()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE server_resources
    SET
        available_cpu = available_cpu + OLD.cpu,
        available_ram = available_ram + OLD.ram,
        available_disk = available_disk + OLD.disk
    WHERE id = OLD.server_resource_id;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER after_vm_delete
AFTER DELETE ON virtual_machines
FOR EACH ROW
EXECUTE FUNCTION restore_server_resources_after_delete();

CREATE OR REPLACE FUNCTION update_server_resources_after_update()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE server_resources
    SET
        available_cpu = available_cpu + OLD.cpu,
        available_ram = available_ram + OLD.ram,
        available_disk = available_disk + OLD.disk
    WHERE id = OLD.server_resource_id;

    IF NEW.cpu > (SELECT available_cpu FROM server_resources WHERE id = NEW.server_resource_id) OR
       NEW.ram > (SELECT available_ram FROM server_resources WHERE id = NEW.server_resource_id) OR
       NEW.disk > (SELECT available_disk FROM server_resources WHERE id = NEW.server_resource_id) THEN
        RAISE EXCEPTION 'Niewystarczające zasoby na serwerze o ID: %', NEW.server_resource_id;
    END IF;

    UPDATE server_resources
    SET
        available_cpu = available_cpu - NEW.cpu,
        available_ram = available_ram - NEW.ram,
        available_disk = available_disk - NEW.disk
    WHERE id = NEW.server_resource_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER after_vm_update
AFTER UPDATE ON virtual_machines
FOR EACH ROW
EXECUTE FUNCTION update_server_resources_after_update();

CREATE OR REPLACE FUNCTION log_vm_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO logs (user_id, event_type, description)
        VALUES (NEW.user_id, 'VM_CREATED', 'Virtual machine ' || NEW.name || ' created.');
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO logs (user_id, event_type, description)
        VALUES (NEW.user_id, 'VM_UPDATED', 'Virtual machine ' || NEW.name || ' updated.');
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO logs (user_id, event_type, description)
        VALUES (OLD.user_id, 'VM_DELETED', 'Virtual machine ' || OLD.name || ' deleted.');
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER log_vm_changes_trigger
AFTER INSERT OR UPDATE OR DELETE ON virtual_machines
FOR EACH ROW
EXECUTE FUNCTION log_vm_changes();

CREATE OR REPLACE FUNCTION notify_new_billing()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO notifications (user_id, message)
    VALUES (NEW.user_id, 'New billing created with amount: ' || NEW.amount || ' and status: ' || NEW.status);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER after_billing_insert
AFTER INSERT ON billing
FOR EACH ROW
EXECUTE FUNCTION notify_new_billing();

CREATE OR REPLACE FUNCTION notify_billing_status_change()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status <> NEW.status THEN
        INSERT INTO notifications (user_id, message)
        VALUES (NEW.user_id, 'Billing status changed from ' || OLD.status || ' to ' || NEW.status);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER after_billing_status_update
AFTER UPDATE ON billing
FOR EACH ROW
EXECUTE FUNCTION notify_billing_status_change();