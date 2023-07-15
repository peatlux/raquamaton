s.boot;

//---------- T A B L A ----------------
p = Platform.userHomeDir +/+ "/Documents/Studium/Master AKT/SS 23/Unconventional Computing/quantumlife/";

(
// Create buffer paths
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
SynthDef(\tabla, { |out = 0, bufnum, amp = 0.5,cutoff = 16e3, resonance = 1,speed = 1|
    var sig, filtered;
    sig = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum)*speed, doneAction: Done.freeSelf);
	//filtered = RLPF.ar(sig, cutoff, resonance);
    //sig = filtered * amp;
	Out.ar(out, sig!2);
}).add;

//Synth(\tabla, [\bufnum,~bufferIndices[10.rand], \cutoff, 600, \resonance, 1, \speed, rrand(0.8,1.2)]);


a = Pdef(\rhythmPattern, Pbind(
    \instrument, \tabla,
	\bufnum, Pn(Pdefn(\sampleholder),inf),
	\dur, Pn(Pdefn(\durholder),inf)
));

c = Pdefn(\durholder,{|arr| Pseq(arr.durarray)});
b = Pdefn(\sampleholder, {|arr| Pseq(arr.samparr)});
b.set(\samparr, Array.fill(16, {arg i; ~bufferIndices[[1,0,1,2,0,3,1,1,0,1,0].scramble.normalizeSum.windex]} ));
c.set(\durarray,  Array.fill(16,{arg i; 0.2 + rrand(-0.2,0.2)}) );
)


a.play;
a.stop;
b.set(\samparr, Array.fill(16, {arg i; ~bufferIndices[[1,0,1,2,0,3,1,1,0,1,0].scramble.normalizeSum.windex]} ));
//[10,8,5,5,5,5,5,7,5,5,5]
c.set(\durarray,  Array.fill(16,{arg i; 0.2 + rrand(-0.2,0.2)}) );

//Pdefn(\sampleholder).source.postcs; // ... and inspect the event pattern itself.


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
    |out = 0, freq = 709, amp = 0.5, pan = 0,chill=0.3, scale = #[-1.0,0.0,4.0,5.0,9.0,7.0,4.0,5.0,4.0,2.0,0.0], decay = -1.0, delay = #[1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0]|
    var excitation, string, sound, signal, env;

    // Excitation source (e.g., an impulse)
	excitation = Impulse.kr(0.5); //Dust.ar(1);
	//Impulse.kr(MouseY.kr(0.1, 5).reciprocal)
    // String model
	//string = Pluck.ar(WhiteNoise.ar(0.1),excitation , 0.1, MouseX.kr(0, 1).linexp(0,1,0.0001,0.005) , 10,
    //    coef:MouseY.kr(0, 0.999));

	//Bhairavi tuning for 11 base strings in semitones relative to base freq

	signal = Mix.fill(11,{ arg i;(Pluck.ar(WhiteNoise.ar(0.1),TDelay.kr(excitation,delay[0..i].sum*chill/11) , 0.01, 709/freq*1409e-6*(2**(-1.0*scale[i]/12)) , 20+(decay*scale[i]),
		coef:35e-3));});

	Out.ar(0, Pan2.ar(signal*amp, pan));
}).add;

// Create an instance of the 'sitar' and play it
a = Synth(\stringSynth,[\chill,1]);
a.set(\fac,1);
a.set(\chill, 1.0);
a.set(\delay, Array.fill(11,{arg i; rrand(0.05,3.0)}));
a.set(\freq, 440);

//Ndef(\stringSynth, Pbind(\fac, -1, \chill, 0.7, \delay,Array.fill(11,{arg i; rrand(0.5,1.0)})));
a.stop;

s.freqscope;

FreqScope.new(800, 500, 0, server: s);
[2.0,3.0,6.0][1..2].sum





c = Ppar([]);


// SynthDef for playing a buffer with amplitude and filter control
SynthDef(\bufferFilterPlayer, { |out = 0, bufnum, amp = 0.5, cutoff = 8000, resonance = 0.5|
    var sig, filtered;
    sig = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum), doneAction: Done.freeSelf);
    filtered = RLPF.ar(sig, cutoff, resonance);
    sig = filtered * amp;
    Out.ar(out, sig);
}).add;

// Set up OSC receivers
OSCdef(\receive1, { |msg|
    var bufnum, amp;
    bufnum = msg[1].asInteger;  // Assuming the first argument is the buffer number
    amp = msg[2].asFloat;  // Assuming the second argument is the amplitude
    Synth(\bufferPlayer, [\bufnum, bufnum, \amp, amp]);
}, '/playbuffer1');

OSCdef(\receive2, { |msg|
    var bufnum, pitch, amp;
    bufnum = msg[1].asInteger;  // Assuming the first argument is the buffer number
    pitch = msg[2].asFloat;  // Assuming the second argument is the pitch
    amp = msg[3].asFloat;  // Assuming the third argument is the amplitude
    Synth(\bufferPitchPlayer, [\bufnum, bufnum, \pitch, pitch, \amp, amp]);
}, '/playbuffer2');

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
