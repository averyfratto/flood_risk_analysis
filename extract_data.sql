-- Environmental Risk: data extraction (DuckDB)
-- ---------------------------------------------------------------------------
-- Target city: Milwaukee, WI
-- BBOX (xmin, ymin, xmax, ymax): -87.927704, 43.024730, -87.876635, 43.056158
--
-- The bbox filter uses an INTERSECTS test (not "min corner inside the box"),
-- so large features that start west/south of the box (e.g. Lake Michigan,
-- big parcels) are included.
-- ---------------------------------------------------------------------------

INSTALL spatial;
INSTALL httpfs;
LOAD spatial;
LOAD httpfs;
SET s3_region = 'us-west-2';


-- === 1. Buildings =========================================================

COPY (
    SELECT
        id,
        names.primary AS name,
        class,
        subtype,
        height,
        num_floors,
        geometry
    FROM read_parquet(
        's3://overturemaps-us-west-2/release/2026-09-23.1/theme=buildings/type=building/*',
        hive_partitioning=true
    )
    WHERE bbox.xmin <= -87.876635
      AND bbox.xmax >= -87.927704
      AND bbox.ymin <= 43.056158
      AND bbox.ymax >= 43.024730
) TO 'data/processed/Milwaukee_buildings.parquet' WITH (FORMAT PARQUET);



-- === 2. Water bodies ======================================================

COPY (
    SELECT
        id,
        names.primary AS name,
        class,
        geometry
    FROM read_parquet(
        's3://overturemaps-us-west-2/release/2026-09-23.1/theme=base/type=water/*',
        hive_partitioning=true
    )
    WHERE bbox.xmin <= -87.876635
      AND bbox.xmax >= -87.927704
      AND bbox.ymin <= 43.056158
      AND bbox.ymax >= 43.024730
) TO 'data/processed/Milwaukee_water.parquet' WITH (FORMAT PARQUET);


-- === 3. Land use ==========================================================

COPY (
    SELECT
        id,
        names.primary AS name,
        class,
        subtype,
        geometry
    FROM read_parquet(
        's3://overturemaps-us-west-2/release/2026-09-23.1/theme=base/type=land_use/*',
        hive_partitioning=true
    )
    WHERE bbox.xmin <= -87.876635
      AND bbox.xmax >= -87.927704
      AND bbox.ymin <= 43.056158
      AND bbox.ymax >= 43.024730
) TO 'data/processed/Milwaukee_land_use.parquet' WITH (FORMAT PARQUET);


-- === 4. NOAA Storm Events (Wisconsin, 2022-2024, inside the bbox) ===========
-- Assumes the GeoParquet files have a `geometry` column and a STATE column.
-- These files probably have no `bbox` column, so filter on geometry instead.

COPY (
    SELECT *
    FROM read_parquet(
        ['data/raw/storm_events_2022.parquet',
         'data/raw/storm_events_2023.parquet',
         'data/raw/storm_events_2024.parquet'],
        union_by_name=true
    )
    WHERE STATE = 'WISCONSIN'
      AND ST_Intersects(
            geometry,
            ST_MakeEnvelope(-87.927704, 43.024730, -87.876635, 43.056158)
          )
) TO 'data/processed/Milwaukee_storms.parquet' WITH (FORMAT PARQUET);


-- === 5. Storm event summary ===============================================

SELECT
    EVENT_TYPE,
    COUNT(*) AS event_count,
    SUM(INJURIES_DIRECT) AS total_injuries,
    SUM(DEATHS_DIRECT) AS total_deaths
FROM read_parquet('data/processed/Milwaukee_storms.parquet')
GROUP BY EVENT_TYPE
ORDER BY event_count DESC;


