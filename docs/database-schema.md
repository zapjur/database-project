---
layout: default
title: Database Schema
nav_order: 1
---

# Schemat bazy danych

## Diagram ERD
![Diagram ERD](images/erd-diagram.png)

## Tabele

### Tabela: `server_resources`
- **Opis:** Przechowuje informacje o zasobach serwerowych.
- **Kolumny:**
    - `id` – unikalny identyfikator serwera (klucz główny).
    - `total_cpu` – całkowita liczba rdzeni procesora na serwerze.
    - `available_cpu` – liczba dostępnych rdzeni procesora.
    - `total_ram` – całkowita ilość pamięci RAM (w GB).
    - `available_ram` – dostępna ilość pamięci RAM (w GB).
    - `total_disk` – całkowita pojemność dysku (w GB).
    - `available_disk` – dostępna pojemność dysku (w GB).
    - `sla_id` – odniesienie do tabeli `sla` (klucz obcy).

### Tabela: `virtual_machines`
- **Opis:** Przechowuje informacje o maszynach wirtualnych.
- **Kolumny:**
    - `id` – unikalny identyfikator maszyny wirtualnej (klucz główny).
    - `name` – nazwa maszyny.
    - `os` – system operacyjny maszyny (np. Ubuntu, Windows).
    - `cpu` – liczba przydzielonych rdzeni procesora.
    - `ram` – przydzielona pamięć RAM (w GB).
    - `disk` – przydzielona pojemność dysku (w GB).
    - `server_resource_id` – odniesienie do tabeli `server_resources` (klucz obcy).

### Tabela: `sla`
- **Opis:** Przechowuje informacje o poziomach SLA (Service Level Agreement).
- **Kolumny:**
    - `id` – unikalny identyfikator SLA (klucz główny).
    - `service_level` – nazwa poziomu SLA (np. Gold, Silver).
    - `uptime_guarantee` – gwarantowany czas działania (w procentach, np. 99.9).
    - `response_time` – gwarantowany czas reakcji (w minutach).

### Tabela: `deployment_history`
- **Opis:** Przechowuje historię wdrożeń dla maszyn wirtualnych.
- **Kolumny:**
    - `id` – unikalny identyfikator wdrożenia (klucz główny).
    - `virtual_machine_id` – odniesienie do tabeli `virtual_machines` (klucz obcy).
    - `deployment_date` – data i godzina wdrożenia.
    - `version` – wersja wdrożonego oprogramowania.
    - `status` – status wdrożenia (np. success, failure).

---

## Relacje między tabelami

### 1. Relacja `server_resources` -> `sla`
- Każdy serwer (`server_resources`) ma przypisany jeden poziom SLA (`sla`).
- Relacja typu N:1 (wiele serwerów, jeden poziom SLA).
- Kolumna `sla_id` w tabeli `server_resources` odnosi się do `id` w tabeli `sla`.

### 2. Relacja `server_resources` -> `virtual_machines`
- Każdy serwer (`server_resources`) może być powiązany z wieloma maszynami wirtualnymi (`virtual_machines`).
- Relacja typu 1:N (jeden serwer, wiele maszyn).
- Kolumna `server_resource_id` w tabeli `virtual_machines` odnosi się do `id` w tabeli `server_resources`.

### 3. Relacja `virtual_machines` -> `deployment_history`
- Każda maszyna wirtualna (`virtual_machines`) może mieć wiele wpisów w historii wdrożeń (`deployment_history`).
- Relacja typu 1:N (jedna maszyna, wiele wdrożeń).
- Kolumna `virtual_machine_id` w tabeli `deployment_history` odnosi się do `id` w tabeli `virtual_machines`.

---

## Dodatkowe informacje

- **Klucze główne i obce:**
    - Każda tabela ma zdefiniowany klucz główny (`id`).
    - Klucze obce (`server_resource_id`, `virtual_machine_id`, `sla_id`) zapewniają integralność referencyjną między tabelami.

- **Normalizacja:**
    - Schemat został zaprojektowany zgodnie z 2NF, aby unikać redundancji danych i zapewnić spójność.
