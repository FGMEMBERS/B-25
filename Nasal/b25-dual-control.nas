# Dual control for the B-25J
# Copyright (c) 2019 Ludovic Brenta <ludovic@ludovic-brenta.org>
# Based on the dual control tools for FlightGear, by Anders Gidenstam.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

######################################################################
# Unlike some other aircraft, this dual control does not support a
# pilot and a copilot, a situation that I find uninteresting.
# Instead, it supports a pilot and a turret gunner.

var DCT = dual_control_tools;

## Pilot/copilot aircraft identifiers. Used by dual_control.
var pilot_type   = "Aircraft/B-25/Models/b25.xml";
var copilot_type = "Aircraft/B-25/Models/turret-gunner.xml";
var connected = 0;

pilot_connect_copilot = func (copilot) {
    connected = 1;
    return [
      DCT.Translator.new (copilot.getNode ("sim/multiplay/generic/float[14]"),
                          props.globals.getNode ("sim/model/turret[0]/heading")),
      DCT.Translator.new (copilot.getNode ("sim/multiplay/generic/float[15]"),
                          props.globals.getNode ("sim/model/turret[0]/pitch"))
    ];
}

pilot_disconnect_copilot = func () {
  connected = 0;
}

generic = props.globals.getNode ("sim/multiplay/generic");

copilot_connect_pilot = func (pilot) {
    connected = 1;
    turrets.Dorsal_Turret.init();
    # because this is normally called when the FDM is initialized but the turret gunner doesn't have an FDM
    turrets.Dorsal_Turret.update();
    # because this is normally called when we change views but the turret gunner doesn't normally change views
    # The result doesn't do anything as we transmit our heading and pitch as generic properties, see turret-gunner-set.xml.
    return [];
}

copilot_disconnect_pilot = func () {
    connected = 0;
}
