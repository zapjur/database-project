# Procedury składowane

## Procedura: `bulk_update_sla_uptime`

### Opis
Aktualizuje gwarantowany czas działania (`uptime_guarantee`) dla wszystkich poziomów SLA poniżej podanego progu, zwiększając go o określoną wartość.

### Sygnatura
```sql
CREATE OR REPLACE PROCEDURE bulk_update_sla_uptime(
    threshold DECIMAL, 
    increment DECIMAL
)
```

### Parametry wejściowe
| Nazwa       | Typ danych | Opis                                  |
|-------------|-----------|--------------------------------------|
| `threshold` | DECIMAL   | Próg, poniżej którego SLA są aktualizowane. |
| `increment` | DECIMAL   | Wartość, o którą zwiększany jest `uptime_guarantee`. |

### Przykład użycia
```sql
CALL bulk_update_sla_uptime(99.9, 0.5);
```

---

## Procedura: `deactivate_expired_api_keys`

### Opis
Automatycznie dezaktywuje wygasłe klucze API, ustawiając ich datę wygaśnięcia na bieżący czas.

### Sygnatura
```sql
CREATE OR REPLACE PROCEDURE deactivate_expired_api_keys()
```

### Przykład użycia
```sql
CALL deactivate_expired_api_keys();
```
