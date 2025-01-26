-- Wprowadzenie danych testowych
INSERT INTO server_resources (total_cpu, total_ram, total_disk, available_cpu, available_ram, available_disk)
VALUES (64, 256, 2048, 32, 128, 1024);

INSERT INTO virtual_machines (name, os, cpu, ram, disk, server_resource_id)
VALUES ('VM1', 'Ubuntu 22.04', 4, 16, 100, 1);

INSERT INTO sla (service_level, uptime_guarantee, response_time)
VALUES ('Gold', 99.99, 10), ('Silver', 99.5, 30), ('Bronze', 98, 60);

INSERT INTO deployment_history (virtual_machine_id, deployment_date, version, status)
VALUES (1, NOW(), 'v1.0', 'success');
