#!/bin/bash

# Налаштування облікових даних PostgreSQL
PGPASSWORD=password
export PGPASSWORD

# Шлях до резервної копії
filename=$1

# Налаштування з'єднання з PostgreSQL
dbUser=postgres
database=postgres_db
host=postgres  # Ім'я контейнера PostgreSQL з Docker Compose
port=5432

# Перевірка доступності PostgreSQL перед завантаженням дампу
until psql -U $dbUser -h $host -p $port -d $database -c '\q'; do
  >&2 echo "Postgres не готовий... чекаємо"
  sleep 5
done

# Переконайтеся, що резервна копія існує
if [ ! -f "$filename" ]; then
  echo "Файл резервної копії $filename не знайдено!"
  exit 1
fi

# Відновлення бази даних з резервної копії
pg_restore -U $dbUser -h $host -p $port -d $database "$filename"

# Очистка пароля
unset PGPASSWORD
