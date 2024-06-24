var map;

var MAPBOX_TOKEN = "pk.eyJ1IjoiamFrZXJicm93biIsImEiOiJjbHhuYmdkNG8wMXZhMmxvcDl6d2szenNpIn0.OE5A8y5gw-dqEv1I1Eo6Ow";
var SPECIFICATION = "https://raw.githubusercontent.com/jakerbrown/legislator_map_repo/main/assets/north-carolina.json";
var zoomTo = Qualtrics.SurveyEngine.getEmbeddedData("start_zoom");
    if (zoomTo == null || zoomTo.trim() == "") zoomTo = 6;

var CENTROID_LON = -79.2316
var CENTROID_LAT = 35.3321

Qualtrics.SurveyEngine.addOnload(function() {
    this.disableNextButton();



    map = window.MapDraw("#ns__container", {
        token: MAPBOX_TOKEN,
        url: SPECIFICATION,
        errors: showError,
        allowProceed: (function(allow) {
            if (allow) this.enableNextButton();
            else this.disableNextButton();
        }).bind(this),
        callback: function(map) {
            map.map.easeTo({center: [CENTROID_LON, CENTROID_LAT], zoom: zoomTo});
            map.enableMap();
        }
    });
});

Qualtrics.SurveyEngine.addOnPageSubmit(function() {
    Qualtrics.SurveyEngine.setEmbeddedData("neighborhood", map.getNeighborhood());
});
