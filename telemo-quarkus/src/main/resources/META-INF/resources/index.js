console.log("Welcome to Telemetry Demo!")

const decay_interval = 10 * 1000;
const palette = [
  "#f94144",
  "#f3722c",
  "#f8961e",
  "#f9844a",
  "#f9c74f",
  "#90be6d",
  "#43aa8b",
  "#4d908e",
  "#577590",
  "#277da1",
]

function randomColor(){
  const r = Math.floor(Math.random() * palette.length);
  return palette[r];
}

function randomUUID() {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
  });
}

function decrementBattery(){
  batteryLevel -= 1;
  texttip.setContent(batteryLevel + "");
}

function changeColor(){
  c_fill = randomColor();
  circle.setStyle({
    fillColor: c_fill
  });
}

function geoFindMe() {
    function circleClick(){
      changeColor();
      decrementBattery();
      sendTelemetry();
    }

    function success(position) {
      lat  = position.coords.latitude;
      lng = position.coords.longitude;

      mymap.setView([lat, lng], zoom);

      circle = L.circle([lat, lng], {
        color: c_color,
        fillColor: c_fill,
        fillOpacity: c_opacity,
        radius: c_radius
      }).addTo(mymap);

      texttip = L.tooltip({
        permanent: true,
        direction: 'center',
        className: 'text'
      })
      .setLatLng([lat,lng])
      .setContent(batteryLevel + "");
      texttip.addTo(mymap);

      circle.on("click", circleClick);
      sendTelemetry();
    }

    function error() {
      console.log('Unable to retrieve your location');
    }

  if(!navigator.geolocation) {
    console.log('Geolocation is not supported by your browser');
  } else {
    navigator.geolocation.getCurrentPosition(success, error);
  }
}

var sourceUUID = randomUUID();
var lat = -18.9083297;
var lng =  -48.226165762;
var zoom = 13;
var batteryLevel = 99;

var circle = null;
var c_color = 'white';
var c_fill = randomColor();
var c_opacity = 0.5;
var c_radius = 500;

var texttip = null;

var mymap = L.map('mapid');
mymap.setView([lat, lng], zoom);

L.tileLayer('https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}', {
  attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, Imagery © <a href="https://www.mapbox.com/">Mapbox</a>',
  maxZoom: 18,
  id: 'mapbox/streets-v11',
  tileSize: 512,
  zoomOffset: -1,
  accessToken: 'pk.eyJ1IjoiZmFlcm1hbmoiLCJhIjoiY2tubHZobWU4MGo1bDJucHJteXk4aThnZiJ9.mOUIu1AM41cYiLSkRhJMIg'
}).addTo(mymap);

function sendTelemetry(){
  console.log("Sending telemetry");
  var xmlHttp = new XMLHttpRequest();
  xmlHttp.onreadystatechange = function() {
    if(xmlHttp.readyState == 4 && xmlHttp.status == 200)
    {
      console.log(xmlHttp.responseText);
    }
  }
  xmlHttp.open("post", "/api/hb", true);
  xmlHttp.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
  var state = {
    "sourceUUID": sourceUUID,
    "lat": lat,
    "lng": lng,
    "createTime": new Date().toISOString(),
    "displayColor": c_fill,
    "batteryLevel": batteryLevel}
  xmlHttp.send(JSON.stringify(state));
}

(function main(){
  geoFindMe();

  setInterval(function (){
    decrementBattery();
  }, decay_interval);

  setInterval(sendTelemetry, decay_interval / 2);
})();
