-- Tabela SLA
CREATE TABLE sla (
    id SERIAL PRIMARY KEY,
    service_level VARCHAR(50) NOT NULL, -- Poziom SLA (np. Gold, Silver, Bronze)
    uptime_guarantee DECIMAL(5, 2) NOT NULL, -- Gwarantowany czas działania (np. 99.99%)
    response_time INT NOT NULL -- Gwarantowany czas reakcji (w minutach)
);

-- Tabela zasobów serwerowych
CREATE TABLE server_resources (
    id SERIAL PRIMARY KEY,
    total_cpu INT NOT NULL, -- Całkowita liczba rdzeni CPU
    total_ram INT NOT NULL, -- Całkowita ilość RAM (w GB)
    total_disk INT NOT NULL, -- Całkowita pojemność dysku (w GB)
    available_cpu INT NOT NULL, -- Dostępna liczba rdzeni CPU
    available_ram INT NOT NULL, -- Dostępna ilość RAM (w GB)
    available_disk INT NOT NULL, -- Dostępna pojemność dysku (w GB)
    sla_id INT REFERENCES sla(id) -- Poziom SLA przypisany do serwera
);

-- Tabela maszyn wirtualnych
CREATE TABLE virtual_machines (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL, -- Nazwa maszyny wirtualnej
    os VARCHAR(50), -- System operacyjny
    cpu INT NOT NULL, -- Liczba przydzielonych rdzeni CPU
    ram INT NOT NULL, -- Przydzielona ilość RAM (w GB)
    disk INT NOT NULL, -- Przydzielona pojemność dysku (w GB)
    server_resource_id INT REFERENCES server_resources(id) ON DELETE CASCADE -- Serwer, na którym działa maszyna wirtualna
);

-- Tabela historii wdrożeń
CREATE TABLE deployment_history (
    id SERIAL PRIMARY KEY,
    virtual_machine_id INT REFERENCES virtual_machines(id) ON DELETE CASCADE, -- Maszyna wirtualna, dla której rejestrowane jest wdrożenie
    deployment_date TIMESTAMP DEFAULT NOW(), -- Data i czas wdrożenia
    version VARCHAR(50) NOT NULL, -- Wersja oprogramowania
    status VARCHAR(50) CHECK (status IN ('success', 'failure')) -- Status wdrożenia (np. success lub failure)
);
