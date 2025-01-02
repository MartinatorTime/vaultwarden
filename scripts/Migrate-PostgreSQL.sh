#!/bin/bash

# Source database connection string from secrets (better error handling)
SOURCE_CONN="$DATABASE_URL"
if [[ -z "$SOURCE_CONN" ]]; then
  echo "Error: SOURCE_CONN environment variable not set.  Please set it to a valid PostgreSQL connection string (e.g., 'postgresql://user:password@host:port/database')."
  exit 1
fi

# Target database connection string - MUST be defined elsewhere or via env var
TARGET_CONN="$DB2"
if [[ -z "$TARGET_CONN" ]]; then
  echo "Error: TARGET_CONN environment variable not set. Please set it to a valid PostgreSQL connection string (e.g., 'postgresql://user:password@host:port/database')."
  exit 1
fi

# Backup directory
BACKUP_DIR="./data"

# Temporary file for data-only dump
TEMP_FILE=$(mktemp)

# Backup filename
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/postgres_backup_${TIMESTAMP}.dump"

# Check if pg_dump and pg_restore are installed
if ! command -v pg_dump &> /dev/null || ! command -v pg_restore &> /dev/null; then
  echo "Error: pg_dump or pg_restore command not found. Make sure PostgreSQL is installed and pg_dump/pg_restore are in your PATH."
  exit 1
fi

# Create backup directory if it doesn't exist
mkdir -p "${BACKUP_DIR}"

# Function to run psql commands with improved error checking and messaging
run_psql() {
  local command="$1"
  local conn="$2"
  local description="$3"
  echo "Running: $command ($description)"
  if psql -c "$command" "$conn" > /dev/null 2>&1; then
    echo "$description successful."
  else
    echo "Error: $description failed.  Check PostgreSQL logs for details."
    exit 1
  fi
}

# Create a full backup of the source database
echo "Creating a full backup of the source database..."
run_psql "SELECT 1;" "$SOURCE_CONN" "Testing source connection" #Test the connection before dumping
pg_dump -Fc -d "${SOURCE_CONN}" > "${BACKUP_FILE}" || {
  echo "Error: Backup creation failed. Check pg_dump output and ensure the connection string is correct."
  exit 1
}
echo "Backup created successfully at: ${BACKUP_FILE}"

# Get the source database name (more robust)
SOURCE_DB=$(echo "$SOURCE_CONN" | sed 's/.*dbname=\(.*\)/\1/')

# Check if the target database exists.  Use a more reliable method.
echo "Checking if target database exists..."
if psql -tAc "SELECT 1 FROM pg_database WHERE datname = '$SOURCE_DB'" "$TARGET_CONN" > /dev/null 2>&1; then
  echo "Target database '$SOURCE_DB' already exists."
else
  echo "Creating target database '$SOURCE_DB'..."
  run_psql "CREATE DATABASE ${SOURCE_DB}" "$TARGET_CONN" "Creating target database"
fi


# --- Crucial Step: Create Schema in Target Database (improved) ---
echo "Creating schema in target database..."
if [[ ! -f "schema.sql" ]]; then
  echo "Error: schema.sql file not found. Create this file with your schema definition.  Example contents:
CREATE TABLE my_table (id SERIAL PRIMARY KEY, name TEXT);
"
  exit 1
fi
psql -f schema.sql -d "$TARGET_CONN" || {
  echo "Error: Schema creation failed. Check schema.sql and PostgreSQL logs for errors."
  exit 1
}


# Dump data only, excluding specified tables, with options
echo "Dumping data from source database..."
pg_dump -Fc --data-only --no-owner --no-privileges --no-tablespaces -d "${SOURCE_CONN}" --exclude-table "__diesel_schema_migrations" > "${TEMP_FILE}" || {
  echo "Error: Data dump failed. Check pg_dump output for details."
  rm "${TEMP_FILE}"
  exit 1
}

echo "Restoring data to target database..."
pg_restore -c -d "$TARGET_CONN" "${TEMP_FILE}" || {
  echo "Error: Data restore failed. Check pg_restore output for details."
  rm "${TEMP_FILE}"
  exit 1
}

echo "Data transfer complete."
rm "${TEMP_FILE}"

exit 0