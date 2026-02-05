#!/bin/bash
set -e

DATA_DIR="${DATA_DIR:-/var/www/html/data}"
CONVERTER_JAR="/opt/emailconverter.jar"
LOG_PREFIX="[eml-converter]"

log() {
    echo "$LOG_PREFIX $(date '+%Y-%m-%d %H:%M:%S') $1"
}

convert_eml() {
    local eml_file="$1"
    local pdf_file="${eml_file%.eml}.pdf"
    
    # Skip if PDF already exists
    if [ -f "$pdf_file" ]; then
        log "PDF already exists, skipping: $pdf_file"
        return 0
    fi
    
    log "Converting: $eml_file"
    
    if java -jar "$CONVERTER_JAR" -o "$pdf_file" "$eml_file" 2>&1; then
        log "Success: $pdf_file"
    else
        log "Error converting: $eml_file"
        return 1
    fi
}

# Convert existing EML files on startup
log "Scanning for existing .eml files in $DATA_DIR..."
find "$DATA_DIR" -name "*.eml" -type f 2>/dev/null | while read -r eml; do
    convert_eml "$eml" || true
done
log "Initial scan complete."

# Watch for new EML files
log "Watching for new .eml files..."
inotifywait -m -r -e create -e moved_to --format '%w%f' "$DATA_DIR" 2>/dev/null | while read -r file; do
    if [[ "$file" == *.eml ]]; then
        # Small delay to ensure file is fully written
        sleep 1
        convert_eml "$file" || true
    fi
done
