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

// Title:        nanAI_synths.scd
// Author:       Enric Guaus
// Created:      17/01/2023
// Description:  Synthesizers for nanAI
// Dependencies: korgNANOKONTROL2toOSC.scd
//               nanAI_play.scd
//               nanAI_config.scd
// Config:       In Synthdef(\analysis...):
//               - Manual selection of computed desciptors (and derivatives).
//               - Manual normalization for better classification. Please, check values.
//               - "tanh" is computed over some of the normalized and returned values.
// Use:          Update ~n_dims at config.scd.

// ----------------------
// ---- START SERVER ----
// ----------------------
s.waitForBoot({

	// -----------------
	// ---- BUFFERS ----
	// -----------------
	~kme_buf = ~n_inputs.collect{Buffer.alloc(s, ~kme_k, ~n_dims+1)};
	~aud_buf = ~n_inputs.collect{arg i; Buffer.read(s, ~audio_path +/+  PathName.new(~audio_path).files[i].fileName)};
	~n_inputs.collect{arg i; Bus.newFrom(~mic_bus,i,1)}; // ??? Cal aquesta línia? Feta per resoldre la FFT?

	// -------------------
	// ---- SYNTHDEFs ----
	// -------------------
	SynthDef(\mic, {arg in=0, out=0, amp=0.7;//, pan=0.5;
		var snd = SoundIn.ar(in).tanh;
		var ste = PanX.ar(~n_outputs,snd,LFNoise2.ar(0.1,0.5,0.5),amp);
		Out.ar(out, snd);  // Out to descriptors bus
		Out.ar(0, ste);    // Out to audio (default audio output)
	}).add;

	SynthDef(\play_stereo2mono, {arg in_buf=0, out=0, amp=0.7;//, pan=0.5;
		var snd = Mix.ar(PlayBuf.ar(2,in_buf,loop: 1,doneAction:2).tanh);
		var ste = PanX.ar(~n_outputs,snd,LFNoise2.ar(0.1,0.5,0.5),amp);
		Out.ar(out, snd);  // Out to descriptors bus
		Out.ar(0, ste);    // Out to audio (default audio output)
	}).add;

	SynthDef(\analysis, {arg in=0, out=0, smooth=200;
		// ---- Input and FFT ----
		var snd = In.ar(in,1);
		var fft = FFT(LocalBuf(1024), snd);
		var trg = fft > -0.001;
		// ---- Amplitude, RMS and Loudness ---- 6 descriptors ----
		var amp   = Amplitude.kr(snd);
		var rms   = RMS.kr(snd);
		var lou   = Loudness.kr(fft);
		var d_amp = Slope.kr(amp);
		var d_rms = Slope.kr(rms);
		var d_lou = Slope.kr(lou);
		// ---- Pitch ---- 2 descriptors ----
		var frq   = Tartini.kr(snd);
		var d_frq = Slope.kr(frq);
		// ---- Rhythm ---- 7 descriptors ----
		var ons   = OnsetStatistics.kr(Onsets.kr(fft,0.25),2.0);
		var bst   = BeatStatistics.kr(fft);
		// ---- Chroma ---- 13 descriptors
		var key   = KeyTrack.kr(fft, keydecay: 2.0, chromaleak: 0.25);
		var chr   = Chromagram.kr(fft);
		// ---- Timbre ---- 32 descriptors ----
		var cen   = SpecCentroid.kr(fft);
		var fla   = SpecFlatness.kr(fft);
		var sdi   = SensoryDissonance.kr(fft);
		var mfc   = MFCC.kr(fft);
		var d_cen = Slope.kr(cen);
		var d_fla = Slope.kr(fla);
		var d_sdi = Slope.kr(sdi);
		var d_mfc = Slope.kr(mfc);
		// ---- Save data ---- 60 descriptors ---- manual normalization ----
		var des   = [
			        //amp,d_amp,
			        //rms,d_rms,
		        	(lou/40).tanh,//d_lou,
			        (frq[0]/1000).tanh,//d_frq[0],
			        //frq[1],d_frq[1],
			        (ons[0]/10).tanh,ons[1].tanh,ons[2].tanh,
			        //bst[0],bst[1],bst[2],bst[3],
			        //key,
			        // chr[0],chr[1],chr[2],chr[3],chr[4] ,chr[5] ,chr[6],
			        //        chr[7],chr[8],chr[9],chr[10],chr[11],
			        //cen,d_cen,
			        fla.tanh,//d_fla,
			        sdi.tanh//,d_sdi
			        //mfc[0],mfc[1],mfc[2],mfc[3] ,mfc[4] ,mfc[5] ,mfc[6],
			        //       mfc[7],mfc[8],mfc[9],mfc[10],mfc[11],mfc[12],
			        //d_mfc[0],d_mfc[1],d_mfc[2],d_mfc[3],d_mfc[4] ,d_mfc[5] ,d_mfc[6],
			        //         d_mfc[7],d_mfc[8],d_mfc[9],d_mfc[10],d_mfc[11],d_mfc[12]
		            ];
		Out.kr(out,des);
	}).add;

	SynthDef(\k_means,{arg in_fea=0, out_cla=0, out_dis=0, kbuf=0, rst=0, smooth=1;
		// Consider use MovingAverage for features
		// Consider use MedianTriggered for classification
		var fea = In.kr(in_fea,~n_dims);
		var cla = KMeansRT.kr(kbuf, fea, ~kme_k, reset:rst>0);
		var cen=Array.fill(~kme_k,0.0);
		var dis=Array.fill(~kme_k,0.0);
		~kme_k.do({arg i;
			cen[i] = KMeansRT.getCentroid(kbuf,i,~n_dims);
			dis[i] = (fea-cen[i]).abs.sum;
		});
		Out.kr(out_cla, cla);
		Out.kr(out_dis, dis);
	}).add;
});


