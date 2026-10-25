# Portfolio README Template

Use this template for the README.md of your capstone project repository. Replace all `[bracketed]` text with your own content.

---

# [Project Title]

[One-sentence description of what this project does and why it matters.]

![Map screenshot](images/map_screenshot.png)
*[Caption describing what the map shows.]*

## The Question

[What spatial question does this project answer? Write it as a plain-English question that a non-technical person would understand.]

**Example:** "Which neighborhoods in Portland have the fewest transit options relative to their population density?"

## Key Findings

- [Finding 1 — the most important or surprising result]
- [Finding 2 — a supporting result with a specific number]
- [Finding 3 — a practical implication or recommendation]

## Data Sources

| Dataset | Source | Records | Format |
|---------|--------|---------|--------|
| [Dataset 1] | [Source name + link] | [count] | [GeoJSON/Parquet/etc.] |
| [Dataset 2] | [Source name + link] | [count] | [format] |
| [Dataset 3] | [Source name + link] | [count] | [format] |

## Methods

1. **Data acquisition** — [How you got the data: Overture S3, NYC Open Data API, Census download, etc.]
2. **Spatial analysis** — [What spatial operations you performed: buffer, spatial join, density calculation, etc.]
3. **Visualization** — [How you presented results: MapLibre choropleth, Streamlit dashboard, static maps, etc.]

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
jupyter lab notebooks/analysis.ipynb

# View the web map
cd web
python3 -m http.server 8080
# Open http://localhost:8080
```

## Project Structure

```
[repo-name]/
├── README.md
├── requirements.txt
├── notebooks/
│   └── analysis.ipynb        ← Main analysis notebook
├── data/
│   ├── raw/                  ← Downloaded source data
│   └── processed/            ← Analysis outputs (GeoParquet, GeoJSON)
├── web/
│   ├── index.html            ← MapLibre web map
│   └── data.pmtiles          ← Vector tiles
└── images/
    └── map_screenshot.png    ← For README and portfolio
```

## What I Learned

[2–3 sentences about what was new or challenging. Be specific — "I learned that spatial joins on 100K+ points require a spatial index" is better than "I learned about databases."]

---

*Built during the [Modern GIS Accelerator](https://example.com) course.*
