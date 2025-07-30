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

// Title:        nanAI_config.scd
// Author:       Enric Guaus
// Created:      17/01/2023
// Description:  General configuration for nanAI
// Dependencies: korgNANOKONTROL2toOSC.scd
//               nanAI_play.scd
// Config:       ~n_inputs: Number of input channels. Each channel performs an independent analysis
//               ~n_outputs: Number of output channels. Only for monitoring input, with creative panning
//               ~n_dims: Number of computed descriptors (manually selected according to nanAI_synths)
//               ~kme_k: number of clusters
//               ~audio_path: Path to audio files, in case of recorded input.
//               ~result_osc_out: IP address for output values (manually selected)
// Use:          Play:  Play all files in ~audio_path
//               Rec:   Listens all channels in ~n_inputs
//               Stop:  Performs analysis from "Play" or "Rec"
//               Cycle: Reset all ~kme_k cluster data
//               Knob:  Amplitude for each input channels

// ------------------------
// ---- PREPARE SERVER ----
// ------------------------
if(s.serverRunning==false,{
	ServerOptions.devices;
	s.options.memSize=1024*64;
});

s.doWhenBooted({
	s.meter(4,4);
	s.plotTree;
});

// -------------------
// ---- CONSTANTS ----
// -------------------
~n_inputs   = 2;
~n_outputs  = 2;
~n_dims     = 7;
~kme_k      = 3;

// ---------------
// ---- BUSES ----
// ---------------
~mic_bus = Bus.audio(s,~n_inputs);
~fea_bus = Bus.control(s,~n_inputs*~n_dims);
~cla_bus = Bus.control(s,~n_inputs);
~dis_bus = Bus.control(s,~n_inputs*~kme_k);

// -----------------------
// ---- AUDIO IN PATH ----
// -----------------------
~audio_path = "/Users/eguaus/OneDrive/Creació/audio/peya/";

// ------------------------
// ---- OSC CONTROL IN ----
// ------------------------
~osc_korg_port   = 57120;  // Receive actions from controller KORG nanoKONTROL2

// -------------------
// ---- VARIABLES ----
// -------------------
~gui_width  = 800;
~gui_height = 650;//480;// 650;
~gui_image = Image.new(~nanAI_folder ++ "images/sheepdog_lite.jpg");

// -------------------------
// ---- OSC CONTROL OUT ----
// -------------------------
~osc_out_port    = 6448;
~result_osc_out  = NetAddr("192.168.123.21", ~osc_out_port); // Send results to another computer
~result_osc_tst  = NetAddr("127.0.0.1", ~osc_out_port);      // Send results to localhost for testing (see nanAI_oscSend)