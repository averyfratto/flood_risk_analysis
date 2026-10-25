
# Flood Risk Composite Score

To improve my open-source geospatial skills, I developed a flood risk scoring method, tested in on Wilwaukee, WI, and visualized my results using open-source tools and softwares. 

![Map screenshot](/Users/averyfratto/accelerator/PortfolioProject/part4/screenshot.tiff)
*[Screenshot from index.html]*

## The Guiding Question

What neighborhoods in Milwaukee are at higher risk of flood damage? 


## Method

I analyzed flood risk in Milwaukee using a PostgreSQL/PostGIS database, with Python (pandas, NumPy, GeoPandas, and Matplotlib) for scoring and exploratory mapping. The study area was divided into a grid of hexagonal cells in UTM Zone 16N (EPSG:32616), and building footprints from Overture Maps were assigned to cells using a representative point guaranteed to fall inside each footprint. Three indicators were calculated for each hexagon. For flood zone exposure, each building was joined to FEMA flood hzard data and scored 100 for the Special Flood Hazard Area, 50 for the 0.2% annual chance zone, 25 for undetermined zones, and 0 otherwise, and these scores were averaged by hexagon. For storm density, I counted storm events from 2022 to 2024 that intersect each hexagon. For water proximity, I measured the distance from each building to the nearest waterbody, scored buildings 100, 67, or 33 if they fell within 100, 200, or 500 meters, and averaged these scores by hexagon. Each indicator was rescaled from 0 to 100 using min-max normalization, so scores show relative rather than absolute risk. Hexagons with fewer than 5 buildings were excluded to avoid unstable averages. The composite risk score is a weighted sum of the three normalized scores (flood 50%, storm 10%, water 40%), rescaled again to 0 to 100, and hexagons were ranked from highest to lowest risk. For the web maps, I reprojected the results to WGS84 with GDAL’s ogr2ogr and converted them to a single PMTiles archive with Tippecanoe. The interactive maps were built with MapLibre GL JS and the PMTiles JavaScript library, over a CARTO Dark Matter basemap. Each map shades hexagons in five classes (0 to 20, 20 to 40, 40 to 60, 60 to 80, and 80 to 100) using ColorBrewer palettes: Blues for flood zone, Purples for storm density, GnBu for water proximity, and YlOrRd for composite risk. Users can hover to highlight a hexagon and click it to see the underlying values, such as building counts, the percentage of buildings in flood zones, and the risk rank.

## Data Sources

FEMA Flood Data: https://msc.fema.gov/portal/home<
NOAA Storm Events Database: https://www.ncei.noaa.gov/access/storm-events-database
Overture Buildings: https://docs.overturemaps.org/guides/buildings/
Overture Water: https://docs.overturemaps.org/schema/reference/base/water/


**Tools used:** DuckDB, GeoPandas, PostGIS, MapLibre GL JS, Streamlit, tippecanoe

## How to Run

```bash
# Clone the repository
git clone https://github.com/[YOUR_USERNAME]/[REPO_NAME].git
cd [REPO_NAME]

# Set up Python environment
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

# Run the analysis
jupyter lab analysis.ipynb
create_pmtiles.sh

# View the web map
python3 -m http.server 8080
# Open http://localhost:8080
```

## Project Structure

```
[flood_risk_analysis]/
├── README.md
├── requirements.txt
├── analysis.ipynb            <-- how I analyzed processed data (parquets) and created geojson and csv
├── extra_data.sql.           <-- how I analyzed initial raw data
├── create_pmtiles.sh         <-- how I converted geojson to pmtiles
├── data/
│   └── processed/            <-- Analysis outputs (GeoParquet, GeoJSON, pmtiles)
├── index.html            
└── images/
    └── map_screenshot.png    <-- For README
```

## What I Learned

The main focus of the project was practicing the full workflow of gathering data, analyzing it, and hosting results using open-source tools and methods. With that in mind, the actual composite score is somewhat simple. For future research, I'd like to develop something that can scale to other cities. 

For example, Milwaukee only had two storms in the 2022-2024 timeframe I used, so I adjusted its final weight to only 10% in the composite score. This would not apply to other cities. I've realized that good spatial analysis needs to be able to adapt weights and assumptions to the study area, without it being hardcoded. For my next project, I want the formula weights to adjust based on what variable shows to be the most indicative of flood danger in a city. 

To that same point, my methods used relative scoring. All scores are min-max normalized within the study area, so they show relative risk within Milwaukee and can’t be compared directly with scores from other regions- another weakness. 

Overall, my biggest takeaway is open-source geospatial tool are an incredibly efficient way to build and share analyses; however, scaling and replicating my script require more than just a public github repo, but deeper research behind the methods to make results relevant across time and space. 

---

