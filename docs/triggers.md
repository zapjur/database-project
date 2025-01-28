---
layout: default
title: Triggers
nav_order: 3
---

# Wyzwalacz: `after_vm_insert`

## Opis
Wyzwalacz `after_vm_insert` służy do automatycznej aktualizacji dostępnych zasobów serwera po dodaniu nowej maszyny wirtualnej do tabeli `virtual_machines`. Funkcja `update_server_resources` sprawdza dostępność zasobów serwera oraz zmniejsza dostępne CPU, RAM i miejsce na dysku zgodnie z przydziałem nowej maszyny wirtualnej.

## Sygnatura
```sql
CREATE OR REPLACE TRIGGER after_vm_insert
AFTER INSERT ON virtual_machines
FOR EACH ROW
EXECUTE FUNCTION update_server_resources();
```

## Funkcja: `update_server_resources`

## Opis
Funkcja update_server_resources wykonuje następujące kroki:

- Sprawdza, czy serwer ma wystarczające zasoby (available_cpu, available_ram, available_disk).
- W przypadku braku wystarczających zasobów generuje wyjątek (RAISE EXCEPTION).
- Aktualizuje dostępne zasoby serwera, zmniejszając ich ilość o wartości przydzielone maszynie wirtualnej.

## Sygnatura
```sql
CREATE OR REPLACE FUNCTION update_server_resources()
RETURNS TRIGGER AS $$
BEGIN
    -- Sprawdzenie dostępnych zasobów
    IF NEW.cpu > (SELECT available_cpu FROM server_resources WHERE id = NEW.server_resource_id) OR
       NEW.ram > (SELECT available_ram FROM server_resources WHERE id = NEW.server_resource_id) OR
       NEW.disk > (SELECT available_disk FROM server_resources WHERE id = NEW.server_resource_id) THEN
        RAISE EXCEPTION 'Niewystarczające zasoby na serwerze o ID: %', NEW.server_resource_id;
    END IF;

    -- Aktualizacja dostępnych zasobów
    UPDATE server_resources
    SET
        available_cpu = available_cpu - NEW.cpu,
        available_ram = available_ram - NEW.ram,
        available_disk = available_disk - NEW.disk
    WHERE id = NEW.server_resource_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

## Przykład działania

### Przykładowe dane

Załóżmy, że tabela `server_resources` zawiera następujące dane przed dodaniem nowej maszyny wirtualnej:

| id | total_cpu | available_cpu | total_ram | available_ram | total_disk | available_disk |
|----|-----------|---------------|-----------|---------------|------------|----------------|
| 1  | 64        | 60            | 256       | 248           | 2000       | 1950           |

Tabela `virtual_machines` zawiera następujące dane:

| id | name      | os     | cpu | ram | disk | server_resource_id |
|----|-----------|--------|-----|-----|------|--------------------|
| 1  | VM1       | Ubuntu | 4   | 8   | 50   | 1                  |

### Zapytanie

```sql
INSERT INTO virtual_machines (name, os, cpu, ram, disk, server_resource_id)
VALUES ('VM2', 'Windows', 6, 12, 100, 1);
```

### Wynik

Po wykonaniu zapytania, tabela `server_resources` zostanie zaktualizowana:

| id | total_cpu | available_cpu | total_ram | available_ram | total_disk | available_disk |
|----|-----------|---------------|-----------|---------------|------------|----------------|
| 1  | 64        | 54            | 256       | 236           | 2000       | 1850           |

Tabela `virtual_machines` zostanie zaktualizowana o nową maszynę wirtualną:

| id | name      | os     | cpu | ram | disk | server_resource_id |
|----|-----------|--------|-----|-----|------|--------------------|
| 1  | VM1       | Ubuntu | 4   | 8   | 50   | 1                  |
| 2  | VM2       | Windows | 6   | 12  | 100  | 1                  |


## Uwagi

- Funkcja update_server_resources zapewnia integralność danych, uniemożliwiając dodanie maszyn wirtualnych, które przekraczają dostępne zasoby serwera.
- Wyjątek RAISE EXCEPTION jest generowany w przypadku niewystarczających zasobów, co zapobiega błędnym operacjom.
- Wyzwalacz działa automatycznie i nie wymaga dodatkowych działań użytkownika.