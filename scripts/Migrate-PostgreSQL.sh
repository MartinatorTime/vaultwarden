#!/bin/bash

# Source database connection string
SOURCE_CONN="$DATABASE_URL"

# Target database connection string
TARGET_CONN="$DB2"


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
if [ ! -d "${BACKUP_DIR}" ]; then
  mkdir -p "${BACKUP_DIR}"
fi

# --- Function to parse PostgreSQL connection string ---
parse_conn_string() {
  local conn_string="$1"
  local host user_pass host_port db

  host=$(echo "${conn_string}" | sed 's|^postgres://\([^:]*\):.*|\1|')
  user_pass=$(echo "${conn_string}" | sed 's|^postgres://[^:]*:\([^@]*\)@.*|\1|')
  host_port=$(echo "${conn_string}" | sed 's|^postgres://[^:]*:\([^@]*\)@\(.*\)/.*|\2|')
  db=$(echo "${conn_string}" | sed 's|^postgres://[^:]*:[^@]*@.*\/\(.*\)| \1|')

  # Extract user and password
  user=$(echo "${user_pass}" | cut -d: -f1)
  pass=$(echo "${user_pass}" | cut -d: -f2)


  #Handle port separately
  if [[ $host_port =~ ":" ]]; then
    host=$(echo "${host_port}" | cut -d: -f1)
    port=$(echo "${host_port}" | cut -d: -f2)
  else
    port=5432
  fi

  echo "$host" "$port" "$user" "$pass" "$db"
}

# --- Parse source and target connection strings ---
parse_conn_string "${SOURCE_CONN}"
SOURCE_HOST="$REPLY"
SOURCE_PORT="$2"
SOURCE_USER="$3"
SOURCE_PASS="$4"
SOURCE_DB="$5"

parse_conn_string "${TARGET_CONN}"
TARGET_HOST="$REPLY"
TARGET_PORT="$2"
TARGET_USER="$3"
TARGET_PASS="$4"
TARGET_DB="$5"


# Create a full backup of the source database
echo "Creating a full backup of the source database..."
pg_dump -h "${SOURCE_HOST}" -p "${SOURCE_PORT}" -U "${SOURCE_USER}" -Fc "${SOURCE_DB}" > "${BACKUP_FILE}"

if [ $? -ne 0 ]; then
  echo "Error: Backup creation failed."
  exit 1
fi

echo "Backup created successfully at: ${BACKUP_FILE}"

# Create the target database if it doesn't exist
echo "Checking if target database exists..."
psql -h "${TARGET_HOST}" -p "${TARGET_PORT}" -U "${TARGET_USER}" -d "${TARGET_DB}" -c '\l' > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Creating target database '${TARGET_DB}'..."
  createdb -h "${TARGET_HOST}" -p "${TARGET_PORT}" -U "${TARGET_USER}" "${TARGET_DB}"
  if [ $? -ne 0 ]; then
    echo "Error: Failed to create target database."
    exit 1;
  fi
fi

# Dump data only from the source database
echo "Dumping data from source database..."
pg_dump -h "${SOURCE_HOST}" -p "${SOURCE_PORT}" -U "${SOURCE_USER}" -Fc --sslmode=require --no-privileges --no-owner --no-tablespaces --data-only "${SOURCE_DB}" > "${TEMP_FILE}"

if [ $? -ne 0 ]; then
  echo "Error: Data dump failed."
  rm "${TEMP_FILE}"
  exit 1
fi

echo "Restoring data to target database..."
pg_restore -c -h "${TARGET_HOST}" -p "${TARGET_PORT}" -U "${TARGET_USER}" -d "${TARGET_DB}" "${TEMP_FILE}"

if [ $? -ne 0 ]; then
  echo "Error: Data restore failed."
  rm "${TEMP_FILE}"
  exit 1
fi

echo "Data transfer complete."
rm "${TEMP_FILE}"

exit 0