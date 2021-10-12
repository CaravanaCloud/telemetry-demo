var mymap = null;
var markers = null;


function setHTML(id,val){
  document.getElementById(id).innerHTML = val;
}

function draw(data){
  setHTML("count_heartbeats",data["count_heartbeats"]);
  setHTML("count_sources",data["count_sources"]);
  setHTML("min_battery",data["min_battery"]);
}

function markEach(hb){
  console.log(hb);
  var marker = L.marker([hb.lat, hb.lng]);
  var text = "<p>";
  text += hb["sourceUUID"] + "<br/>";
  text += "<div style='color: "+hb["displayColor"]+"'> 🔋 "+hb["batteryLevel"] + " %</div>";
  text += "<div><textarea style='width: 100%;'></textarea></div>";
  text += "<div><input type='button' value='email'></input></div>";
  text += "</p>";
  marker.bindPopup(text);
  markers.addLayer(marker);
}

function mark(data){
  markers.clearLayers();
  data.forEach(markEach);
}

function refresh(){
  fetch('/api/hb/stats')
    .then(response => response.json())
    .then(data => draw(data));

  fetch("/api/hb/latest")
    .then(response => response.json())
    .then(data => mark(data));
}

(function main(){
  var lat = 14.7167;
  var lng =  17.4677;
  var zoom = 2;

  mymap = L.map('mapid');
  mymap.setView([lat, lng], zoom);

  L.tileLayer('https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}', {
    attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, Imagery © <a href="https://www.mapbox.com/">Mapbox</a>',
    maxZoom: 18,
    id: 'mapbox/streets-v11',
    tileSize: 512,
    zoomOffset: -1,
    accessToken: 'pk.eyJ1IjoiZmFlcm1hbmoiLCJhIjoiY2tubHZobWU4MGo1bDJucHJteXk4aThnZiJ9.mOUIu1AM41cYiLSkRhJMIg'
  }).addTo(mymap);

  markers = L.markerClusterGroup();
  mymap.addLayer(markers);

  setInterval(refresh,5000);
  refresh();
  console.log("Main Done")
})();

