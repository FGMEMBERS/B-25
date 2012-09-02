####################### boost  #####################
var blower0 = getprop("controls/engines/engine[0]/boost");
var blower1 = getprop("controls/engines/engine[1]/boost");

var shift_blower_up = func {
	if (blower0 <= 0.7){
      setprop("/controls/engines/engine[0]/boost", 1);
	}
}

var shift_blower_dn = func {
	if (blower0 >= 1.0){
      setprop("/controls/engines/engine[0]/boost", 0.7);
	}
}

var shift_blower_up = func {
	if (blower1 <= 0.7){
      setprop("/controls/engines/engine[1]/boost", 1);
	}
}

var shift_blower_dn = func {
	if (blower1 >= 1.0){
      setprop("/controls/engines/engine[1]/boost", 0.7);
	}
}


