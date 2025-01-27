---
layout: default
title: Functions
nav_order: 2
---

# Funkcja: `check_sla_threshold`

## Opis
Funkcja `check_sla_threshold` służy do analizy poziomów SLA, które nie spełniają określonego progu gwarantowanego czasu działania (uptime). Zwraca tabelę zawierającą identyfikator SLA, nazwę poziomu SLA oraz gwarantowany czas działania dla tych poziomów SLA, które mają `uptime_guarantee` mniejszy niż podany próg.

## Sygnatura
```sql
CREATE OR REPLACE FUNCTION check_sla_threshold(threshold DECIMAL)
RETURNS TABLE (sla_id INT, service_level VARCHAR, uptime_guarantee DECIMAL) AS $$
BEGIN
RETURN QUERY
SELECT s.id, s.service_level, s.uptime_guarantee
FROM sla s
WHERE s.uptime_guarantee < threshold;
END;
$$ LANGUAGE plpgsql;
```

---

## Parametry wejściowe
`treshold` (DECIMAL) - Próg gwarantowanego czasu działania w procentach, poniżej którego funkcja zwraca poziomy SLA.

---

## Wynik

Tabela zawierająca następujące kolumny:
- `sla_id` (INT) - Unikalny identyfikator poziomu SLA.
- `service_level` (VARCHAR) - Nazwa poziomu SLA.
- `uptime_guarantee` (DECIMAL) - Gwarantowany czas działania w procentach.

---

## Przykład użycia

### Wywołanie funkcji

```sql
SELECT * FROM check_sla_threshold(99.95);
```

### Wynik

Zakładając, że tabela `sla` zawiera następujące dane:

| id | service_level | uptime_guarantee |
|----|---------------|------------------|
| 1  | Gold          | 99.99           |
| 2  | Silver        | 99.90           |
| 3  | Bronze        | 99.00           |

Zapytanie zwróci:

| sla_id | service_level | uptime_guarantee |
|--------|---------------|------------------|
| 2      | Silver        | 99.90            |
| 3      | Bronze        | 99.00            |

