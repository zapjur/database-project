---
layout: default
title: Views
nav_order: 4
---

# Widoki

## Widok: `available_server_resources`

### Opis
Widok `available_server_resources` umożliwia monitorowanie dostępnych zasobów serwerów oraz przypisanych do nich poziomów SLA.

### Sygnatura
```sql
CREATE VIEW available_server_resources AS
SELECT sr.id AS server_id, sr.total_cpu, sr.available_cpu, sr.total_ram, sr.available_ram, sr.total_disk, sr.available_disk, s.service_level
FROM server_resources sr
JOIN sla s ON sr.sla_id = s.id;
```

### Wynik

| Kolumna         | Typ danych | Opis                                  |
|----------------|-----------|--------------------------------------|
| `server_id`    | INT       | Unikalny identyfikator serwera.     |
| `total_cpu`    | INT       | Całkowita liczba rdzeni procesora.  |
| `available_cpu`| INT       | Liczba dostępnych rdzeni procesora. |
| `total_ram`    | INT       | Całkowita ilość pamięci RAM w GB.   |
| `available_ram`| INT       | Dostępna ilość pamięci RAM w GB.    |
| `total_disk`   | INT       | Całkowita pojemność dysku w GB.     |
| `available_disk`| INT      | Dostępna pojemność dysku w GB.      |
| `service_level`| VARCHAR   | Poziom SLA przypisany do serwera.   |

### Przykład użycia

```sql
SELECT * FROM available_server_resources;
```

---

## Widok: `virtual_machines_with_users`

### Opis
Widok `virtual_machines_with_users` zwraca listę maszyn wirtualnych wraz z informacjami o użytkownikach, którzy nimi zarządzają.

### Sygnatura
```sql
CREATE VIEW virtual_machines_with_users AS
SELECT vm.id AS vm_id, vm.name, vm.os, vm.cpu, vm.ram, vm.disk, u.username, u.email
FROM virtual_machines vm
LEFT JOIN users u ON vm.user_id = u.id;
```

### Wynik

| Kolumna  | Typ danych | Opis                                |
|----------|-----------|------------------------------------|
| `vm_id`  | INT       | Identyfikator maszyny wirtualnej. |
| `name`   | VARCHAR   | Nazwa maszyny.                    |
| `os`     | VARCHAR   | System operacyjny maszyny.        |
| `cpu`    | INT       | Liczba przydzielonych rdzeni CPU. |
| `ram`    | INT       | Przydzielona ilość RAM (w GB).    |
| `disk`   | INT       | Przydzielona pojemność dysku (w GB). |
| `username`| VARCHAR  | Nazwa użytkownika zarządzającego maszyną. |
| `email`  | VARCHAR   | Email użytkownika.                |

### Przykład użycia

```sql
SELECT * FROM virtual_machines_with_users;
```

---

## Widok: `deployment_history_details`

### Opis
Widok `deployment_history_details` zwraca szczegółowe informacje o historii wdrożeń dla maszyn wirtualnych.

### Sygnatura
```sql
CREATE VIEW deployment_history_details AS
SELECT dh.id AS deployment_id, vm.name AS vm_name, dh.deployment_date, dh.version, dh.status
FROM deployment_history dh
JOIN virtual_machines vm ON dh.virtual_machine_id = vm.id;
```

### Wynik

| Kolumna          | Typ danych   | Opis                                  |
|-----------------|-------------|--------------------------------------|
| `deployment_id` | INT         | Identyfikator wdrożenia.             |
| `vm_name`       | VARCHAR     | Nazwa maszyny wirtualnej.            |
| `deployment_date` | TIMESTAMP  | Data wdrożenia.                      |
| `version`        | VARCHAR     | Wersja wdrożenia.                     |
| `status`         | VARCHAR     | Status wdrożenia (np. success, failure). |

### Przykład użycia

```sql
SELECT * FROM deployment_history_details;
```

---

## Widok: `unread_notifications`

### Opis
Widok `unread_notifications` zwraca listę nieprzeczytanych powiadomień użytkowników.

### Sygnatura
```sql
CREATE VIEW unread_notifications AS
SELECT n.id AS notification_id, u.username, n.message, n.created_at
FROM notifications n
JOIN users u ON n.user_id = u.id
WHERE n.read_status = FALSE;
```

### Wynik

| Kolumna         | Typ danych  | Opis                                  |
|----------------|------------|--------------------------------------|
| `notification_id` | INT      | Identyfikator powiadomienia.         |
| `username`    | VARCHAR     | Nazwa użytkownika.                   |
| `message`     | TEXT        | Treść powiadomienia.                 |
| `created_at`  | TIMESTAMP   | Data wysłania powiadomienia.         |

### Przykład użycia

```sql
SELECT * FROM unread_notifications;
```

---

## Widok: `active_api_keys`

### Opis
Widok `active_api_keys` zwraca listę aktywnych kluczy API przypisanych do użytkowników.

### Sygnatura
```sql
CREATE VIEW active_api_keys AS
SELECT ak.id AS api_key_id, u.username, ak.api_key, ak.created_at, ak.expires_at
FROM api_keys ak
JOIN users u ON ak.user_id = u.id
WHERE ak.expires_at > NOW();
```

### Wynik

| Kolumna      | Typ danych  | Opis                                |
|-------------|------------|------------------------------------|
| `api_key_id` | INT        | Identyfikator klucza API.         |
| `username`   | VARCHAR    | Nazwa użytkownika.                |
| `api_key`    | TEXT       | Wartość klucza API.               |
| `created_at` | TIMESTAMP  | Data utworzenia klucza.           |
| `expires_at` | TIMESTAMP  | Data wygaśnięcia klucza API.      |

### Przykład użycia

```sql
SELECT * FROM active_api_keys;
```

---

## Widok: `user_billing_history`

### Opis
Widok `user_billing_history` zwraca historię rozliczeń użytkowników.

### Sygnatura
```sql
CREATE VIEW user_billing_history AS
SELECT b.id AS billing_id, u.username, b.amount, b.billing_date, b.status
FROM billing b
JOIN users u ON b.user_id = u.id;
```

### Wynik

| Kolumna       | Typ danych  | Opis                                |
|--------------|------------|------------------------------------|
| `billing_id` | INT        | Identyfikator rozliczenia.        |
| `username`   | VARCHAR    | Nazwa użytkownika.                |
| `amount`     | DECIMAL    | Kwota rozliczenia.                |
| `billing_date` | TIMESTAMP | Data wystawienia rachunku.        |
| `status`     | VARCHAR    | Status rozliczenia (pending, paid, failed). |

### Przykład użycia

```sql
SELECT * FROM user_billing_history;
```

---

## Widok: `vm_configuration_details`

### Opis
Widok `vm_configuration_details` zwraca szczegółowe informacje o konfiguracji maszyn wirtualnych.

### Sygnatura
```sql
CREATE VIEW vm_configuration_details AS
SELECT vc.id AS config_id, vm.name AS vm_name, vc.config_key, vc.config_value
FROM vm_configurations vc
JOIN virtual_machines vm ON vc.virtual_machine_id = vm.id;
```

### Wynik

| Kolumna      | Typ danych | Opis                                      |
|-------------|-----------|------------------------------------------|
| `config_id` | INT       | Identyfikator konfiguracji.               |
| `vm_name`   | VARCHAR   | Nazwa maszyny wirtualnej.                 |
| `config_key`| VARCHAR   | Klucz konfiguracji (np. firewall_enabled).|
| `config_value`| TEXT     | Wartość konfiguracji.                     |

### Przykład użycia

```sql
SELECT * FROM vm_configuration_details;
```

---

## Widok: `backup_status`

### Opis
Widok `backup_status` zwraca szczegółowe informacje o statusie kopii zapasowych maszyn wirtualnych.

### Sygnatura
```sql
CREATE VIEW backup_status AS
SELECT bh.id AS backup_id, vm.name AS vm_name, bh.backup_date, bh.status
FROM backup_history bh
JOIN virtual_machines vm ON bh.virtual_machine_id = vm.id;
```

### Wynik

| Kolumna      | Typ danych | Opis                                  |
|-------------|-----------|--------------------------------------|
| `backup_id` | INT       | Identyfikator kopii zapasowej.       |
| `vm_name`   | VARCHAR   | Nazwa maszyny wirtualnej.            |
| `backup_date` | TIMESTAMP | Data wykonania kopii.               |
| `status`    | VARCHAR   | Status kopii (completed, failed).    |

### Przykład użycia

```sql
SELECT * FROM backup_status;
```

---

## Widok: `user_logs`

### Opis
Widok `user_logs` zwraca historię logów systemowych użytkowników.

### Sygnatura
```sql
CREATE VIEW user_logs AS
SELECT l.id AS log_id, u.username, l.event_type, l.description, l.event_timestamp
FROM logs l
LEFT JOIN users u ON l.user_id = u.id;
```

### Wynik

| Kolumna         | Typ danych  | Opis                                   |
|----------------|------------|---------------------------------------|
| `log_id`       | INT        | Identyfikator logu.                   |
| `username`     | VARCHAR    | Nazwa użytkownika (może być NULL).    |
| `event_type`   | VARCHAR    | Typ zdarzenia (np. login, update).    |
| `description`  | TEXT       | Opis zdarzenia.                       |
| `event_timestamp` | TIMESTAMP | Czas wystąpienia zdarzenia.           |

### Przykład użycia

```sql
SELECT * FROM user_logs;
```

---
