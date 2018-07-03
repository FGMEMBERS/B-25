

################ OIL TEMP CONVERSION #################

  setlistener("engines/engine/oil-temperature-degf", func(degf) {
        var degf = degf.getValue();
        var degc = (degf - 32) * (5 / 9);
        setprop("engines/engine/oil-temperature-degc", degc);
    });



  setlistener("engines/engine[1]/oil-temperature-degf", func(degf) {
        var degf = degf.getValue();
        var degc = (degf - 32) * (5 / 9);
        setprop("engines/engine[1]/oil-temperature-degc", degc);
    });




##############################################
############### ENGINE SYSTEM ################
##############################################

#Engine sensors class 
# ie: var Eng = Engine.new(engine number);
var Engine = {
    new : func(eng_num){
        m =               { parents : [Engine]};
        m.air_temp =      props.globals.initNode("environment/temperature-degc");
        m.oat =           m.air_temp.getValue() or 0;
        m.eng =           props.globals.getNode ("engines").getChild ("engine", eng_num);
        m.control =       props.globals.getNode ("controls/engines").getChild ("engine", eng_num);
        m.ot_target =     60;
        m.mp =            m.eng.initNode("mp-inhg");
        m.egt =           m.eng.initNode("egt-degf");
        m.cutoff =        m.control.initNode("cutoff");
        m.mixture =       m.eng.initNode("mixture");
        m.mixture_lever = m.control.initNode("mixture",1,"DOUBLE");
        m.rpm =           m.eng.initNode("rpm",1);
        m.oil_temp =      m.eng.initNode("oil-temp-c",m.oat,"DOUBLE");
        m.cyl_temp =      m.eng.initNode("cyl-temp",m.oat,"DOUBLE");
        m.carb_heat =     m.eng.initNode("carb-heat",0,"DOUBLE");
        m.carb_temp =     m.eng.initNode("carb-temp-degc",m.oat,"DOUBLE");
        m.oil_psi =       m.eng.initNode("oil-pressure-psi",0.0,"DOUBLE");
        m.fuel_psi =      m.eng.initNode("fuel-psi-norm",0,"DOUBLE");
        m.fuel_out =      m.eng.initNode("out-of-fuel",0,"BOOL");
        m.fuel_switch =   props.globals.initNode("controls/fuel/switch-position",-1,"INT");
        m.hpump =         props.globals.initNode("systems/hydraulics/pump-psi["~eng_num~"]",0,"DOUBLE");
        m.blower =        m.control.initNode ("boost", 1, "DOUBLE", 0.3);
  return m;
    },
#### update ####
    update : func () {
        var rpm =     me.rpm.getValue();
        var mp =      me.mp.getValue();
        var OT =      me.oil_temp.getValue();
        var mx =      me.mixture_lever.getValue();
        var ctemp =   me.air_temp.getValue();
        var cyltemp = me.cyl_temp.getValue();
        var cheat =   me.carb_heat.getValue();
        var cooling = (getprop("velocities/airspeed-kt") * 0.1) *2;

        ###################################
        ######### OIL TEMPERATURE #########
        ###################################
        cooling += (mx * 5);
        var tgt  = me.ot_target + mp;
        var tgt -= cooling;
        if(me.eng.getChild("running").getValue ()) {
          if(OT < tgt) OT += rpm * 0.00001;
          if(OT > tgt) OT -= cooling * 0.001;
          }else{
          if(OT > me.air_temp.getValue()) OT-=0.001; 
        }     
        me.oil_temp.setValue(OT);

        ###################################
        #### CYLINDER HEAD TEMPERATURE ####
        ###################################
        var thr = me.eng.getChild ("prop-thrust").getValue();
        var ct = me.cyl-temp.getValue();
        var cp = me.control.getChild ("cowl-flaps-norm").getValue ();
        var as = getprop("/velocities/airspeed-kt");
        var egt = (me.egt.getValue() - 32) * 0.55;
        var et0 = getprop("/environment/temperature-degc");
        var mp = me.mp.getValue();
        var mix = me.mixture_lever.getValue();
        var visc = me.eng.getChild ("oil-visc").getValue();
        var cbt = et0 + 0.85 * mp; #carb temperature
        var temp = 3.1 * cbt + 0.225 * rpm + 0.5 * egt - 0.0033 * as * as - 0.08 * thr * (1.28 * cp + 0.1) - 20 * mix; #cyl-head temperature
        interpolate(me.cyl-temp, temp * 0.4, 45);

        ###################################
        ############# MIXTURE #############
        ###################################
        me.mixture.setValue(mx);
    },

    shift_blower_up : func () {
       interpolate (me.blower, 1.0, 3);
    },

    shift_blower_down : func () {
       interpolate (me.blower, 0.7, 3);
    },

    toggle_blower : func () {
       print (me.eng.getPath () ~ ": blower position=" ~ me.blower.getValue());
       if (me.blower.getValue () < 0.8) { me.shift_blower_up (); }
       else { me.shift_blower_down (); }
    }
};

EngineLeft = Engine.new(0);
EngineRight = Engine.new(1);


###############################################

var update_system = func{
  EngineLeft.update(0);
  EngineRight.update(1);

    if(getprop("/engines/engine[0]/running")){
      setprop("/controls/engines/engine[0]/starter",0);
      setprop("/controls/engines/engine[0]/cranking",0);
    }


    if(getprop("/engines/engine[1]/running")){
      setprop("/controls/engines/engine[1]/starter",0);
      setprop("/controls/engines/engine[1]/cranking",0);
  }
}

var shift_blower_up = func {
  EngineLeft.shift_blower_up ();
  EngineRight.shift_blower_up ();
}

var shift_blower_dn = func {
  EngineLeft.shift_blower_down ();
  EngineRight.shift_blower_down ();
}
