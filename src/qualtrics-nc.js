var map;

var MAPBOX_TOKEN = "pk.eyJ1IjoiamFrZXJicm93biIsImEiOiJjbHhuYmdkNG8wMXZhMmxvcDl6d2szenNpIn0.OE5A8y5gw-dqEv1I1Eo6Ow";
var SPECIFICATION = "https://raw.githubusercontent.com/jakerbrown/legislator_map_repo/main/assets/north-carolina.json";

Qualtrics.SurveyEngine.addOnload(function() {
  this.disableNextButton();

  var zoomTo = Qualtrics.SurveyEngine.getEmbeddedData("start_zoom");
  if (zoomTo == null || zoomTo.trim() === "") zoomTo = 14;

  map = window.MapDraw("#ns__container", {
    token: MAPBOX_TOKEN,
    url: SPECIFICATION,
    errors: showError,
    zoomTo: zoomTo,
    allowProceed: (function(allow) {
      if (allow) this.enableNextButton();
      else this.disableNextButton();
    }).bind(this)
  });

  map.map.easeTo({center: [-79.2316, 35.3321], zoom: 11});


});






Qualtrics.SurveyEngine.addOnPageSubmit(function() {
  Qualtrics.SurveyEngine.setEmbeddedData("neighborhood", map.getNeighborhood());
});
