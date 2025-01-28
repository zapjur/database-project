---
layout: default
title: Views
nav_order: 4
---

# Widok: `resource_usage`

## Opis
Widok `resource_usage` służy do monitorowania wykorzystania zasobów przez maszyny wirtualne oraz dostępnych zasobów serwerów, na których są uruchomione. Łączy dane z tabel `virtual_machines` i `server_resources`, aby dostarczyć pełny obraz przypisanych i dostępnych zasobów.

## Sygnatura
```sql
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
```

## Kolumny widoku

- `vm_id` (INT) - Unikalny identyfikator maszyny wirtualnej.
- `vm_name` (VARCHAR(100)) - Nazwa maszyny wirtualnej.
- `cpu` (INT) - liczba przydzielonych rdzeni procesora dla maszyny wirtualnej.
- `ram` (INT) - ilość przydzielonej pamięci RAM (w GB) dla maszyny wirtualnej.
- `disk` (INT) - ilość przydzielonego miejsca na dysku (w GB) dla maszyny wirtualnej.
- `available_cpu` (INT) - dostępna liczba rdzeni procesora na serwerze, na którym działa maszyna wirtualna.
- `available_ram` (INT) - dostępna ilość pamięci RAM (w GB) na serwerze, na którym działa maszyna wirtualna.
- `available_disk` (INT) - dostępna ilość miejsca na dysku (w GB) na serwerze, na którym działa maszyna wirtualna.

## Przykład użycia

### Przykładowe dane

Załóżmy, że tabela `virtual_machines` zawiera następujące dane:

| id | name | cpu | ram | disk | server_resource_id |
|----|-----|-----|-----|------|--------------------|
| 1  | VM1 | 2   | 4   | 50   | 1                  |
| 2  | VM2 | 4   | 8   | 100  | 1                  |

Tabela `server_resources` zawiera dane:

| id | total_cpu | available_cpu | total_ram | available_ram | total_disk | available_disk |
|----|-----------|---------------|-----------|---------------|------------|----------------|
| 1  | 8         | 2             | 16        | 4             | 200        | 50             |

### Przykładowe zapytanie

```sql
SELECT * FROM resource_usage;
```

### Wynik

Zapytanie zwróci:

| vm_id | vm_name | cpu | ram | disk | available_cpu | available_ram | available_disk |
|-------|---------|-----|-----|------|---------------|---------------|----------------|
| 1     | VM1     | 2   | 4   | 50   | 2             | 4             | 50             |
| 2     | VM2     | 4   | 8   | 100  | 2             | 4             | 50             |


## Uwagi

- Widok resource_usage pozwala na łatwe monitorowanie i analizę przypisanych zasobów oraz ich dostępności na serwerach.
- Widok może być używany w raportach dotyczących efektywności wykorzystania infrastruktury.
- Łączy dane za pomocą klucza obcego server_resource_id, który odnosi maszyny wirtualne do serwerów.