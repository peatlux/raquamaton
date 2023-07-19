s.boot;

//---------- T A B L A ----------------


// Create buffer paths
p = Platform.userHomeDir +/+ "/Documents/Studium/Master AKT/SS 23/Unconventional Computing/quantumlife/";


(
var bufferPaths = [
    (p++"tabla samples/dha.wav"),
	(p++"tabla samples/dhin.wav"),
	(p++"tabla samples/ga.wav"),
	(p++"tabla samples/ka.wav"),
	(p++"tabla samples/na.wav"),
	(p++"tabla samples/ra.wav"),
	(p++"tabla samples/te.wav"),
	(p++"tabla samples/tin.wav"),
	(p++"tabla samples/tun.wav"),
	(p++"tabla samples/break01.wav"),
	(p++"tabla samples/break02.wav"),

];

// Load audio files into buffers
var buffers = bufferPaths.collect { |path| Buffer.read(s, path); };

// Set up buffer indices for the SynthDefs
~bufferIndices = buffers.collect { |buffer| buffer.bufnum; };


// SynthDef for playing a buffer with amplitude control
SynthDef(\tabla, { |out = 0, bufnum, amp = 0.1,cutoff = 16e3, resonance = 1,speed = 1,onoff = 1|
    var sig, filtered;
    sig = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum)*speed, doneAction: Done.freeSelf);
	//filtered = RLPF.ar(sig, cutoff, resonance);
    //sig = filtered * amp;
	Out.ar(out, onoff*amp*sig!2);
}).add;

//Synth(\tabla, [\bufnum,~bufferIndices[10.rand], \cutoff, 600, \resonance, 1, \speed, rrand(0.8,1.2)]);

a = Pdef(\rhythmPattern, Pbind(
    \instrument, \tabla,
	\bufnum, Pseq(Array.fill(4, {arg i; ~bufferIndices[[1,0,1,2,0,3,1,1,0,1,0].scramble.normalizeSum.windex]} ),inf),
	//Pseq([ 7, 1, 8, 9 ], inf)
	\dur, Pseq([0.17,0.33],inf),
	\amp, Pseq([0.1,0.2],inf)
));

)

//test
a.play;
a.stop;

//Pdef(\rhythmPattern).source.postcs; // ... and inspect the event pattern itself.


(
// ---------------------- S I T A R -----------------------------------------------------------------
// SynthDef for 'sitar' using physical modeling of strings
SynthDef(\stringSynth, {
    |out = 0, freq = 709,octave = 0.0, amp = 0.5, pan = 0.0, scl = 0.0, decay = -1.0, glide = 0.0|
    var excitation, string, sound, signal, env;

    // Excitation source (e.g., an impulse)
	excitation = Impulse.kr(0); //Dust.ar(1);
	//Impulse.kr(MouseY.kr(0.1, 5).reciprocal)
    // String model
	//string = Pluck.ar(WhiteNoise.ar(0.1),excitation , 0.1, MouseX.kr(0, 1).linexp(0,1,0.0001,0.005) , 10,
    //    coef:MouseY.kr(0, 0.999));

	//Bhairavi tuning for 11 base strings in semitones relative to base freq

	signal = Pluck.ar(WhiteNoise.ar(0.1),excitation , 0.01, SinOsc.kr(2,0.5pi,0.001,1) * 709.0/freq*1409e-6*(2**((-1*Line.kr(0,(glide+octave) * 0.2,0.2) - (1.0*scl) - (octave*12.0))/12.0)) , 20+(decay*scl),
		coef:35e-3 - Line.kr(0,glide.abs * 17e-3,0.2),mul: amp); //35e-3
	env = EnvGen.kr(Env.perc(0,10,1,10), doneAction: Done.freeSelf);


	Out.ar(0, Pan2.ar(signal*env, pan));
}).add;

b = Pdef(\sitar, Pbind(
	'scl', Pseq([ 12.0, 0.0, 3.0, 1.0, 12.0, 0.0, 3.0, 1.0, 0.0, 3.0, 0.0, 8.0, 0.0, 3.0, 0.0, 8.0, 1.0, 0.0, 0.0, 4.0, 1.0, 0.0, 0.0, 4.0, 2.0, 0.0, 12.0, 0.0, 2.0, 0.0, 12.0, 0.0 ], inf),
	'instrument', 'stringSynth',
	'dur', (2.0 * Pseq([ 0.020833333333333, 0.052083333333333, 0.010416666666667, 0.10416666666667, 0.020833333333333, 0.052083333333333, 0.010416666666667, 0.10416666666667, 0.010416666666667, 0.0, 0.020833333333333, 0.0, 0.010416666666667, 0.0, 0.020833333333333, 0.0, 0.041666666666667, 0.020833333333333, 0.083333333333333, 0.010416666666667, 0.041666666666667, 0.020833333333333, 0.083333333333333, 0.010416666666667, 0.0, 0.083333333333333, 0.0, 0.041666666666667, 0.0, 0.083333333333333, 0.0, 0.041666666666667 ], inf)), 'decay', Pseq([ 1, 1, 2, 2, -1, -1, -3, -1 ], inf),
	'freq', 709,
	'amp', (0.6 * Pseq([ 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 1.0 ], inf)),
	'octave', Pseq([ 0.89999997615814, -0.10000000149012, 0.89999997615814, 0.89999997615814, 0.89999997615814, -0.10000000149012, 0.89999997615814, 0.89999997615814, -1.1000000238419, -0.10000000149012, -1.1000000238419, -1.1000000238419, -1.1000000238419, -0.10000000149012, -1.1000000238419, -1.1000000238419, -0.10000000149012, -1.1000000238419, -1.1000000238419, -0.10000000149012, -0.10000000149012, -1.1000000238419, -1.1000000238419, -0.10000000149012, -1.1000000238419, -1.1000000238419, -0.10000000149012, -1.1000000238419, -1.1000000238419, -1.1000000238419, -0.10000000149012, -1.1000000238419 ], inf),
	'glide', Pseq([ 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0 ], inf)));

)

//Pdef(\sitar).source.postcs; // ... and inspect the event pattern itself.

//test
b.play;
b.stop;
a.stop;
//s.prepareForRecord(p++"out3.aiff",2);
//s.stopRecording;

(
// ----------------- S T A R T ----------------------------------------
// STOP with Cmd + .
// RESTART if stopped by Cmd + .  and Start again.


// settings for the mix
~amp_tabla = 0.3;
~amp_sitar = 0.6;
~unit_t = 4.0; //also controlled via OSC

//s.record;
~m = Ppar([a,b],inf);
~m.play();


// --------------------------- O S C  -  R E C E I V E R S -------------------------------

OSCdef(\rgvol, { |msg|
	var amp;
	amp = msg[1];
	Pbindef(\rhythmPattern, \amp,~amp_tabla*amp);
	Pbindef(\sitar, \amp,~amp_sitar*amp);
}, '/global/volume');

OSCdef(\rgtime, { |msg|
    var time;
	time = msg[1].asFloat;
	"time for one loop [s]: ".post;
	time.value.postln;
	~unit_t = time.value;
	~unit_t.postln;
}, '/global/time');


OSCdef(\rtonoff, { |msg|
    var onoff;
    onoff = msg[1..].asFloat;
	"tabla onoff: ".post;
	onoff.postln;
	Pbindef(\rhythmPattern, \onoff,  Pseq(onoff,inf));
}, '/tabla/onoff');



OSCdef(\rtamp, { |msg|
    var amp;
    amp = msg[1..].asFloat;
	amp = amp.softclip;
	"tabla amp: ".post;
	amp.postln;
	Pbindef(\rhythmPattern, \amp, ~amp_tabla * Pseq(amp,inf));
}, '/tabla/amparr');

OSCdef(\rtsamp, { |msg|
    var samp;
    samp = msg[1..].asInteger;
	samp = ~bufferIndices[samp];
	samp.postln;
	Pbindef(\rhythmPattern, \bufnum, Pseq(samp,inf));
}, '/tabla/samparr');

OSCdef(\rtdur, { |msg|
    var dur;
    dur = msg[1..].asFloat;
	dur = dur + 0.001; //to prevent a total duration of 0 which stops the Pattern smhw
	dur = dur.normalizeSum;
	dur.postln;
	Pbindef(\rhythmPattern, \dur, ~unit_t * Pseq(dur,inf));
}, '/tabla/durarr');

OSCdef(\rtnumsamp, { |msg|
    var num;
    num = msg[1..].asFloat;
	//dur = dur.normalizeSum;
	//num.postln;
	//Pbindef(\rhythmPattern, \dur, Pseq(num,inf));
}, '/tabla/numsamp');


OSCdef(\rsonoff, { |msg|
    var amp;
    amp = msg[1..].asFloat;
	amp.postln;
	Pbindef(\sitar, \amp, ~amp_sitar * Pseq(amp,inf));
}, '/sitar/onoff');

OSCdef(\rsscale, { |msg|
    var scale;
    scale = msg[1..].asFloat;
	scale.postln;
	Pbindef(\sitar, \scl, Pseq(scale,inf));
}, '/sitar/scale');

OSCdef(\rsdur, { |msg|
    var dur;
    dur = msg[1..].asFloat;
	dur = dur.normalizeSum;
	dur.postln;
	Pbindef(\sitar, \dur, ~unit_t * Pseq(dur,inf));
}, '/sitar/durarr');

OSCdef(\rsoct, { |msg|
    var oct;
    oct = msg[1..].asFloat;
	oct.postln;
	Pbindef(\sitar, \octave , Pseq(oct,inf));
}, '/sitar/octave');

OSCdef(\rsglide, { |msg|
    var glide;
    glide = msg[1..].asFloat;
	glide = glide.normalize * 2 -1;
	glide.postln;
	Pbindef(\sitar, \glide , Pseq(glide, inf) );
}, '/sitar/glide');


)




