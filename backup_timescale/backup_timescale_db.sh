#!/bin/bash

# Backup script for ramp_iiot-timescale-db
# This script creates a backup of ALL databases in the TimescaleDB PostgreSQL cluster

set -e
export $(cat ../.env.secrets | grep "#" -v)

# Configuration
CONTAINER_NAME="ramp_iiot-timescale-db"
BACKUP_DIR="."
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="ramp_iiot_timescaledb_ALL_backup_${TIMESTAMP}.sql"


DB_USER="${ORIONLD_TROE_USER}"
# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Create backup directory if it doesn't exist
mkdir -p "${BACKUP_DIR}"

echo -e "${YELLOW}Starting backup of ALL databases in TimescaleDB...${NC}"
echo "Container: ${CONTAINER_NAME}"
echo "User: ${DB_USER}"
echo "Backup directory: ${BACKUP_DIR}"
echo "Backup file: ${BACKUP_FILE}"
echo "Backup user:${DB_USER}"

echo ""

# Check if container is running
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo -e "${RED}Error: Container ${CONTAINER_NAME} is not running${NC}"
    exit 1
fi

# List all databases
echo -e "${YELLOW}Listing all databases...${NC}"
docker exec "${CONTAINER_NAME}" psql -U "${DB_USER}" -c "\l" | grep -E "^\s\w"
echo ""

# Perform the backup using pg_dumpall
echo -e "${YELLOW}Creating database dump (all databases, roles, and tablespaces)...${NC}"
echo -e "${YELLOW}This may take several minutes depending on database size...${NC}"
echo ""

# Create a temporary file for verbose output
VERBOSE_LOG="${BACKUP_DIR}/${BACKUP_FILE}.progress"

# Run pg_dumpall with verbose output
docker exec "${CONTAINER_NAME}" pg_dumpall -U "${DB_USER}" \
    --clean --if-exists --verbose \
    > "${BACKUP_DIR}/${BACKUP_FILE}" 2>"${VERBOSE_LOG}" &

# Get the PID of the background process
DUMP_PID=$!

# Show progress indicator while backup is running
LAST_DB=""
while kill -0 $DUMP_PID 2>/dev/null; do
    # Get current database being processed from verbose log
    if [ -f "${VERBOSE_LOG}" ]; then
        CURRENT_DB=$(grep -oP "pg_dump: dumping database \"\K[^\"]*" "${VERBOSE_LOG}" | tail -1)
        if [ ! -z "$CURRENT_DB" ] && [ "$CURRENT_DB" != "$LAST_DB" ]; then
            echo -e "${GREEN}Processing database: ${CURRENT_DB}${NC}"
            LAST_DB="$CURRENT_DB"
        fi
    fi
    
    # Get current file size
    if [ -f "${BACKUP_DIR}/${BACKUP_FILE}" ]; then
        CURRENT_SIZE=$(du -h "${BACKUP_DIR}/${BACKUP_FILE}" 2>/dev/null | cut -f1)
        echo -ne "\r  Backup size: ${CURRENT_SIZE}  "
    fi
    sleep 2
done

# Wait for the process to complete and get exit status
wait $DUMP_PID
BACKUP_EXIT_CODE=$?

# Clean up verbose log
rm -f "${VERBOSE_LOG}"

echo -e "\n"

echo -e "\n"

# Check if backup was successful
if [ $BACKUP_EXIT_CODE -eq 0 ]; then
    # Get backup file size
    BACKUP_SIZE=$(du -h "${BACKUP_DIR}/${BACKUP_FILE}" | cut -f1)
    echo -e "${GREEN}✓ Backup completed successfully!${NC}"
    echo "Backup file: ${BACKUP_DIR}/${BACKUP_FILE}"
    echo "Size: ${BACKUP_SIZE}"
    
    # Compress the backup
    echo -e "${YELLOW}Compressing backup...${NC}"
    gzip "${BACKUP_DIR}/${BACKUP_FILE}"
    COMPRESSED_SIZE=$(du -h "${BACKUP_DIR}/${BACKUP_FILE}.gz" | cut -f1)
    echo -e "${GREEN}✓ Backup compressed${NC}"
    echo "Compressed file: ${BACKUP_DIR}/${BACKUP_FILE}.gz"
    echo "Compressed size: ${COMPRESSED_SIZE}"
    
    # Optional: Keep only last N backups (uncomment and adjust as needed)
    # KEEP_BACKUPS=7
    # echo -e "${YELLOW}Cleaning old backups (keeping last ${KEEP_BACKUPS})...${NC}"
    # ls -t "${BACKUP_DIR}"/ramp_iiot_timescaledb_ALL_backup_*.sql.gz | tail -n +$((KEEP_BACKUPS + 1)) | xargs -r rm
    
    echo -e "${GREEN}✓ Backup process completed!${NC}"
    echo ""
    echo -e "${YELLOW}Note: To restore, use:${NC}"
    echo "gunzip -c ${BACKUP_DIR}/${BACKUP_FILE}.gz | docker exec -i ${CONTAINER_NAME} psql -U ${DB_USER} -d postgres"
    echo ""
    echo -e "${YELLOW}If restoration encounters constraint issues, use:${NC}"
    echo "gunzip -c ${BACKUP_DIR}/${BACKUP_FILE}.gz | docker exec -i ${CONTAINER_NAME} psql -U ${DB_USER} -d postgres -v ON_ERROR_STOP=0"
else
    echo -e "${RED}✗ Backup failed!${NC}"
    exit 1
fi


# gunzip -c ramp_iiot_timescaledb_ALL_backup_.sql.gz | docker exec -i ramp_iiot-timescale-db psql -U rampiot -d postgres