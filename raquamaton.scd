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
SynthDef(\tabla, { |out = 0, bufnum, amp = 0.5,cutoff = 16e3, resonance = 1,speed = 1,onoff = 1|
    var sig, filtered;
    sig = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum)*speed, doneAction: Done.freeSelf);
	//filtered = RLPF.ar(sig, cutoff, resonance);
    //sig = filtered * amp;
	Out.ar(out, onoff*amp*sig!2);
}).add;

//Synth(\tabla, [\bufnum,~bufferIndices[10.rand], \cutoff, 600, \resonance, 1, \speed, rrand(0.8,1.2)]);


a = Pdef(\rhythmPattern, Pbind(
    \instrument, \tabla,
	\bufnum, Pn(Pdefn(\sampleholder),inf),
	\dur, Pn(Pdefn(\durholder),inf),
	\amp, Pn(Pdefn(\ampholder),inf)
));

c = Pdefn(\durholder,{|arr| Pseq(arr.durarr)});
b = Pdefn(\sampleholder, {|arr| Pseq(arr.samparr)});
v = Pdefn(\ampholder,{|arr| Pseq(arr.amparr)});
b.set(\samparr, Array.fill(16, {arg i; ~bufferIndices[[1,0,1,2,0,3,1,1,0,1,0].scramble.normalizeSum.windex]} ));
c.set(\durarr,  Array.fill(16,{arg i; 0.2 + rrand(-0.2,0.2)}) );
v.set(\amparr, Array.fill(16, {arg i; 0.4}));
)

a.play;
a.stop;
b.set(\samparr, Array.fill(16, {arg i; ~bufferIndices[[1,0,1,2,0,3,1,1,0,1,0].scramble.normalizeSum.windex]} ));
//[10,8,5,5,5,5,5,7,5,5,5]
c.set(\durarr,  Array.fill(16,{arg i; 0.2 + rrand(-0.2,0.2)}) );
v.set(\amparr, Array.fill(16, {arg i; 0.2 + rrand(0,0.1)}));

//Pdefn(\sampleholder).source.postcs; // ... and inspect the event pattern itself.

Pbindef(\rhythmPattern, \amp, 0.3);
Pbindef(\rhythmPattern, \bufnum, Pseq(Array.fill(16,{|i| ~bufferIndices[[1,0,1,2,0,3,1,1,0,1,0].scramble.normalizeSum.windex]} ),inf),\dur,Pseq(Array.fill(16,{arg i; 0.2 + rrand(-0.2,0.2)}),inf));


d = Scale.bhairav;
d.name
d = Scale.chooseFromSelected({arg item; e.includesEqual(item.name);})

e = ["Indian","Hindu","Athar Kurd","Karjighar","Purvi","Jiharkah","Bayati","Ahirbhairav","Bhairav","Nawa Athar"];


d.name.class

"Bhairav".class
// SynthDef for playing a buffer with pitch control
SynthDef(\shruti, { |out = 0, bufnum, pitch = 0, amp = 0.5, cutoff = 16e3, resonance = 1 |
    var sig, freq, filtered;
    freq = BufRateScale.kr(bufnum) * (2 ** (pitch / 12));
    sig = PlayBuf.ar(1, bufnum, freq, doneAction: Done.freeSelf);
	filtered = RLPF.ar(sig, cutoff, resonance);
    sig = filtered * amp;
    Out.ar(out, sig);
}).add;


Quarks.gui;
Platform.userExtensionDir;

Ndef(\sound).play;
Ndef(\sound).fadeTime = 1;
Ndef(\sound, { SinOsc.ar([600, 635], 0, SinOsc.kr(0.15).clip(-0.8,0.8) * 0.1) });
Ndef(\sound, Pbind(\dur, 0.17, \freq, Pfunc({ rrand(300, 700) })) );

// SynthDef for 'sitar' using physical modeling of strings
SynthDef(\stringSynth, {
    |out = 0, freq = 709,octave = 1.0, amp = 0.5, pan = 0.0,chill=0.3, scl = 0.0, decay = -1.0, glide = 0.0|
    var excitation, string, sound, signal, env;

    // Excitation source (e.g., an impulse)
	excitation = Impulse.kr(0); //Dust.ar(1);
	//Impulse.kr(MouseY.kr(0.1, 5).reciprocal)
    // String model
	//string = Pluck.ar(WhiteNoise.ar(0.1),excitation , 0.1, MouseX.kr(0, 1).linexp(0,1,0.0001,0.005) , 10,
    //    coef:MouseY.kr(0, 0.999));

	//Bhairavi tuning for 11 base strings in semitones relative to base freq

	signal = Pluck.ar(WhiteNoise.ar(0.1),excitation , 0.01, SinOsc.kr(2,0.5pi,0.001,1)  * 709/freq*1409e-6*(2**((-1*Line.kr(0,glide * 0.2*octave,0.2) - (1.0*scl) - (octave*12))/12.0)) , 20+(decay*scl),
		coef:35e-3 - Line.kr(0,glide.abs * 17e-3,0.2),mul: amp); //35e-3
	env = EnvGen.kr(Env.perc(0,10,1,10), doneAction: Done.freeSelf);


	Out.ar(0, Pan2.ar(signal, pan));
}).add;

Pbindef(\sitar, \glide, Pseq([0,1,0,0,-1,1,-1,0,0,0,0],inf));
//[0,1,0,0,-1,1,-1,0,0,0,0].normalize *2 -1

{SinOsc.kr(Line.kr(0,5,20),0.5pi,0.1,1)}.plot(20);

// Create an instance of the 'sitar' and play it
a = Synth(\stringSynth,[\chill,1]);
a.set(\decay,1); //>0: high tones take longer; <0: low tones take longer
a.set(\chill, 1.0);
a.set(\delay, Array.fill(11,{arg i; rrand(0.05,3.0)}));
a.set(\freq, 440);

//Ndef(\stringSynth, Pbind(\fac, -1, \chill, 0.7, \delay,Array.fill(11,{arg i; rrand(0.5,1.0)})));
a.stop;
n.stop;

~s1 = Array.fill(16,{arg i; 0.2 + rrand(-0.2,0.2)});
~s1 = [-999,0,1,6,-4,-1];
~s1.floor

FreqScope.new(800, 500, 0, server: s);
[2.0,3.0,6.0][1..2].sum;

n = Pdef(\sitar, Pbind(
	\instrument, \stringSynth,
	\scl, Pseq([-1.0,0.0,4.0,5.0,9.0,7.0,4.0,5.0,4.0,2.0,0.0],inf),
	\dur, Pseq( Array.fill(16,{arg i; 0.2 + rrand(-0.2,0.2)}) ,inf),
	\decay, Pseq([1,1,2,2,-1,-1,-3,-1],inf),
	\freq, 709,
	\amp, 0.5,
));
n.play;
n.stop;
n.set(\decay,-20); //>0: high tones take longer; <0: low tones take longer
n.set(\chill, 1.0);
n.set(\freq, 440);
Pbindef(\sitar, \amp,0.5*Pseq([0,1,0,1,0,0,0,1,1],inf), \decay, Pseq([-10,-2,4.2,9,-5],inf) );

(
Pbindef(\sitar, \decay, Pseq([-12,-15,6,-9],inf),\scl, Pseq([-1.0,0.0,4.0,5.0,9.0,7.0,4.0,5.0,4.0,2.0,0.0].scramble,inf));
Pbindef(\rhythmPattern, \bufnum, Pseq(Array.fill(16,{|i| ~bufferIndices[[1,0,1,2,0,3,1,1,0,1,0].scramble.normalizeSum.windex]} ),inf),\dur,Pseq(Array.fill(16,{arg i; 0.2 + rrand(-0.2,0.2)}),inf));
)

n.play(u);
n.stop;

m = Ppar([a,n],inf);
m.play(u);
m.stop;

t = TempoClock.new;
u = TempoClock.new;
Pdef(\p04b).play(t);
Pdef(\p04c).play(u);
u.tempo = 1.0;

~amp_tabla = 0.3;
~amp_sitar = 0.6;
~unit_t = 4;

// Set up OSC receivers
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
    samp = msg[1..].asFloat;
	samp.postln;
	Pbindef(\rhythmPattern, \bufnum, Pseq(samp,inf));
}, '/tabla/samparr');

OSCdef(\rtdur, { |msg|
    var dur;
    dur = msg[1..].asFloat;
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

n.play;


OSCdef(\receive3, { |msg|
    var bufnum, amp, cutoff, resonance;
    bufnum = msg[1].asInteger;  // Assuming the first argument is the buffer number
    amp = msg[2].asFloat;  // Assuming the second argument is the amplitude
    cutoff = msg[3].asFloat;  // Assuming the third argument is the cutoff frequency
    resonance = msg[4].asFloat;  // Assuming the fourth argument is the resonance
    Synth(\bufferFilterPlayer, [\bufnum, bufnum, \amp, amp, \cutoff, cutoff, \resonance, resonance]);
}, '/playbuffer3');

OSCdef(\receive4, { |msg|
    // Add code for the fourth receiver here
    // Adjust the number of arguments and their mappings to parameters as needed
}, '/playbuffer4');

OSCdef(\receive5, { |msg|
    // Add code for the fifth receiver here
    // Adjust the number of arguments and their mappings to parameters as needed
}, '/playbuffer5');
