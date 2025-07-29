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

// Title:        nanAI_gui.scd
// Author:       Enric Guaus
// Created:      17/01/2023
// Description:  GUI for nanAI
// Dependencies: korgNANOKONTROL2toOSC.scd
//               nanAI_play.scd
//               nanAI_config.scd
//               nanAI_synths.scd
//               nanAI_oscControl.scd
// Config:       Nothing to configure here.
// Use:          Nothing. Just enjoy the color changes!

// -----------------------
// ---- CREATE WINDOW ----
// -----------------------
~nanAI_Wdw = Window("nanAI (by Sheepdog)", Rect(128, 64, ~gui_width, ~gui_height))
    .background_(Color(0,0,0,0.4))
    .drawFunc_({
	    Pen.drawImage( Point(5, 5), ~gui_image, operation: 'sourceOver', opacity:1);
	    Pen.drawImage( Point(120,5), ~gui_image, operation: 'sourceOver', opacity:0.85);
	    Pen.drawImage( Point(235,5), ~gui_image, operation: 'sourceOver', opacity:0.7);
	    Pen.drawImage( Point(350,5), ~gui_image, operation: 'sourceOver', opacity:0.55);
	    Pen.drawImage( Point(465,5), ~gui_image, operation: 'sourceOver', opacity:0.4);
	    Pen.drawImage( Point(580,5), ~gui_image, operation: 'sourceOver', opacity:0.25);
	    Pen.drawImage( Point(695,5), ~gui_image, operation: 'sourceOver', opacity:0.1);
    })
    .onClose_({
	    ~n_inputs.do({arg i;~fre_gui[i].kill;});
	    // ~n_inputs.do({arg i;~nne_gui[i].kill;}); ---- TO DELETE ----
	    ~runDes.stop;
    });

~fre_gui = Array.fill(~n_inputs,{arg i;
	FreqScopeView(~nanAI_Wdw, Rect((~gui_width/~n_inputs)*i+10,155,(~gui_width/~n_inputs)-20,145))
	.active_(true)
	//.inBus_(~mic_bus.subBus(i,1))
	.inBus_(Bus.newFrom(~mic_bus,i,1))
	.freqMode_(1)
});

~fea_gui = Array.fill(~n_inputs,{arg i;
	MultiSliderView(~nanAI_Wdw,Rect((~gui_width/~n_inputs)*i+10,305,(~gui_width/~n_inputs)-20,145))
	.fillColor_(Color.blue(0.3+(0.1*i),0.5+(0.1*i)))
});

~dis_gui = Array.fill(~n_inputs,{arg i;
	MultiSliderView(~nanAI_Wdw,Rect((~gui_width/~n_inputs)*i+10,455,(~gui_width/~n_inputs)-20,145))
	.fillColor_(Color.green(0.3+(0.1*i),0.5+(0.1*i)))
});

~clu_box = Array.fill(~n_inputs,{arg i;
	NumberBox(~nanAI_Wdw, Rect((~gui_width/~n_inputs)*i+10,605,(~gui_width/~n_inputs)-20,20));
});

~n_inputs.do({arg i;
	~fea_gui[i].elasticMode=true;
	~fea_gui[i].drawRects=true;
	~fea_gui[i].isFilled=true;
	~fea_gui[i].editable=true;
	~fea_gui[i].value=Array.fill(~n_dims,{arg j; 0});
	~dis_gui[i].elasticMode=true;
	~dis_gui[i].drawRects=true;
	~dis_gui[i].isFilled=true;
	~dis_gui[i].editable=true;
	~dis_gui[i].value=Array.fill(~kme_k,{arg j; 0});
	~clu_box[i].value = 0.0;
});

~nanAI_Wdw.front;

// --------------
// ---- TASK ----
// --------------
~runGui=Task({
	inf.do({arg k;
		~n_inputs.do({arg i;
			// Print computed features
			//~fea_bus[i].get({arg j;{~fea_gui[i].value_(j)}.defer});
			~fea_bus.subBus(i*~n_dims,~n_dims).get({arg j;{~fea_gui[i].value_(j)}.defer;});
			0.005.wait;
			~dis_bus.subBus(i*~kme_k,~kme_k).get({arg j;{~dis_gui[i].value_(j.log10)}.defer;});
			0.005.wait;
			~cla_bus.subBus(i,1).get({arg j;{~clu_box[i].value_(j)}.defer;});
		    0.005.wait;
		});
		0.005.wait;
		~nanAI_Wdw.background_(Color(
			sin(1*k/(2*pi)/500-(pi/2)).linlin(-1,1,0,1),
			sin(3*k/(2*pi)/500-(pi/2)).linlin(-1,1,0,1),
			sin(5*k/(2*pi)/500-(pi/2)).linlin(-1,1,0,1),
		0.4));
		0.005.wait;
 	});
});//.play(AppClock);
