#!/bin/bash

# Source database connection string from secrets
SOURCE_CONN="$DATABASE_URL"

# Target database connection string - MUST be defined elsewhere.
TARGET_CONN="$DB2" # Needs to be defined elsewhere or via environment variable


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


# Create a full backup of the source database
echo "Creating a full backup of the source database..."
pg_dump -Fc -d "${SOURCE_CONN}" > "${BACKUP_FILE}"

if [ $? -ne 0 ]; then
  echo "Error: Backup creation failed."
  exit 1
fi

echo "Backup created successfully at: ${BACKUP_FILE}"

# Create the target database if it doesn't exist
echo "Checking if target database exists..."
psql -c '\l' "${TARGET_CONN}" > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Creating target database..."
  createdb "${TARGET_CONN}"
  if [ $? -ne 0 ]; then
    echo "Error: Failed to create target database."
    exit 1;
  fi
fi

# Dump data only, excluding specified tables, with options
echo "Dumping data from source database..."
pg_dump -Fc --data-only --no-owner --no-privileges --no-tablespaces --schema-only -d "${SOURCE_CONN}"  --exclude-table "__diesel_schema_migrations" > "${TEMP_FILE}"

if [ $? -ne 0 ]; then
  echo "Error: Data dump failed."
  rm "${TEMP_FILE}"
  exit 1
fi

echo "Restoring data to target database..."
pg_restore -c -d "${TARGET_CONN}" "${TEMP_FILE}"

if [ $? -ne 0 ]; then
  echo "Error: Data restore failed."
  rm "${TEMP_FILE}"
  exit 1
fi


#Rename schema after restore (Important: This needs to be done AFTER restoring data)
echo "Renaming schema..."
psql -c "ALTER SCHEMA \"bitwarden\" RENAME TO public;" -d "${TARGET_CONN}"

if [ $? -ne 0 ]; then
  echo "Error: Schema rename failed."
  exit 1;
fi


echo "Data transfer complete."
rm "${TEMP_FILE}"

exit 0