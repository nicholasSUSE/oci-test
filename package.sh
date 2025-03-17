#!/bin/bash

# Define source and destination directories
CHARTS_DIR="charts"
DEST_DIR="assets"
INDEX_FILE="index.yaml"
BASE_URL="assets"  # Replace with your actual base URL

#rm -r "$DEST_DIR"
# Ensure the assets directory exists
#mkdir -p "$DEST_DIR"

# Loop over all charts in the directory
for chart in "$CHARTS_DIR"/*/*; do
    if [ -d "$chart" ]; then 
        if [[ $chart != *"rancher-logging"* ]]; then
            continue
        fi
        
        # Extract chart name from the directory structure: charts/{helmchartname}/{version}/
        CHART_NAME=$(basename "$(dirname "$chart")")
        VERSION=$(basename "$chart")

        if [[ "$(printf "%s\n%s" "105.2.1+up4.10.0" "$VERSION" | sort -V | head -n1)" != "105.2.1+up4.10.0" ]]; then
            continue
        fi

        echo $CHART_NAME
        echo $VERSION
        
        # Create destination subdirectory
        CHART_DEST="$DEST_DIR/$CHART_NAME"
        mkdir -p "$CHART_DEST"

        echo "Packaging chart: $chart -> $CHART_DEST"
        helm package "$chart" -d "$CHART_DEST"
    fi
done

# Generate a global index.yaml at the same level as charts/ and assets/
helm repo index "$DEST_DIR" --url "$BASE_URL" --merge "$INDEX_FILE"
mv "$DEST_DIR/index.yaml" "$INDEX_FILE"

echo "All Helm charts packaged, and global index.yaml updated at $(pwd)/$INDEX_FILE!"