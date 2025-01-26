up:
	docker-compose up --build -d

restart:
	docker-compose down
	docker volume rm database-project_postgres_data
	docker-compose up --build -d

down:
	docker-compose down