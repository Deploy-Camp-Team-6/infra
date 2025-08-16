CREATE DATABASE "{{ shared_postgres_db }}";
GRANT ALL PRIVILEGES ON DATABASE "{{ shared_postgres_db }}" TO "{{ shared_postgres_user }}";
