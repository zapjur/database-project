-- Tabela zasobów serwerowych
CREATE TABLE server_resources (
    id SERIAL PRIMARY KEY,
    total_cpu INT NOT NULL,
    total_ram INT NOT NULL,
    total_disk INT NOT NULL,
    available_cpu INT NOT NULL,
    available_ram INT NOT NULL,
    available_disk INT NOT NULL
);

-- Tabela maszyn wirtualnych
CREATE TABLE virtual_machines (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    os VARCHAR(50),
    cpu INT NOT NULL,
    ram INT NOT NULL,
    disk INT NOT NULL,
    server_resource_id INT REFERENCES server_resources(id) ON DELETE CASCADE
);

-- Tabela SLA
CREATE TABLE sla (
    id SERIAL PRIMARY KEY,
    service_level VARCHAR(50) NOT NULL,
    uptime_guarantee DECIMAL(5, 2) NOT NULL,
    response_time INT NOT NULL
    );

-- Tabela historii wdrożeń
CREATE TABLE deployment_history (
    id SERIAL PRIMARY KEY,
    virtual_machine_id INT REFERENCES virtual_machines(id) ON DELETE CASCADE,
    deployment_date TIMESTAMP DEFAULT NOW(),
    version VARCHAR(50) NOT NULL,
    status VARCHAR(50) CHECK (status IN ('success', 'failure'))
);
