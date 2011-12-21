[21~
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


################ TIRE SYSTEM #################

#tire rotation per minute by circumference/groundspeed#
TireSpeed = {
    new : func(number){
        m = { parents : [TireSpeed] };
            m.num=number;
            m.circumference=[];
            m.tire=[];
            m.rpm=[];
            for(var i=0; i<m.num; i+=1) {
                var diam =arg[i];
                var circ=diam * math.pi;
                append(m.circumference,circ);
                append(m.tire,props.globals.initNode("gear/gear["~i~"]/tire-rpm",0,"DOUBLE"));
                append(m.rpm,0);
            }
        m.count = 0;
        return m;
    },
    #### calculate and write rpm ###########
    get_rotation: func (fdm1){
        var speed=0;
        if(fdm1=="yasim"){ 
            speed =getprop("gear/gear["~me.count~"]/rollspeed-ms") or 0;
            speed=speed*60;
            }elsif(fdm1=="jsb"){
                speed =getprop("fdm/jsbsim/gear/unit["~me.count~"]/wheel-speed-fps") or 0;
                speed=speed*18.288;
            }
        var wow = getprop("gear/gear["~me.count~"]/wow");
        if(wow){
            me.rpm[me.count] = speed / me.circumference[me.count];
        }else{
            if(me.rpm[me.count] > 0) me.rpm[me.count]=me.rpm[me.count]*0.95;
        }
        me.tire[me.count].setValue(me.rpm[me.count]);
        me.count+=1;
        if(me.count>=me.num)me.count=0;
    },
};

#var tire=TireSpeed.new(# of gear,diam[0],diam[1],diam[2], ...);
var tire=TireSpeed.new(3, 1.143, 1.143, 0.560);


############### ENGINE SYSTEM ################


#Engine sensors class 
# ie: var Eng = Engine.new(engine number);
var Engine = {
    new : func(eng_num){
        m =               { parents : [Engine]};
	m.air_temp =      props.globals.initNode("environment/temperature-degc");
	m.oat =           m.air_temp.getValue() or 0;
        m.eng =           props.globals.initNode("engines/engine["~eng_num~"]");
        m.running =       0;
        m.ot_target =     60;
	m.mp =            m.eng.initNode("mp-inhg");
        m.cutoff =        props.globals.initNode("controls/engines/engine["~eng_num~"]/cutoff");
        m.mixture =       props.globals.initNode("engines/engine["~eng_num~"]/mixture");
        m.mixture_lever = props.globals.initNode("controls/engines/engine["~eng_num~"]/mixture",1,"DOUBLE");
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
	m.Lrunning =      setlistener("engines/engine["~eng_num~"]/running",func (rn){m.running=rn.getValue()},0,0);
	return m;
    },
#### update ####
    update : func(eng_num){
        var rpm =     me.rpm.getValue();
	var mp =      me.mp.getValue();
	var OT =      me.oil_temp.getValue();
        var mx =      me.mixture_lever.getValue();
	var ctemp =   me.air_temp.getValue();
        var cyltemp = me.cyl_temp.getValue();
        var cheat =   me.carb_heat.getValue();
	var cooling =    (getprop("velocities/airspeed-kt") * 0.1) *2;

        ######### OIL TEMPERATURE #########

	cooling += (mx * 5);
	var tgt  = me.ot_target + mp;
	var tgt -= cooling;
	if(me.running){
		if(OT < tgt) OT += rpm * 0.00001;
		if(OT > tgt) OT -= cooling * 0.001;
		}else{
		if(OT > me.air_temp.getValue()) OT-=0.001; 
	}
        me.oil_temp.setValue(OT);
       
        #### CYLINDER HEAT TEMPERATURE ####
   	var thr = getprop("/engines/engine["~eng_num~"]/prop-thrust");
	var ct = getprop("/engines/engine["~eng_num~"]/cyl-temp");
	var cp = getprop("/controls/engines/engine["~eng_num~"]/cowl-flaps-norm");
	var as = getprop("/velocities/airspeed-kt");
	var egt = (getprop("/engines/engine["~eng_num~"]/egt-degf") - 32) * 0.55;
	var et0 = getprop("/environment/temperature-degc");
	var mp = getprop("/engines/engine["~eng_num~"]/mp-osi");
	var mix = getprop("/controls/engines/engine["~eng_num~"]/mixture");
	var visc = getprop("/engines/engine["~eng_num~"]/oil-visc");
	var cbt = et0 + 0.85 * mp; #carb temperature
	var temp = 3.1 * cbt + 0.225 * rpm + 0.5 * egt - 0.0033 * as * as - 0.08 * thr * (1.28 * cp + 0.1) - 20 * mix; #cyl-head temperature
	interpolate("/engines/engine["~eng_num~"]/cyl-temp", temp * 0.4, 45);
       
        ##### CARBURATOR TEMPERATURE ######
      
        if(props.globals.getNode("systems/electrical/outputs/carb-heat").getValue() > 8){
          cheat += 0.01;
          if(cheat > 40) cheat = 40;
          setprop("engines/engine["~eng_num~"]/carb-heat", cheat);
          cbt += cheat;
        }else{
          cheat -= 0.05;
          if(cheat < 0) cheat = 0;
          setprop("engines/engine["~eng_num~"]/carb-heat", cheat);
          cbt += cheat;
        }
	ctemp = rpm * 0.007;
	me.carb_temp.setValue(et0 - ctemp + cheat);

