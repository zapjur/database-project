CREATE TABLE sla (
                     id SERIAL PRIMARY KEY,
                     service_level VARCHAR(50) NOT NULL,
                     uptime_guarantee DECIMAL(5, 2) NOT NULL,
                     response_time INT NOT NULL
);

CREATE TABLE users (
                       id SERIAL PRIMARY KEY,
                       username VARCHAR(50) UNIQUE NOT NULL,
                       email VARCHAR(100) UNIQUE NOT NULL,
                       password_hash TEXT NOT NULL,
                       created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE server_resources (
                                  id SERIAL PRIMARY KEY,
                                  total_cpu INT NOT NULL,
                                  total_ram INT NOT NULL,
                                  total_disk INT NOT NULL,
                                  available_cpu INT NOT NULL,
                                  available_ram INT NOT NULL,
                                  available_disk INT NOT NULL,
                                  sla_id INT REFERENCES sla(id)
);

CREATE TABLE virtual_machines (
                                  id SERIAL PRIMARY KEY,
                                  name VARCHAR(100) NOT NULL,
                                  os VARCHAR(50),
                                  cpu INT NOT NULL,
                                  ram INT NOT NULL,
                                  disk INT NOT NULL,
                                  server_resource_id INT REFERENCES server_resources(id) ON DELETE CASCADE,
                                  user_id INT REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE deployment_history (
                                    id SERIAL PRIMARY KEY,
                                    virtual_machine_id INT REFERENCES virtual_machines(id) ON DELETE CASCADE,
                                    deployment_date TIMESTAMP DEFAULT NOW(),
                                    version VARCHAR(50) NOT NULL,
                                    status VARCHAR(50) CHECK (status IN ('success', 'failure'))
);

CREATE TABLE user_roles (
                            id SERIAL PRIMARY KEY,
                            user_id INT REFERENCES users(id) ON DELETE CASCADE,
                            role VARCHAR(50) NOT NULL CHECK (role IN ('admin', 'client'))
);

CREATE TABLE logs (
                      id SERIAL PRIMARY KEY,
                      user_id INT REFERENCES users(id) ON DELETE SET NULL,
                      event_type VARCHAR(50) NOT NULL,
                      description TEXT NOT NULL,
                      event_timestamp TIMESTAMP DEFAULT NOW()
);

CREATE TABLE backup_history (
                                id SERIAL PRIMARY KEY,
                                virtual_machine_id INT REFERENCES virtual_machines(id) ON DELETE CASCADE,
                                backup_date TIMESTAMP DEFAULT NOW(),
                                status VARCHAR(50) CHECK (status IN ('completed', 'failed'))
);

CREATE TABLE notifications (
                               id SERIAL PRIMARY KEY,
                               user_id INT REFERENCES users(id) ON DELETE CASCADE,
                               message TEXT NOT NULL,
                               read_status BOOLEAN DEFAULT FALSE,
                               created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE vm_configurations (
                                   id SERIAL PRIMARY KEY,
                                   virtual_machine_id INT REFERENCES virtual_machines(id) ON DELETE CASCADE,
                                   config_key VARCHAR(100) NOT NULL,
                                   config_value TEXT NOT NULL
);

CREATE TABLE billing (
                         id SERIAL PRIMARY KEY,
                         user_id INT REFERENCES users(id) ON DELETE CASCADE,
                         amount DECIMAL(10, 2) NOT NULL,
                         billing_date TIMESTAMP DEFAULT NOW(),
                         status VARCHAR(50) CHECK (status IN ('pending', 'paid', 'failed'))
);

CREATE TABLE network_settings (
                                  id SERIAL PRIMARY KEY,
                                  virtual_machine_id INT REFERENCES virtual_machines(id) ON DELETE CASCADE,
                                  ip_address VARCHAR(15) NOT NULL UNIQUE,
                                  subnet VARCHAR(50) NOT NULL,
                                  gateway VARCHAR(50) NOT NULL
);

CREATE TABLE api_keys (
                          id SERIAL PRIMARY KEY,
                          user_id INT REFERENCES users(id) ON DELETE CASCADE,
                          api_key TEXT NOT NULL UNIQUE,
                          created_at TIMESTAMP DEFAULT NOW(),
                          expires_at TIMESTAMP NOT NULL
);
