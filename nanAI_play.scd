/*
Copyright (C) [2023] [Enric Guaus]

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <https://www.gnu.org/licenses/>.
*/

// Title:        nanAI_play.scd
// Author:       Enric Guaus
// Created:      29/07/2025
// Description:  Runs all scripts for nanAI
// Dependencies: korgNANOKONTROL2toOSC.scd
// Config:       Nothing to do here.
//               Closing functions are splitted for error handling on Realtime.
// Use:          Execute main routine.

(
// ---------------
// ---- START ----
// ---------------
Routine {
	~nanAI_folder = PathName.new(thisProcess.nowExecutingPath).pathOnly;
	(~nanAI_folder ++ "nanAI_config.scd").load;
    2.wait;  // wait for 2 seconds
	(~nanAI_folder ++ "nanAI_synths.scd").load;
    2.wait;  // wait for 2 seconds
	(~nanAI_folder ++ "nanAI_oscControl.scd").load;
	2.wait;  // wait for 2 seconds
	(~nanAI_folder ++ "nanAI_gui.scd").load;
	2.wait;  // wait for 2 seconds
	(~nanAI_folder ++ "nanAI_oscSend.scd").load;
}.play(AppClock);
)

(
// ---------------
// ---- CLOSE ----
// ---------------
// ---- from nanAI_gui.scd ----
~nanAI_Wdw.close;

// ---- from nanAI.oscControl.scd ----
OSCdef(\nanAI_nanoKONTROL2_play).free;
OSCdef(\nanAI_nanoKONTROL2_rec).free;
OSCdef(\nanAI_nanoKONTROL2_stop).free;
OSCdef(\nanAI_nanoKONTROL2_cycle).free;
OSCdef(\nanAI_nanoKONTROL2_knob1).free;
OSCdef(\nanAI_nanoKONTROL2_knob2).free;
OSCdef(\nanAI_nanoKONTROL2_knob3).free;
OSCdef(\nanAI_nanoKONTROL2_knob4).free;
OSCdef(\nanAI_nanoKONTROL2_knob5).free;
OSCdef(\nanAI_nanoKONTROL2_knob6).free;
OSCdef(\nanAI_nanoKONTROL2_knob7).free;
OSCdef(\nanAI_nanoKONTROL2_knob8).free;

// ---- from nanAI_synths.scd ----
~n_inputs.do({arg i;
	~aud_buf[i].free;
	~kme_buf[i].free;
});

// ---- from nanAI_config.scd ----
~result_osc_out.disconnect;
~result_osc_tst.disconnect;
~dis_bus.free;
~cla_bus.free;
~fea_bus.free;
~mic_bus.free;
)

s.freeAll;
s.quit;