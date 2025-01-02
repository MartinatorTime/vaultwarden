#!/bin/bash

# Source database connection string from secrets (better error handling)
SOURCE_CONN="$DATABASE_URL"
if [[ -z "$SOURCE_CONN" ]]; then
  echo "Error: SOURCE_CONN environment variable not set."
  exit 1
fi

# Target database connection string - MUST be defined elsewhere or via env var
TARGET_CONN="$DB2"
if [[ -z "$TARGET_CONN" ]]; then
  echo "Error: TARGET_CONN environment variable not set."
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

# Function to run psql commands with error checking
run_psql() {
  local command="$1"
  local conn="$2"
  echo "Running: $command"
  psql -c "$command" "$conn" || {
    echo "Error: psql command failed: $command"
    exit 1
  }
}


# Create a full backup of the source database
echo "Creating a full backup of the source database..."
pg_dump -Fc -d "${SOURCE_CONN}" > "${BACKUP_FILE}" || {
  echo "Error: Backup creation failed."
  exit 1
}
echo "Backup created successfully at: ${BACKUP_FILE}"

# Get the source database name (more robust)
SOURCE_DB=$(echo "$SOURCE_CONN" | sed 's/.*dbname=\(.*\)/\1/')

# Create the target database if it doesn't exist
echo "Checking if target database exists..."
run_psql "\l" "$TARGET_CONN"
if [[ $? -ne 0 ]]; then
  echo "Creating target database..."
  run_psql "CREATE DATABASE ${SOURCE_DB}" "$TARGET_CONN"
fi


# --- Crucial Step: Create Schema in Target Database (improved) ---
echo "Creating schema in target database..."
#  Instead of hardcoding schema creation, use a separate SQL file.
#  This allows for better management of schema changes.
if [[ ! -f "schema.sql" ]]; then
  echo "Error: schema.sql file not found. Create this file with your schema definition."
  exit 1
fi
psql -f schema.sql -d "$TARGET_CONN" || {
  echo "Error: Schema creation failed."
  exit 1
}


# Dump data only, excluding specified tables, with options
echo "Dumping data from source database..."
pg_dump -Fc --data-only --no-owner --no-privileges --no-tablespaces -d "${SOURCE_CONN}" --exclude-table "__diesel_schema_migrations" > "${TEMP_FILE}" || {
  echo "Error: Data dump failed."
  rm "${TEMP_FILE}"
  exit 1
}

echo "Restoring data to target database..."
pg_restore -c -d "$TARGET_CONN" "${TEMP_FILE}" || {
  echo "Error: Data restore failed."
  rm "${TEMP_FILE}"
  exit 1
}

# Rename schema (use with EXTREME caution -  commented out by default)
#  Renaming public is generally discouraged. Consider if this is truly necessary.
# echo "Renaming schema..."
# run_psql "ALTER SCHEMA \"bitwarden\" RENAME TO public;" "$TARGET_CONN"


echo "Data transfer complete."
rm "${TEMP_FILE}"

exit 0