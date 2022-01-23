(
"hello world".postln
)

(
var greeting;

greeting = "hello world";
greeting.postln;
)


(
var syn, sound;
syn = SynthDef.new("example1", {
Out.ar(0, SinOsc.ar(440));
});
syn.load(s);
sound = Synth.new("example1");
)