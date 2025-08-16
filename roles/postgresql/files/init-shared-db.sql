CREATE DATABASE "{{ shared_postgres_db }}";

DO
$$
BEGIN
    IF NOT EXISTS (
        SELECT FROM pg_catalog.pg_roles WHERE rolname = '{{ shared_postgres_user }}'
    ) THEN
        CREATE ROLE "{{ shared_postgres_user }}" WITH LOGIN PASSWORD '{{ shared_postgres_password }}';
    END IF;
END
$$;

GRANT ALL PRIVILEGES ON DATABASE "{{ shared_postgres_db }}" TO "{{ shared_postgres_user }}";
