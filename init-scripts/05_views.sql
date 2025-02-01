-- Widok dla monitorowania dostępnych zasobów serwerów
CREATE VIEW available_server_resources AS
SELECT sr.id AS server_id, sr.total_cpu, sr.available_cpu, sr.total_ram, sr.available_ram, sr.total_disk, sr.available_disk, s.service_level
FROM server_resources sr
         JOIN sla s ON sr.sla_id = s.id;

-- Widok dla listy maszyn wirtualnych i ich użytkowników
CREATE VIEW virtual_machines_with_users AS
SELECT vm.id AS vm_id, vm.name, vm.os, vm.cpu, vm.ram, vm.disk, u.username, u.email
FROM virtual_machines vm
         LEFT JOIN users u ON vm.user_id = u.id;

-- Widok dla historii wdrożeń maszyn wirtualnych
CREATE VIEW deployment_history_details AS
SELECT dh.id AS deployment_id, vm.name AS vm_name, dh.deployment_date, dh.version, dh.status
FROM deployment_history dh
         JOIN virtual_machines vm ON dh.virtual_machine_id = vm.id;

-- Widok dla nieprzeczytanych powiadomień użytkowników
CREATE VIEW unread_notifications AS
SELECT n.id AS notification_id, u.username, n.message, n.created_at
FROM notifications n
         JOIN users u ON n.user_id = u.id
WHERE n.read_status = FALSE;

-- Widok dla aktywnych kluczy API użytkowników
CREATE VIEW active_api_keys AS
SELECT ak.id AS api_key_id, u.username, ak.api_key, ak.created_at, ak.expires_at
FROM api_keys ak
         JOIN users u ON ak.user_id = u.id
WHERE ak.expires_at > NOW();

-- Widok dla historii rozliczeń użytkowników
CREATE VIEW user_billing_history AS
SELECT b.id AS billing_id, u.username, b.amount, b.billing_date, b.status
FROM billing b
         JOIN users u ON b.user_id = u.id;

-- Widok dla konfiguracji maszyn wirtualnych
CREATE VIEW vm_configuration_details AS
SELECT vc.id AS config_id, vm.name AS vm_name, vc.config_key, vc.config_value
FROM vm_configurations vc
         JOIN virtual_machines vm ON vc.virtual_machine_id = vm.id;

-- Widok dla kopii zapasowych maszyn wirtualnych
CREATE VIEW backup_status AS
SELECT bh.id AS backup_id, vm.name AS vm_name, bh.backup_date, bh.status
FROM backup_history bh
         JOIN virtual_machines vm ON bh.virtual_machine_id = vm.id;

-- Widok dla logów systemowych użytkowników
CREATE VIEW user_logs AS
SELECT l.id AS log_id, u.username, l.event_type, l.description, l.event_timestamp
FROM logs l
         LEFT JOIN users u ON l.user_id = u.id;
