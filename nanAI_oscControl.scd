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

// Title:        nanAI_oscControl.scd
// Author:       Enric Guaus
// Created:      17/01/2023
// Description:  OSC control from Korg nanoKONTROL2 for nanAI
// Dependencies: korgNANOKONTROL2toOSC.scd
//               nanAI_play.scd
//               nanAI_config.scd
//               nanAI_synths.scd
// Config:       Nothing to configure here.
// Use:          Play:  Play all files in ~audio_path
//               Rec:   Listens all channels in ~n_inputs
//               Stop:  Performs analysis from "Play" or "Rec"
//               Cycle: Reset all ~kme_k cluster data
//               Knob:  Amplitude for each input channels

// -------------------
// ---- TRANSPORT ----
// -------------------
OSCdef(\nanAI_nanoKONTROL2_play,{ arg msg, time, addr, recvPort;
	var value = msg[1].asFloat;
	if(value>0,{
		w = ~n_inputs.collect{arg i; Synth(\play_stereo2mono,[\in_buf, ~aud_buf[i], \out, Bus.newFrom(~mic_bus,i,1), \amp, 0])};
		//w = ~n_inputs.collect{arg i; Synth(\play_stereo2mono,[\in_buf, ~aud_buf[i], \out, ~mic_bus.subBus(i,1), \amp, 0])};
	},{
		~n_inputs.do({arg i; w[i].free;	});
	});
},'/nanoKONTROL2/transport/play',recvPort:~osc_korg_port);

OSCdef(\nanAI_nanoKONTROL2_rec,{ arg msg, time, addr, recvPort;
	var value = msg[1].asFloat;
	if(value>0,{
		w = ~n_inputs.collect{arg i; Synth(\mic,[\in, i, \out, Bus.newFrom(~mic_bus,i,1), \amp, 0])};
		//w = ~n_inputs.collect{arg i; Synth(\mic,[\in, i, \out, ~mic_bus.subBus(i,1), \amp, 0])};
	},{
		~n_inputs.do({arg i; w[i].free;	});
	});
},'/nanoKONTROL2/transport/rec',recvPort:~osc_korg_port);

OSCdef(\nanAI_nanoKONTROL2_stop,{ arg msg, time, addr, recvPort;
	var value = msg[1].asFloat;
	if(value>0,{
		x = ~n_inputs.collect{arg i;
	Synth.tail(nil,\analysis,[\in, ~mic_bus.subBus(i,1), \out, Bus.newFrom(~fea_bus,i*~n_dims,~n_dims), \smooth, 200])};
		y = ~n_inputs.collect{arg i;
	Synth.tail(nil,\k_means,[\in_fea, ~fea_bus.subBus(i*~n_dims,~n_dims), \out_cla, Bus.newFrom(~cla_bus,i,1), \out_dis, Bus.newFrom(~dis_bus,i*~kme_k,~kme_k), \kbuf,~kme_buf[i], \rst, 0, \smooth, 1])};
		~runGui.play(AppClock);
		~runOSC.play(AppClock);
	},{
		~n_inputs.do({arg i;
			y[i].free;
			x[i].free;
		});
		~runGui.stop;
		~runOSC.stop;
	});
},'/nanoKONTROL2/transport/stop',recvPort:~osc_korg_port);

OSCdef(\nanAI_nanoKONTROL2_cycle,{ arg msg, time, addr, recvPort;
	var value = msg[1].asFloat;
	if(value>0,{
		~n_inputs.do({arg i; y[i].set(\rst,1)});
	},{
		~n_inputs.do({arg i; y[i].set(\rst,0)});
	});
},'/nanoKONTROL2/cycle',recvPort:~osc_korg_port);

// ---------------
// ---- KNOBS ----
// ---------------
OSCdef(\nanAI_nanoKONTROL2_knob1,{ arg msg, time, addr, recvPort;
	w[0].set(\amp,msg[1].asFloat);
},'/nanoKONTROL2/knob/1',recvPort:~osc_korg_port);

OSCdef(\nanAI_nanoKONTROL2_knob2,{ arg msg, time, addr, recvPort;
	w[1].set(\amp,msg[1].asFloat);
},'/nanoKONTROL2/knob/2',recvPort:~osc_korg_port);

OSCdef(\nanAI_nanoKONTROL2_knob3,{ arg msg, time, addr, recvPort;
	w[2].set(\amp,msg[1].asFloat);
},'/nanoKONTROL2/knob/3',recvPort:~osc_korg_port);

OSCdef(\nanAI_nanoKONTROL2_knob4,{ arg msg, time, addr, recvPort;
	w[3].set(\amp,msg[1].asFloat);
},'/nanoKONTROL2/knob/4',recvPort:~osc_korg_port);

OSCdef(\nanAI_nanoKONTROL2_knob5,{ arg msg, time, addr, recvPort;
	w[4].set(\amp,msg[1].asFloat);
},'/nanoKONTROL2/knob/5',recvPort:~osc_korg_port);

OSCdef(\nanAI_nanoKONTROL2_knob6,{ arg msg, time, addr, recvPort;
	w[5].set(\amp,msg[1].asFloat);
},'/nanoKONTROL2/knob/6',recvPort:~osc_korg_port);

OSCdef(\nanAI_nanoKONTROL2_knob7,{ arg msg, time, addr, recvPort;
	w[6].set(\amp,msg[1].asFloat);
},'/nanoKONTROL2/knob/7',recvPort:~osc_korg_port);

OSCdef(\nanAI_nanoKONTROL2_knob8,{ arg msg, time, addr, recvPort;
	w[7].set(\amp,msg[1].asFloat);
},'/nanoKONTROL2/knob/8',recvPort:~osc_korg_port);









// ---------------------------------------------------
// ---- TO DELETE - EXAMPLE LINES FOR CUT'N'PASTE ----
// ---------------------------------------------------
/*
OSCdef(\nanoKONTROL2_next,{ arg msg, time, addr, recvPort;
	var value = msg[1].asFloat;
	if(value>0,{
		z = ~n_inputs.collect{arg i;
			Synth.newPaused(\encdec,[\in,~aud_buf[i], \out, Bus.newFrom(~nne_bus,i,1), \idx,i,\in_lat,~dis_bus.subBus(i*~kme_k,~kme_k)])};
	});
},'/nanoKONTROL2/marker/next',recvPort:~osc_korg_port);

OSCdef(\nanoKONTROL2_last,{ arg msg, time, addr, recvPort;
	var value = msg[1].asFloat;
	if(value>0,{
		~n_inputs.do({arg i; z[i].free;});
	});
},'/nanoKONTROL2/marker/last',recvPort:~osc_korg_port);



OSCdef(\nanoKONTROL2_fader1,{ arg msg, time, addr, recvPort;
	z[0].set(\amp,msg[1].asFloat);
},'/nanoKONTROL2/fader/1',recvPort:~osc_korg_port);

OSCdef(\nanoKONTROL2_fader2,{ arg msg, time, addr, recvPort;
	z[1].set(\amp,msg[1].asFloat);
},'/nanoKONTROL2/fader/2',recvPort:~osc_korg_port);

OSCdef(\nanoKONTROL2_fader3,{ arg msg, time, addr, recvPort;
	z[2].set(\amp,msg[1].asFloat);
},'/nanoKONTROL2/fader/3',recvPort:~osc_korg_port);

OSCdef(\nanoKONTROL2_fader4,{ arg msg, time, addr, recvPort;
	z[3].set(\amp,msg[1].asFloat);
},'/nanoKONTROL2/fader/4',recvPort:~osc_korg_port);

OSCdef(\nanoKONTROL2_fader5,{ arg msg, time, addr, recvPort;
	z[4].set(\amp,msg[1].asFloat);
},'/nanoKONTROL2/fader/5',recvPort:~osc_korg_port);

OSCdef(\nanoKONTROL2_fader6,{ arg msg, time, addr, recvPort;
	z[5].set(\amp,msg[1].asFloat);
},'/nanoKONTROL2/fader/6',recvPort:~osc_korg_port);

OSCdef(\nanoKONTROL2_fader7,{ arg msg, time, addr, recvPort;
	z[6].set(\amp,msg[1].asFloat);
},'/nanoKONTROL2/fader/7',recvPort:~osc_korg_port);

OSCdef(\nanoKONTROL2_fader8,{ arg msg, time, addr, recvPort;
	z[7].set(\amp,msg[1].asFloat);
},'/nanoKONTROL2/fader/8',recvPort:~osc_korg_port);
)



OSCdef(\nanoKONTROL2_rec1,{ arg msg, time, addr, recvPort;
	var value = msg[1].asFloat;
	if(value>0,{z[0].run;},{z[0].run(false);});
},'/nanoKONTROL2/rec/1',recvPort:~osc_korg_port);

OSCdef(\nanoKONTROL2_rec2,{ arg msg, time, addr, recvPort;
	var value = msg[1].asFloat;
	if(value>0,{z[1].run},{z[1].run(false)});
},'/nanoKONTROL2/rec/2',recvPort:~osc_korg_port);

OSCdef(\nanoKONTROL2_rec3,{ arg msg, time, addr, recvPort;
	var value = msg[1].asFloat;
	if(value>0,{z[2].run},{z[2].run(false)});
},'/nanoKONTROL2/rec/3',recvPort:~osc_korg_port);

OSCdef(\nanoKONTROL2_rec4,{ arg msg, time, addr, recvPort;
	var value = msg[1].asFloat;
	if(value>0,{z[3].run},{z[3].run(false)});
},'/nanoKONTROL2/rec/4',recvPort:~osc_korg_port);

OSCdef(\nanoKONTROL2_rec5,{ arg msg, time, addr, recvPort;
	var value = msg[1].asFloat;
	if(value>0,{z[4].run},{z[4].run(false)});
},'/nanoKONTROL2/rec/5',recvPort:~osc_korg_port);

OSCdef(\nanoKONTROL2_rec6,{ arg msg, time, addr, recvPort;
	var value = msg[1].asFloat;
	if(value>0,{z[5].run},{z[5].run(false)});
},'/nanoKONTROL2/rec/6',recvPort:~osc_korg_port);

OSCdef(\nanoKONTROL2_rec7,{ arg msg, time, addr, recvPort;
	var value = msg[1].asFloat;
	if(value>0,{z[6].run},{z[6].run(false)});
},'/nanoKONTROL2/rec/7',recvPort:~osc_korg_port);

OSCdef(\nanoKONTROL2_rec8,{ arg msg, time, addr, recvPort;
	var value = msg[1].asFloat;
	if(value>0,{z[7].run},{z[7].run(false)});
},'/nanoKONTROL2/rec/8',recvPort:~osc_korg_port);
*/

