# Changes Maps on Clipboard ( 5 Maps in total ) 

var changeMaps = func{
  var mapCount = getprop("sim/model/config/map");
  var mapReset = 0;
  if (mapCount == 5) {
    setprop("sim/model/config/map", mapReset);
  }
  settimer(changeMaps, 0.4);
}

setlistener("sim/signals/fdm-initialized", changeMaps);
