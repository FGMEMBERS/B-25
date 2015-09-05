var sbc1 = aircraft.light.new( "/sim/model/lights/sbc1", [0.5, 0.3] );
sbc1.interval = 0.1;
sbc1.switch( 1 );

var sbc2 = aircraft.light.new( "/sim/model/lights/sbc2", [0.2, 0.3], "/sim/model/lights/sbc1/state" );
sbc2.interval = 0;
sbc2.switch( 1 );

setlistener( "/sim/model/lights/sbc2/state", func(n) {
  var bsbc1 = sbc1.stateN.getValue();
  var bsbc2 = n.getBoolValue();
  var b = 0;
  if( bsbc1 and bsbc2 and getprop( "/controls/lighting/beacon") ) {
    b = 1;
  } else {
    b = 0;
  }
  setprop( "/sim/model/lights/beacon/enabled", b );

  if( bsbc1 and !bsbc2 and getprop( "/controls/lighting/strobe" ) ) {
    b = 1;
  } else {
    b = 0;
  }
  setprop( "/sim/model/lights/strobe/enabled", b );
});

var beacon_switch = props.globals.getNode("controls/switches/beacon", 2);
var beacon = aircraft.light.new( "/sim/model/lights/beacon", [0, 3], "/controls/lighting/beacon" );

var strobe_switch = props.globals.getNode("controls/switches/strobe", 2);
var strobe = aircraft.light.new( "/sim/model/lights/strobe", [0.05, 0.05, 0.05, 1] );

#############################################################################################################################
var landingLightL = aircraft.light.new("/sim/model/lights/landing[0]", [0], "/controls/lighting/landing-lights");
var landingLightR = aircraft.light.new("/sim/model/lights/landing[1]", [0], "/controls/lighting/landing-lights[1]");

var passingLight = aircraft.light.new("/sim/model/lights/passing", [0.04, 0.7, 0.5, 2], "/controls/lighting/passing-lights");
var tailLight = aircraft.light.new("/sim/model/lights/tail", [0], "/controls/lighting/tail-lights");
var navLight = aircraft.light.new("/sim/model/lights/running", [0], "/controls/lighting/running-lights");

var recognition1 = aircraft.light.new("/sim/model/lights/recognition[0]", [0], "/controls/lighting/recognition-lights");
var recognition2 = aircraft.light.new("/sim/model/lights/recognition[1]", [0], "/controls/lighting/recognition-lights[1]");
var recognition3 = aircraft.light.new("/sim/model/lights/recognition[2]", [0], "/controls/lighting/recognition-lights[2]");

var formationLight = aircraft.light.new("/sim/model/lights/formation", [0], "/controls/lighting/formation-lights");
#############################################################################################################################
