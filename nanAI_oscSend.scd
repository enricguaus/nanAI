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

// Title:        nanAI_oscSend.scd
// Author:       Enric Guaus
// Created:      17/01/2023
// Description:  GUI for nanAI
// Dependencies: korgNANOKONTROL2toOSC.scd
//               nanAI_play.scd
//               nanAI_config.scd
//               nanAI_synths.scd
//               nanAI_oscControl.scd
//               nanAI_oscgui.scd
// Config:       Nothing to configure here.
// Use:          Nothing.
//               There is some code to test data in localhost (manually executed).

// --------------
// ---- TASK ----
// --------------
~runOSC=Task({
	inf.do({
		~n_inputs.do({arg i;
			~result_osc_out.sendMsg("/nch",i);
			~result_osc_tst.sendMsg("/nch",i);
			~fea_bus.subBus(i*~n_dims,~n_dims).get({arg j;{
				~result_osc_out.sendMsg("/fea",*j);
				~result_osc_tst.sendMsg("/fea",*j);
			}.defer});
			~dis_bus.subBus(i*~kme_k,~kme_k).get({arg j;{
				~result_osc_out.sendMsg("/err",*j);
				~result_osc_tst.sendMsg("/err",*j);
			}.defer});
			~cla_bus.subBus(i,1).get({arg j;{
				~result_osc_out.sendMsg("/cla",j);
				~result_osc_tst.sendMsg("/cla",j);
			}.defer});
			0.5.wait;
		});
	});
});


// ------------------
// ---- TEST OSC ----
// ------------------
/*
(
OSCdef(\test_nch,{ arg msg, time, addr, recvPort;
	"n_ch:      ".post;
	msg[1].postln;
},'/nch',recvPort:~osc_out_port);

OSCdef(\test_fea,{ arg msg, time, addr, recvPort;
	"features:  ".post;
	msg[1..].postln;
},'/fea',recvPort:~osc_out_port);

OSCdef(\test_err,{ arg msg, time, addr, recvPort;
	"distance:  ".post;
	msg[1..].postln;
},'/err',recvPort:~osc_out_port);

OSCdef(\test_cla,{ arg msg, time, addr, recvPort;
	"clusterID: ".post;
	msg[1].postln;
},'/cla',recvPort:~osc_out_port);
)
*/


(
OSCdef(\test_nch).free;
OSCdef(\test_fea).free;
OSCdef(\test_err).free;
OSCdef(\test_cla).free;
)
