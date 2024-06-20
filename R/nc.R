library(tidycensus)
library(tidyverse)
library(vroom)
library(sf)
library(spdep)
library(jsonlite)
library(mapboxapi)
TILESET_ID = "north-carolina"

# Jake's mapbox info
MAPBOX_SECRET_TOKEN = read_file('~/Desktop/Docs/MAPBOX_SECRET_KEY.txt')
MAPBOX_USERNAME = "jakerbrown"

# Jake's census api key
census_api_key("880acd38892508a49cdddab4206d05c32ed8dee6", overwrite = FALSE, install = FALSE)



# Census variables you wish to include in the tileset
# I think these variables are only for overlaying, so we don't really need them, but
# get_decennial requires calling at least one variable to get the geometries
vars = c(pop="P1_001N"
         #, pop_white="P001005", pop_black="P001006",
         #pop_hisp="P001002"
         )

d = get_decennial(geography = "tract", variables=vars, state="NC",
                  output="wide", geometry=T, year = 2020)

# remove empty geometries
d = d[!st_is_empty(d),]

cat("Census data downloaded.\n")





state_fips = unique(str_sub(d$GEOID, 1, 2))


# make graph
{
g = poly2nb(d, queen=F)
ids = str_sub(d$GEOID, 6)
class(g) = "list"
names(g) = ids
g = map(g, ~ ids[.])

write_json(g, paste0("assets/", TILESET_ID, "_graph.json"))
}
cat("Adjacency graph created.\n")


mbtile_name = paste0("R/data/", TILESET_ID, ".mbtiles")
d %>%
    mutate(GEOID = str_sub(GEOID, 4)) %>%
tippecanoe(mbtile_name,
          # output = glue('~/Research_Group Dropbox/Jacob Brown/legislator_maps/{mbtile_name}'),
           layer_name="tracts",
           min_zoom=10, # will need to mess around with this to find right starting point
          max_zoom=12, # will need to mess around with this
           other_options="--coalesce-densest-as-needed --detect-shared-borders")
cat("Vector tiles created.\n")


upload_tiles(input=mbtile_name, access_token=MAPBOX_SECRET_TOKEN,
             username=MAPBOX_USERNAME, tileset_id=TILESET_ID,
             tileset_name=paste0(TILESET_ID, "_z10_z12"), multipart=TRUE)
cat("Tileset uploaded.\n")

spec = read_json("assets/boston.json", simplifyVector=T) # copy boston json and swap out lat lon bounds for our state
spec$units$bounds = matrix(st_bbox(d), nrow=2, byrow=T)
spec$units$tileset$source$url = str_glue("mapbox://{MAPBOX_USERNAME}.{TILESET_ID}")
write_json(spec, paste0("assets/", TILESET_ID, ".json"), auto_unbox=T)
cat("Specification written.\n")
