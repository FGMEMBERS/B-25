# Converts Knots to MPH 
var convertSpeed = func{
var speedKnots = getprop("instrumentation/airspeed-indicator/indicated-speed-kt");
var speedMPH = speedKnots * 1.15077945;
setprop("instrumentation/airspeed-indicator/indicated-speed-mph", speedMPH);

settimer(convertSpeed, 0.1);
}

setlistener("sim/signals/fdm-initialized", convertSpeed);

