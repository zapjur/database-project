INSERT INTO sla (service_level, uptime_guarantee, response_time)
VALUES ('Gold', 99.99, 10),
       ('Silver', 99.5, 30),
       ('Bronze', 98, 60);

INSERT INTO users (username, email, password_hash, created_at)
VALUES ('admin', 'admin@example.com', 'hashed_admin_password', NOW()),
       ('user1', 'user1@example.com', 'hashed_user1_password', NOW()),
       ('user2', 'user2@example.com', 'hashed_user2_password', NOW());

INSERT INTO user_roles (user_id, role)
VALUES (1, 'admin'),
       (2, 'client'),
       (3, 'client');

INSERT INTO server_resources (total_cpu, total_ram, total_disk, available_cpu, available_ram, available_disk, sla_id)
VALUES (64, 256, 2048, 32, 128, 1024, 1),
       (128, 512, 4096, 64, 256, 2048, 2);

INSERT INTO virtual_machines (name, os, cpu, ram, disk, server_resource_id, user_id)
VALUES ('VM1', 'Ubuntu 22.04', 4, 16, 100, 1, 2),
       ('VM2', 'Windows Server 2019', 8, 32, 200, 2, 3);

INSERT INTO deployment_history (virtual_machine_id, deployment_date, version, status)
VALUES (1, NOW(), 'v1.0', 'success'),
       (2, NOW(), 'v2.0', 'failure');

INSERT INTO logs (user_id, event_type, description, event_timestamp)
VALUES (1, 'login', 'Admin logged in', NOW()),
       (2, 'vm_create', 'User1 created a VM', NOW()),
       (3, 'vm_delete', 'User2 deleted a VM', NOW());

INSERT INTO backup_history (virtual_machine_id, backup_date, status)
VALUES (1, NOW(), 'completed'),
       (2, NOW(), 'failed');

INSERT INTO notifications (user_id, message, read_status, created_at)
VALUES (1, 'System maintenance scheduled', FALSE, NOW()),
       (2, 'Your VM has been updated', FALSE, NOW()),
       (3, 'Backup process completed', TRUE, NOW());

INSERT INTO vm_configurations (virtual_machine_id, config_key, config_value)
VALUES (1, 'firewall_enabled', 'true'),
       (1, 'auto_backup', 'true'),
       (2, 'max_connections', '50');

INSERT INTO billing (user_id, amount, billing_date, status)
VALUES (2, 49.99, NOW(), 'paid'),
       (3, 19.99, NOW(), 'pending');

INSERT INTO network_settings (virtual_machine_id, ip_address, subnet, gateway)
VALUES (1, '192.168.1.10', '255.255.255.0', '192.168.1.1'),
       (2, '192.168.1.20', '255.255.255.0', '192.168.1.1');

INSERT INTO api_keys (user_id, api_key, created_at, expires_at)
VALUES (1, 'api_key_abc123', NOW(), NOW() + INTERVAL '30 days'),
       (2, 'api_key_def456', NOW(), NOW() + INTERVAL '30 days');
