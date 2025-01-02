#!/bin/bash

# Source database connection string from secrets (better error handling)  -  REPLACE THESE!
SOURCE_CONN="$DATABASE_URL"
TARGET_CONN="$DB2"

# Backup directory
BACKUP_DIR="./data"

# Temporary files
TEMP_SCHEMA_FILE=$(mktemp)
TEMP_DATA_FILE=$(mktemp)

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
    echo "Error: $description failed. Check PostgreSQL logs for details.  Command was: '$command'"
    exit 1
  fi
}


# Create a full backup of the source database (for safety)
echo "Creating a full backup of the source database..."
run_psql "SELECT 1;" "$SOURCE_CONN" "Testing source connection"
pg_dump -Fc -d "${SOURCE_CONN}" > "${BACKUP_FILE}" 2>&1 || {
  echo "Error: Backup creation failed. Check pg_dump output and ensure the connection string is correct."
  exit 1
}
echo "Backup created successfully at: ${BACKUP_FILE}"


# Check if the target database exists; create it if necessary.
VAULTWARDEN_DB="vaultwarden" #Database Name
echo "Checking if target Vaultwarden database exists..."
if psql -tAc "SELECT 1 FROM pg_database WHERE datname = '$VAULTWARDEN_DB'" "$TARGET_CONN" > /dev/null 2>&1; then
  echo "Target Vaultwarden database '$VAULTWARDEN_DB' already exists."
else
  echo "Creating target Vaultwarden database '$VAULTWARDEN_DB'..."
  run_psql "CREATE DATABASE ${VAULTWARDEN_DB} OWNER postgres;" "$TARGET_CONN" "Creating target Vaultwarden database"
fi


# --- Schema Migration ---
echo "Migrating Vaultwarden schema..."
pg_dump --schema-only -d "$SOURCE_CONN" -t "$VAULTWARDEN_DB" > "$TEMP_SCHEMA_FILE" 2>&1 || {
  echo "Error: Schema dump failed. Check pg_dump output:"
  cat "$TEMP_SCHEMA_FILE" >&2
  rm "$TEMP_SCHEMA_FILE"
  exit 1
}
psql -f "$TEMP_SCHEMA_FILE" -d "$TARGET_CONN" || {
  echo "Error: Schema creation failed. Check schema file and PostgreSQL logs for errors."
  rm "$TEMP_SCHEMA_FILE"
  exit 1
}
rm "$TEMP_SCHEMA_FILE"


# --- Data Migration ---
echo "Migrating Vaultwarden data..."
pg_dump -Fc --data-only -d "${SOURCE_CONN}" -t "$VAULTWARDEN_DB" > "${TEMP_DATA_FILE}" 2>&1 || {
  echo "Error: Data dump failed. Check pg_dump output for details."
  rm "${TEMP_DATA_FILE}"
  exit 1
}
pg_restore -c -d "$TARGET_CONN" "${TEMP_DATA_FILE}" || {
  echo "Error: Data restore failed. Check pg_restore output for details."
  rm "${TEMP_DATA_FILE}"
  exit 1
}
rm "${TEMP_DATA_FILE}"

echo "Vaultwarden data transfer complete."

exit 0