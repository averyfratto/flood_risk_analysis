#!/usr/bin/env bash
# create_pmtiles.sh
# ---------------------------------------------------------------------------
# Converts the Milwaukee environmental risk GeoJSON into a PMTiles file
# for use with MapLibre GL JS.
#
# PMTiles is a single-file archive of vector tiles — no tile server needed.
# The browser fetches only the tiles it needs using HTTP range requests.
#
# Input:   PortfolioProject/part4/environmental_risk_analysis/data/processed/milwaukee_risk_by_area.geojson
#          (EPSG:32616 polygons with risk score attributes)
#
# Output:  milwaukee_risk.pmtiles
#
# Prerequisites:
#   - tippecanoe installed (tippecanoe --version to check)
#     macOS:   brew install tippecanoe
#     Ubuntu:  see https://github.com/felt/tippecanoe#installation
#   - GDAL's ogr2ogr installed (ogr2ogr --version to check)
#     macOS:   brew install gdal
#     Ubuntu:  sudo apt install gdal-bin
#
# Usage:   bash create_pmtiles.sh
# ---------------------------------------------------------------------------

set -e

GEOJSON_INPUT="/Users/averyfratto/accelerator/PortfolioProject/part4/environmental_risk_analysis/data/processed/milwaukee_risk_by_area.geojson"
REPROJECTED="milwaukee_risk_wgs84.geojson"
OUTPUT="data/processed/milwaukee_risk.pmtiles"

# Clean up the temporary reprojected file on exit (success or failure)
trap 'rm -f "$REPROJECTED"' EXIT

# --- Check prerequisites --------------------------------------------------
if ! command -v tippecanoe &> /dev/null; then
    echo "❌ tippecanoe is not installed."
    echo ""
    echo "Install it:"
    echo "  macOS:  brew install tippecanoe"
    echo "  Ubuntu: git clone https://github.com/felt/tippecanoe.git && cd tippecanoe && make -j && sudo make install"
    echo "  Docker: docker run -v \$(pwd):/data ghcr.io/felt/tippecanoe:latest tippecanoe ..."
    exit 1
fi

if ! command -v ogr2ogr &> /dev/null; then
    echo "❌ ogr2ogr (GDAL) is not installed."
    echo ""
    echo "Install it:"
    echo "  macOS:  brew install gdal"
    echo "  Ubuntu: sudo apt install gdal-bin"
    exit 1
fi

# --- Check input file -----------------------------------------------------
if [ ! -f "$GEOJSON_INPUT" ]; then
    echo "❌ Input file not found: $GEOJSON_INPUT"
    echo "   Make sure the risk analysis ran and exported the GeoJSON."
    echo "   Expected: $GEOJSON_INPUT"
    exit 1
fi

echo "📁 Input:  $GEOJSON_INPUT"
echo "📦 Output: $OUTPUT"
echo ""

# --- Reproject EPSG:32616 → EPSG:4326 ---------------------------------------
# Tippecanoe requires WGS84 lon/lat. The source file is in UTM 16N (meters),
# and tippecanoe ignores the GeoJSON "crs" member, so we must reproject first.
# All attribute columns are carried over unchanged.
echo "🧭 Reprojecting EPSG:32616 → EPSG:4326..."
ogr2ogr \
    -f GeoJSON \
    -s_srs EPSG:32616 \
    -t_srs EPSG:4326 \
    -lco RFC7946=YES \
    "$REPROJECTED" \
    "$GEOJSON_INPUT"

# --- Convert to PMTiles ---------------------------------------------------
echo "🔄 Running tippecanoe..."
# -z12         → max zoom level 12 (neighborhood-level detail)
# -Z8          → min zoom level 8 (don't show at world/country scale)
# --no-feature-limit  → include all features per tile
# --no-tile-size-limit → don't drop features to shrink tiles
# -l           → layer name inside the tileset (referenced in MapLibre style)
# -o           → output file
# --force      → overwrite if output already exists
#
# All properties are kept by default (area_id, n_buildings, pct_sfha,
# pct_shaded_x, flood_zone_score, storm_events, storm_density_score,
# bldgs_within_100m/200m/500m, pct_within_500m, water_proximity_score,
# risk_score, risk_rank).
#
# NOTE: --coalesce-densest-as-needed from the original template is omitted.
# It can merge neighboring features at low zooms, which would blur the
# per-area attributes. Since every feature has unique risk values and
# the tile size limit is disabled, we don't need it here.

tippecanoe \
    -z12 \
    -Z8 \
    --no-feature-limit \
    --no-tile-size-limit \
    -l milwaukee_risk \
    -o "$OUTPUT" \
    --force \
    "$REPROJECTED"

# --- Verify ---------------------------------------------------------------
echo ""
FILE_SIZE=$(wc -c < "$OUTPUT" | tr -d ' ')
echo "✅ Created $OUTPUT ($FILE_SIZE bytes)"
