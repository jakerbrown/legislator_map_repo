rm(list=ls())
gc()

library(tidycensus)
library(tidyverse)
library(vroom)
library(sf)
library(spdep)
library(jsonlite)
library(mapboxapi)
library(glue)


###
library(here)
library(cli)
library(fs)

# alarm project ----
library(geomander)
library(censable)
library(PL94171)
library(redist)
library(redistmetrics)
library(divseg)
# library(ggredist)

# other data ----
library(tigris)
library(tinytiger)



###

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

# vtds = get_decennial(geography = "voting district", variables=vars, state="NC",
#                   output="wide", geometry=T, year = 2020)


blocks = get_decennial(geography = "block", variables=vars, state="NC",
                     output="wide", geometry=T, year = 2020)


#baf::baf('NC', year = 2024, geographies = 'ssd') # upper
#baf::baf('NC', year = 2024, geographies = 'shd') # lower

baf <- baf::baf('NC', year = 2022, geographies = 'ssd')$SSD2022
  # switch to 2024 after nov. election
 


# remove empty geometries
blocks = blocks[!st_is_empty(blocks),]
gc()
cat("Census data downloaded.\n")





state_fips = unique(str_sub(blocks$GEOID, 1, 2))

REPLACE = F
for(dist in unique(baf$SLDUST)){
if(!file.exists(glue('assets/nc-blk-u-{dist}.json')) | REPLACE){
  TILESET_ID = glue("nc-blk-u-{dist}")
  
  d <- blocks |> 
    filter(GEOID %in% baf$GEOID[baf$SLDUST==dist])
  
# # make graph
# {
# g = poly2nb(d, queen=F)
# ids = d$GEOID
# class(g) = "list"
# names(g) = ids
# g = map(g, ~ ids[.])
# 
# write_json(g, paste0("assets/", TILESET_ID, "_graph.json"))
# }
# cat("Adjacency graph created.\n")


mbtile_name = paste0("R/data/", TILESET_ID, ".mbtiles")
d %>%
   # mutate(pop = 1) %>%
tippecanoe(mbtile_name,
          # output = glue('~/Research_Group Dropbox/Jacob Brown/legislator_maps/{mbtile_name}'),
           layer_name="blocks",
           min_zoom=0,
          max_zoom=12,
           other_options="--coalesce-densest-as-needed --detect-shared-borders")
cat("Vector tiles created.\n")


upload_tiles(input=mbtile_name, access_token=MAPBOX_SECRET_TOKEN,
             username=MAPBOX_USERNAME, tileset_id=TILESET_ID,
             tileset_name=paste0(TILESET_ID), multipart=TRUE)
cat("Tileset uploaded.\n")

spec = read_json("assets/boston.json", simplifyVector=T) # copy template json and swap out lat lon bounds for our state
spec$units$bounds = matrix(st_bbox(d), nrow=2, byrow=T)
spec$units$tileset$source$url = str_glue("mapbox://{MAPBOX_USERNAME}.{TILESET_ID}")
write_json(spec, paste0("assets/", TILESET_ID, ".json"), auto_unbox=T)
cat("Specification written.\n")

}
}
