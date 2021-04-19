function setHTML(id,val){
  document.getElementById(id).innerHTML = val;
}

function draw(data){
  setHTML("count_heartbeats",data["count_heartbeats"]);
  setHTML("count_sources",data["count_sources"]);
  setHTML("min_battery",data["min_battery"]);
}

function refresh(){
  fetch('/api/hb/stats')
    .then(response => response.json())
    .then(data => draw(data));
}

setInterval(refresh,5000);
refresh();