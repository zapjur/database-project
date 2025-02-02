---
layout: default
title: Functions
nav_order: 2
---

# Funkcje

## Funkcja: `check_sla_threshold`

### Opis
Funkcja `check_sla_threshold` zwraca poziomy SLA, których `uptime_guarantee` jest niższy niż podany próg **oraz są przypisane do serwerów z dostępnymi zasobami powyżej średniej**.

### Sygnatura
```sql
CREATE OR REPLACE FUNCTION check_sla_threshold(threshold DECIMAL)
RETURNS TABLE (sla_id INT, service_level VARCHAR, uptime_guarantee DECIMAL) AS $$
BEGIN
RETURN QUERY
SELECT s.id, s.service_level, s.uptime_guarantee
FROM sla s
WHERE s.uptime_guarantee < threshold
  AND s.id IN (
      SELECT sr.sla_id
      FROM server_resources sr
      WHERE sr.available_cpu > (SELECT AVG(available_cpu) FROM server_resources)
        AND sr.available_ram > (SELECT AVG(available_ram) FROM server_resources)
  );
END;
$$ LANGUAGE plpgsql;
```

### Parametry wejściowe
- `threshold` (DECIMAL) - Próg gwarantowanego czasu działania w procentach, poniżej którego funkcja zwraca poziomy SLA.

### Wynik

| Kolumna          | Typ danych   | Opis                                  |
|-----------------|-------------|--------------------------------------|
| `sla_id`        | INT         | Unikalny identyfikator poziomu SLA.  |
| `service_level` | VARCHAR     | Nazwa poziomu SLA.                   |
| `uptime_guarantee` | DECIMAL | Gwarantowany czas działania w procentach. |

### Przykład użycia

```sql
SELECT * FROM check_sla_threshold(99.95);
```

### Wynik

| sla_id | service_level | uptime_guarantee |
|--------|---------------|------------------|
| 2      | Silver        | 99.90            |
| 3      | Bronze        | 99.00            |

---

## Funkcja: `get_available_resources`

### Opis
Funkcja `get_available_resources` pobiera dostępne zasoby (CPU, RAM, dysk) dla wskazanego serwera.

### Sygnatura
```sql
CREATE OR REPLACE FUNCTION get_available_resources(server_id INT)
RETURNS TABLE (available_cpu INT, available_ram INT, available_disk INT) AS $$
BEGIN
RETURN QUERY
SELECT sr.available_cpu, sr.available_ram, sr.available_disk
FROM server_resources sr
WHERE sr.id = server_id;
END;
$$ LANGUAGE plpgsql;
```

### Parametry wejściowe
- `server_id` (INT) - Identyfikator serwera, dla którego pobierane są dostępne zasoby.

### Wynik

| Kolumna          | Typ danych   | Opis                                  |
|-----------------|-------------|--------------------------------------|
| `available_cpu` | INT         | Dostępna liczba rdzeni CPU.          |
| `available_ram` | INT         | Dostępna ilość RAM (w GB).           |
| `available_disk` | INT        | Dostępna pojemność dysku (w GB).     |

### Przykład użycia

```sql
SELECT * FROM get_available_resources(1);
```

### Wynik

| available_cpu | available_ram | available_disk |
|--------------|--------------|---------------|
| 32           | 128          | 1024         |

---

## Funkcja: `get_user_vms`

### Opis
Funkcja `get_user_vms` zwraca listę maszyn wirtualnych przypisanych do konkretnego użytkownika.

### Sygnatura
```sql
CREATE OR REPLACE FUNCTION get_user_vms(user_id_param INT)
RETURNS TABLE (vm_id INT, name VARCHAR, os VARCHAR, cpu INT, ram INT, disk INT) AS $$
BEGIN
RETURN QUERY
SELECT v.id, v.name, v.os, v.cpu, v.ram, v.disk
FROM virtual_machines v
WHERE v.user_id = user_id_param;
END;
$$ LANGUAGE plpgsql;
```

### Parametry wejściowe
- `user_id_param` (INT) - Identyfikator użytkownika.

### Wynik

| Kolumna  | Typ danych | Opis                                |
|----------|-----------|------------------------------------|
| `vm_id`  | INT       | Identyfikator maszyny wirtualnej. |
| `name`   | VARCHAR   | Nazwa maszyny.                    |
| `os`     | VARCHAR   | System operacyjny maszyny.        |
| `cpu`    | INT       | Liczba przydzielonych rdzeni CPU. |
| `ram`    | INT       | Przydzielona ilość RAM (w GB).    |
| `disk`   | INT       | Przydzielona pojemność dysku (w GB). |

### Przykład użycia

```sql
SELECT * FROM get_user_vms(2);
```

### Wynik

| vm_id | name | os              | cpu | ram | disk |
|-------|------|----------------|-----|-----|------|
| 1     | VM1  | Ubuntu 22.04   | 4   | 16  | 100  |
| 2     | VM2  | Windows Server | 8   | 32  | 200  |

---

## Funkcja: `count_user_vms`

### Opis
Funkcja `count_user_vms` zwraca liczbę maszyn wirtualnych przypisanych do użytkownika.

### Sygnatura
```sql
CREATE OR REPLACE FUNCTION count_user_vms(user_id_param INT)
RETURNS INT AS $$
DECLARE
vm_count INT;
BEGIN
SELECT COUNT(*) INTO vm_count
FROM virtual_machines v
WHERE v.user_id = user_id_param;

RETURN vm_count;
END;
$$ LANGUAGE plpgsql;
```

### Parametry wejściowe
- `user_id_param` (INT) - Identyfikator użytkownika.

### Wynik
Liczba maszyn wirtualnych przypisanych do użytkownika.

### Przykład użycia

```sql
SELECT count_user_vms(2);
```

### Wynik

| count_user_vms |
|---------------|
| 2             |

---

## Funkcja: `get_vm_deployment_history`

### Opis
Funkcja `get_vm_deployment_history` zwraca historię wdrożeń dla danej maszyny wirtualnej.

### Sygnatura
```sql
CREATE OR REPLACE FUNCTION get_vm_deployment_history(vm_id INT)
RETURNS TABLE (deployment_date TIMESTAMP, version VARCHAR, status VARCHAR) AS $$
BEGIN
RETURN QUERY
SELECT dh.deployment_date, dh.version, dh.status
FROM deployment_history dh
WHERE dh.virtual_machine_id = vm_id;
END;
$$ LANGUAGE plpgsql;
```

### Parametry wejściowe
- `vm_id` (INT) - Identyfikator maszyny wirtualnej.

### Wynik

| Kolumna          | Typ danych   | Opis                                  |
|-----------------|-------------|--------------------------------------|
| `deployment_date` | TIMESTAMP  | Data wdrożenia.                      |
| `version`        | VARCHAR     | Wersja wdrożenia.                     |
| `status`         | VARCHAR     | Status wdrożenia (np. success, failure). |

### Przykład użycia

```sql
SELECT * FROM get_vm_deployment_history(1);
```

### Wynik

| deployment_date       | version | status  |
|----------------------|---------|--------|
| 2025-02-01 12:00:00 | v1.0    | success |
| 2025-02-02 14:30:00 | v1.1    | success |

---

## Funkcja: `get_latest_vm_deployment`

### Opis
Funkcja `get_latest_vm_deployment` sprawdza status ostatniego wdrożenia dla danej maszyny wirtualnej.

### Sygnatura
```sql
CREATE OR REPLACE FUNCTION get_latest_vm_deployment(vm_id INT)
RETURNS TABLE (deployment_date TIMESTAMP, version VARCHAR, status VARCHAR) AS $$
BEGIN
RETURN QUERY
SELECT dh.deployment_date, dh.version, dh.status
FROM deployment_history dh
WHERE dh.virtual_machine_id = vm_id
ORDER BY dh.deployment_date DESC
LIMIT 1;
END;
$$ LANGUAGE plpgsql;
```

### Parametry wejściowe
- `vm_id` (INT) - Identyfikator maszyny wirtualnej.

### Wynik

| Kolumna          | Typ danych   | Opis                                  |
|-----------------|-------------|--------------------------------------|
| `deployment_date` | TIMESTAMP  | Data wdrożenia.                      |
| `version`        | VARCHAR     | Wersja wdrożenia.                     |
| `status`         | VARCHAR     | Status wdrożenia (np. success, failure). |

### Przykład użycia

```sql
SELECT * FROM get_latest_vm_deployment(1);
```

### Wynik

| deployment_date       | version | status  |
|----------------------|---------|--------|
| 2025-02-02 14:30:00 | v1.1    | success |

---

## Funkcja: `get_user_api_keys`

### Opis
Funkcja `get_user_api_keys` pobiera wszystkie aktywne klucze API przypisane do użytkownika.

### Sygnatura
```sql
CREATE OR REPLACE FUNCTION get_user_api_keys(user_id_param INT)
RETURNS TABLE (api_key TEXT, created_at TIMESTAMP, expires_at TIMESTAMP) AS $$
BEGIN
RETURN QUERY
SELECT ak.api_key, ak.created_at, ak.expires_at
FROM api_keys ak
WHERE ak.user_id = user_id_param AND ak.expires_at > NOW();
END;
$$ LANGUAGE plpgsql;
```

### Parametry wejściowe
- `user_id_param` (INT) - Identyfikator użytkownika.

### Wynik

| Kolumna        | Typ danych | Opis                                  |
|---------------|-----------|--------------------------------------|
| `api_key`     | TEXT      | Klucz API przypisany do użytkownika. |
| `created_at`  | TIMESTAMP | Data utworzenia klucza.              |
| `expires_at`  | TIMESTAMP | Data wygaśnięcia klucza API.         |

### Przykład użycia

```sql
SELECT * FROM get_user_api_keys(3);
```

### Wynik

| api_key    | created_at          | expires_at          |
|-----------|---------------------|---------------------|
| key123456 | 2025-01-15 10:00:00 | 2026-01-15 10:00:00 |

---

## Funkcja: `check_user_billing_status`

### Opis
Funkcja `check_user_billing_status` sprawdza status ostatniej płatności użytkownika.

### Sygnatura
```sql
CREATE OR REPLACE FUNCTION check_user_billing_status(user_id_param INT)
RETURNS VARCHAR AS $$
DECLARE
billing_status VARCHAR;
BEGIN
SELECT status INTO billing_status
FROM billing b
WHERE b.user_id = user_id_param
ORDER BY b.billing_date DESC
LIMIT 1;

RETURN COALESCE(billing_status, 'no_records');
END;
$$ LANGUAGE plpgsql;
```

### Parametry wejściowe
- `user_id_param` (INT) - Identyfikator użytkownika.

### Wynik

| Kolumna        | Typ danych | Opis                                |
|---------------|-----------|------------------------------------|
| `status`      | VARCHAR   | Status ostatniego rozliczenia.    |

### Przykład użycia

```sql
SELECT check_user_billing_status(5);
```

### Wynik

| status   |
|---------|
| paid    |

---

## Funkcja: `count_unread_notifications`

### Opis
Funkcja `count_unread_notifications` zwraca liczbę nieprzeczytanych powiadomień dla danego użytkownika.

### Sygnatura
```sql
CREATE OR REPLACE FUNCTION count_unread_notifications(user_id_param INT)
RETURNS INT AS $$
DECLARE
unread_count INT;
BEGIN
SELECT COUNT(*) INTO unread_count
FROM notifications n
WHERE n.user_id = user_id_param AND n.read_status = FALSE;

RETURN unread_count;
END;
$$ LANGUAGE plpgsql;
```

### Parametry wejściowe
- `user_id_param` (INT) - Identyfikator użytkownika.

### Wynik

| Kolumna          | Typ danych   | Opis                                  |
|-----------------|-------------|--------------------------------------|
| `unread_count`  | INT         | Liczba nieprzeczytanych powiadomień. |

### Przykład użycia

```sql
SELECT count_unread_notifications(4);
```

## Funkcja: `get_users_above_avg_vms`

### Opis
Funkcja `get_users_above_avg_vms` zwraca użytkowników, którzy mają więcej maszyn wirtualnych niż średnia liczba maszyn na użytkownika.

### Sygnatura
```sql
CREATE OR REPLACE FUNCTION get_users_above_avg_vms()
RETURNS TABLE (user_id INT, username VARCHAR, vm_count INT) AS $$
BEGIN
RETURN QUERY
SELECT u.id, u.username, COUNT(v.id) AS vm_count
FROM users u
LEFT JOIN virtual_machines v ON u.id = v.user_id
GROUP BY u.id, u.username
HAVING COUNT(v.id) > (
    SELECT AVG(vm_count) 
    FROM (SELECT COUNT(id) AS vm_count FROM virtual_machines GROUP BY user_id) AS subq
);
END;
$$ LANGUAGE plpgsql;
```

### Wynik

| Kolumna     | Typ danych | Opis                                |
|-------------|-----------|------------------------------------|
| `user_id`   | INT       | Identyfikator użytkownika.         |
| `username`  | VARCHAR   | Nazwa użytkownika.                 |
| `vm_count`  | INT       | Liczba maszyn wirtualnych użytkownika. |

### Przykład użycia
```sql
SELECT * FROM get_users_above_avg_vms();
```

### Wynik
| user_id | username | vm_count |
|---------|----------|---------|
| 5       | jkowalski | 4       |



