var map;

var MAPBOX_TOKEN = "pk.eyJ1IjoiamFrZXJicm93biIsImEiOiJjbHhuYmdkNG8wMXZhMmxvcDl6d2szenNpIn0.OE5A8y5gw-dqEv1I1Eo6Ow";
var BASE_URL = "https://raw.githubusercontent.com/jakerbrown/legislator_map_repo/main/assets/nc-blk-"
// var SPECIFICATION = "https://raw.githubusercontent.com/jakerbrown/legislator_map_repo/main/assets/north-carolina-vtd.json";
// var ADJACENCY = "https://raw.githubusercontent.com/jakerbrown/legislator_map_repo/main/assets/north-carolina-vtd_graph.json";

var zoomTo = Qualtrics.SurveyEngine.getEmbeddedData("start_zoom2");
    if (zoomTo == null || zoomTo.trim() == "") zoomTo = 14;

var CHAMBER = Qualtrics.SurveyEngine.getEmbeddedData("chamber")
    if (CHAMBER == null || CHAMBER.trim() == "") CHAMBER = "l";
  
var DISTRICT = Qualtrics.SurveyEngine.getEmbeddedData("district")
    if (DISTRICT == null || DISTRICT.trim() == "") DISTRICT = "063";
// var CENTROID_LON = -79.2316
// var CENTROID_LAT = 35.3321

Qualtrics.SurveyEngine.addOnload(function() {
    this.disableNextButton();
	
	
	
    map = window.MapDraw("#ns__container", {
        token: MAPBOX_TOKEN,
        url: BASE_URL + CHAMBER + "-" + DISTRICT + ".json",
		// graph: ADJACENCY,
		showOverlay: true, 
		 overlayRule: {
            "fill-color": "#030303", // Light grey color with 60% opacity
            "fill-opacity": .3 // Ensure fill-opacity matches the rgba opacity
        },
        errors: window.showError,
        		allowProceed: (function(allow) {
            if (allow) this.enableNextButton();
            else this.disableNextButton();
        }).bind(this),
        callback: function(map) {
		// map.map.setStyle('mapbox://styles/mapbox/light-v10'); // Set light grey style
          map.map.easeTo({zoom: zoomTo});
           map.enableMap();
			 // map.loadAddress("311 Glenwood Ave, Raleigh, NC")
        }

    });
});

Qualtrics.SurveyEngine.addOnPageSubmit(function() {
    Qualtrics.SurveyEngine.setEmbeddedData("neighborhood", map.getNeighborhood());
});