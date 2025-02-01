---
layout: default
title: Main
nav_exclude: true
---

# Dokumentacja projektu: Hosting aplikacji w chmurze

## Wstęp
Projekt bazy danych dla systemu zarządzania usługami hostingu w chmurze.

### Technologie
- PostgreSQL
- Docker

## Uruchomienie

Aby uruchomić projekt lokalnie, wykonaj następujące kroki:

1. Sklonuj repozytorium:
    ```bash
    git clone https://github.com/zapjur/database-project.git
   ```

2. Przejdź do katalogu projektu:
    ```bash
    cd database-project
    ```

3. Uruchom usługi przy użyciu `docker-compose`:
    ```bash
    docker-compose up --build -d
    ```
   
4. pgAdmin dostępny jest pod adresem `http://localhost:8080`, a baza danych pod adresem `localhost:5432`.

 - **Login**: `admin@admin.com`
 - **Hasło**: `admin`
 - Można zmienić w pliku `docker-compose.yml`

## Uwagi

W razie wprowadzenia zmian w katalogu init-scripts, należy zrestartować kontener bazy danych, aby skrypty zostały ponownie uruchomione. Co więcej należy usunąć wolumen zawierający baze, następującą komendą:
```bash
docker volume rm database-project_postgres_data
```

W przeciwnym wypadku, zostanie pominięty etap inicjalizacji bazy danych i zmiany nie zostaną wprowadzone.

Aby to uprościć powstał Makefile, który pozwala na automatyzację tego procesu. Wystarczy wywołać komendę:
```bash
make restart
```
