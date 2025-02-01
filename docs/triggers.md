---
layout: default
title: Triggers
nav_order: 3
---

# Wyzwalacze

---

## Wyzwalacz: `after_vm_insert`

### Opis  
Aktualizuje zasoby serwera po dodaniu nowej maszyny wirtualnej. Blokuje operację, jeśli brakuje zasobów.

### Sygnatura
```sql
CREATE OR REPLACE TRIGGER after_vm_insert
AFTER INSERT ON virtual_machines
FOR EACH ROW
EXECUTE FUNCTION update_server_resources_after_insert();
```

### Funkcja
```sql
CREATE OR REPLACE FUNCTION update_server_resources_after_insert()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.cpu > (SELECT available_cpu FROM server_resources WHERE id = NEW.server_resource_id) THEN
        RAISE EXCEPTION 'Brak CPU na serwerze %', NEW.server_resource_id;
    END IF;
    
    UPDATE server_resources
    SET available_cpu = available_cpu - NEW.cpu,
        available_ram = available_ram - NEW.ram
    WHERE id = NEW.server_resource_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

### Przykład
**Zapytanie:**
```sql
INSERT INTO virtual_machines (name, cpu, ram, server_resource_id) 
VALUES ('VM-Prod', 4, 16, 1);
```

**Wynik:**  
- Serwer `1`: `available_cpu` zmniejszone o 4, `available_ram` o 16.
- Nowy wpis w `virtual_machines`.

---

## Wyzwalacz: `after_vm_delete`

### Opis  
Przywraca zasoby serwera po usunięciu maszyny wirtualnej.

### Sygnatura
```sql
CREATE OR REPLACE TRIGGER after_vm_delete
AFTER DELETE ON virtual_machines
FOR EACH ROW
EXECUTE FUNCTION restore_server_resources_after_delete();
```

### Funkcja
```sql
CREATE OR REPLACE FUNCTION restore_server_resources_after_delete()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE server_resources
    SET available_cpu = available_cpu + OLD.cpu,
        available_ram = available_ram + OLD.ram
    WHERE id = OLD.server_resource_id;
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
```

### Przykład
**Zapytanie:**
```sql
DELETE FROM virtual_machines WHERE id = 5;
```

**Wynik:**  
- Serwer `1`: `available_cpu` zwiększone o 4, `available_ram` o 16 (przywrócone zasoby z usuniętej maszyny).

---

## Wyzwalacz: `after_vm_update`

### Opis  
Aktualizuje zasoby po zmianie parametrów maszyny wirtualnej (np. skalowanie CPU/RAM).

### Sygnatura
```sql
CREATE OR REPLACE TRIGGER after_vm_update
AFTER UPDATE ON virtual_machines
FOR EACH ROW
EXECUTE FUNCTION update_server_resources_after_update();
```

### Funkcja
```sql
CREATE OR REPLACE FUNCTION update_server_resources_after_update()
RETURNS TRIGGER AS $$
BEGIN
    -- Przywróć stare wartości
    UPDATE server_resources
    SET available_cpu = available_cpu + OLD.cpu,
        available_ram = available_ram + OLD.ram
    WHERE id = OLD.server_resource_id;

    -- Zastosuj nowe wartości
    UPDATE server_resources
    SET available_cpu = available_cpu - NEW.cpu,
        available_ram = available_ram - NEW.ram
    WHERE id = NEW.server_resource_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

### Przykład
**Zapytanie:**
```sql
UPDATE virtual_machines 
SET cpu = 8, ram = 32 
WHERE id = 5;
```

**Wynik:**  
- Serwer `1`: `available_cpu` zmienione z `60` na `56` (8 - 4 = +4), `available_ram` z `248` na `232` (32 - 16 = +16).

---

## Wyzwalacz: `log_vm_changes_trigger`

### Opis  
Rejestruje zmiany w tabeli `virtual_machines` w tabeli `logs`.

### Sygnatura
```sql
CREATE OR REPLACE TRIGGER log_vm_changes_trigger
AFTER INSERT OR UPDATE OR DELETE ON virtual_machines
FOR EACH ROW
EXECUTE FUNCTION log_vm_changes();
```

### Funkcja
```sql
CREATE OR REPLACE FUNCTION log_vm_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO logs (event_type, description)
        VALUES ('VM_CREATED', 'Dodano maszynę ' || NEW.name);
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO logs (event_type, description)
        VALUES ('VM_UPDATED', 'Zmodyfikowano maszynę ' || NEW.name);
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO logs (event_type, description)
        VALUES ('VM_DELETED', 'Usunięto maszynę ' || OLD.name);
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;
```

### Przykład
**Operacja DELETE:**
```sql
DELETE FROM virtual_machines WHERE id = 5;
```

**Wpis w `logs`:**
```
| event_type  | description           |
|-------------|-----------------------|
| VM_DELETED  | Usunięto maszynę VM-Prod |
```
---

## Wyzwalacz: `after_billing_insert`

### Opis  
Wysyła powiadomienie o nowym rozliczeniu.

### Sygnatura
```sql
CREATE OR REPLACE TRIGGER after_billing_insert
AFTER INSERT ON billing
FOR EACH ROW
EXECUTE FUNCTION notify_new_billing();
```

### Funkcja
```sql
CREATE OR REPLACE FUNCTION notify_new_billing()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO notifications (user_id, message)
    VALUES (NEW.user_id, 'Nowe rozliczenie: ' || NEW.amount || ' PLN');
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

### Przykład
**Zapytanie:**
```sql
INSERT INTO billing (user_id, amount, status) 
VALUES (100, 299.99, 'PENDING');
```

**Wynik:**  
```
Nowy wpis w `notifications`:
| user_id | message                   |
|---------|---------------------------|
| 100     | Nowe rozliczenie: 299.99 PLN |
```
---

## Wyzwalacz: `after_billing_status_update`

### Opis  
Wysyła powiadomienie o zmianie statusu rozliczenia.

### Sygnatura
```sql
CREATE OR REPLACE TRIGGER after_billing_status_update
AFTER UPDATE ON billing
FOR EACH ROW
EXECUTE FUNCTION notify_billing_status_change();
```

### Funkcja
```sql
CREATE OR REPLACE FUNCTION notify_billing_status_change()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status <> NEW.status THEN
        INSERT INTO notifications (user_id, message)
        VALUES (NEW.user_id, 'Status rozliczenia zmieniony z ' || OLD.status || ' na ' || NEW.status);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

### Przykład
**Zapytanie:**
```sql
UPDATE billing 
SET status = 'PAID' 
WHERE id = 1;
```

**Wynik:**  
```
Nowy wpis w `notifications`:
| user_id | message                                  |
|---------|------------------------------------------|
| 100     | Status rozliczenia zmieniony z PENDING na PAID |
```
---

## Uwagi
1. **Integralność danych:** Wyzwalacze blokują operacje, które naruszają limity zasobów (np. przekroczenie dostępnego CPU).
2. **Automatyzacja:** Wszystkie aktualizacje zasobów i powiadomienia są wykonywane bez interwencji użytkownika.
3. **Logowanie:** Każda zmiana w tabeli `virtual_machines` jest rejestrowana w `logs`.