-- Widok do monitorowania zasobów maszyn wirtualnych
CREATE VIEW resource_usage AS
SELECT
    v.id AS vm_id,
    v.name AS vm_name,
    v.cpu,
    v.ram,
    v.disk,
    r.available_cpu,
    r.available_ram,
    r.available_disk
FROM
    virtual_machines v
        JOIN
    server_resources r
    ON
        v.server_resource_id = r.id;
