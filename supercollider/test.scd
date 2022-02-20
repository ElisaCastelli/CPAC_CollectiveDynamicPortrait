

/*

Simple GUI to generate scale and arpeggio segments of an overtone row above a given fundamental. This is the first GUI I've programmed, so it's certainly not perfect: most notably, all the numbers have to be typed into the boxes before the pattern will run. Feel free to contact me if you have any questions or feedback!

For non-experienced users: click in row 9 where it says "click here" and press CTRL+ENTER. Start with low volume to be safe :)

*/

( // click here
s.waitForBoot({ // GUI


var numButtons = 4;
var numSliders = 5;
var numNumberBoxes = 3;
var numLabels0 = 5;
var numLabels1 = 3;
var buttons, sliders, numberBoxes, labels0, labels1, sliderLayout, buttonLayout, numberBoxesLayout, labelsLayout0, labelsLayout1, layout, menu;

Window.closeAll;
w = Window.new;

// objects

buttons = numButtons.collect{
	Button.new
};

sliders = numSliders.collect{
	Slider.new.orientation_(\horizontal)
};

numberBoxes = numNumberBoxes.collect{
	NumberBox.new
};

labels0 = numLabels0.collect{
	StaticText.new
};

labels1 = numLabels1.collect{
	StaticText.new
};

menu = PopUpMenu.new;

// layout

buttonLayout = HLayout.new(*buttons);
sliderLayout = VLayout.new(*sliders);
numberBoxesLayout = HLayout.new(*numberBoxes);
labelsLayout0 = VLayout.new(*labels0);
labelsLayout1 = HLayout.new(*labels1);

//layout = VLayout(sliderLayout, buttonLayout, numberBoxesLayout);
layout = VLayout(HLayout(labelsLayout0, sliderLayout), HLayout(buttonLayout, menu), VLayout(numberBoxesLayout, labelsLayout1));


// sliders

// Slider 0 - change dur
sliders[0].action_({|obj|
	var val = obj.value;

	// Scale duration, make sure it is not zero
	val = val.linlin(0.0, 1.0, 2.0, 0.1);
	~dur = val;
	Pdefn(\pDur, ~dur)
});

// Slider 1 - change atk
sliders[1].action_({|obj|
	var val = obj.value;
	val = val.linlin(0.0, 1.0, 0.01, 0.3);
	~atk = val;
	Pdefn(\pAtk, ~atk)
});

// Slider 2 - change rel
sliders[2].action_({|obj|
	var val = obj.value;
	val = val.linlin(0.0, 1.0, 0.5, 10);
	~rel = val;

	Pdefn(\pRel, ~rel)
});

// Slider 3 - change amp
sliders[3].action_({|obj|
	var val = obj.value;
	val = val.linlin(0.0, 1.0, 0.0, 0.75);
	~amp = val;
	Pdefn(\pAmp, ~amp)
});

// Slider 4 - change bass amp
~slider4 = sliders[4].action_({|obj|
	var bassAmp = obj.value;
	bassAmp = bassAmp.linlin(0.0, 1.0, 0.05, 0.75);
	~bassAmp = bassAmp;
	//x.set(\amp, bassAmp);
	if(
		x.isPlaying,
		{x.set(\amp, ~bassAmp)}
	)
});

// numberBoxes

numberBoxes[0].value_(55)
.clipLo_(30)
.clipHi_(120)
.action_({
	arg obj; var val;
	val = obj.value;
	~fundamental = val;
	Pdefn(\fundamental, ~fundamental);
	//x.set(\fundamental, ~fundamental);
	if(
		x.isPlaying,
		{x.set(\fundamental, ~fundamental)}
	)
})

;

numberBoxes[1].value_(10)
.step_(1)
.clipLo_(5)
.clipHi_(30)
.action_({
	arg obj;
	var val = obj.value;
	~startPartial = val;
	Pdefn(\startPartial, ~startPartial)
});

numberBoxes[2].value_(5)
.step_(1)
.clipLo_(2)
.clipHi_(30)
.action_({
	arg obj;
	var val = obj.value;
	~numNotes = val;
	Pdefn(\numNotes, ~numNotes)
});

// buttons

// Start pattern
buttons[0].states_([["Start Pattern", Color.black, Color.gray]]).action_({|obj|
	Pbindef(\pattern).play;
	y = Synth(\reverb, [\in, ~reverbBus]);
});


// Stop pattern
buttons[1].states_([["Stop Pattern", Color.black, Color.gray]]).action_({|obj|
	Pbindef(\pattern).stop;
	y.free;
});


// Start bass note - to do, try out pmono
buttons[2].states_([["Start Bass Note", Color.black, Color.gray]]).action_({|obj|
	x = Synth(\bass, [\fundamental, ~fundamental.value, \amp, ~slider4.value]).register
});


// Stop bass note
buttons[3].states_([["Stop Bass Note", Color.black, Color.gray]]).action_({|obj|
	x.free;
});

// Scale or arpeggio
/*
buttons[4].states_([["Scale", Color.black, Color.gray], ["Arpeggio", Color.black, Color.gray]]).action_({
	|obj| var val;
	val = obj.value;
	~step = val + 1;
	Pdefn(\step, ~step)

});
*/

// popup menu

menu.items_(["Scale ascending", "Scale descending", "Small Arpeggio ascending", "Small Arpeggio descending", "Big Arpeggio ascending", "Big Arpeggio descending"])
.action_(
	{
		arg menu;
		var val = menu.value;
		case
		{val == 0} {~step = 1}
		{val == 1} {~step = -1}
		{val == 2} {~step = 2}
		{val == 3} {~step = -2}
		{val == 4} {~step = 3}
		{val == 5} {~step= -3};
		Pdefn(\step, ~step);
	}
);

// labels - fund, bass amp, start partial, num notes

labels0[0].string_("Speed");
labels0[1].string_("Attack");
labels0[2].string_("Release");
labels0[3].string_("Volume");
labels0[4].string_("Bass Volume");
labels1[0].string_("Fundamental");
labels1[1].string_("Start Partial");
labels1[2].string_("Scale Length");


// tidying up

w.layout = layout;
w.front;



// reverb

~reverbBus = Bus.alloc(\audio, s, 2);


SynthDef(\reverb, {
	arg in=0, out=0;
	var sig;

	sig = In.ar(in, 2);
	sig = FreeVerb.ar(sig);
	Out.ar(out, sig);
}).add;



// sounds


SynthDef(\blip, {
	arg fundamental=55, ratio=10, amp=0.25, pan=0, atk=0.02, rel=0.1, out=0;
	var sig, env;

	env = Env.perc(atk, rel);
	env = EnvGen.ar(env, doneAction: 2);

	sig = SinOsc.ar(fundamental.lag(0.5) * ratio);
	sig = sig * env * amp.lag(0.5);
	sig = Pan2.ar(sig, pan);
	//sig = FreeVerb.ar(sig);
	//sig = HPF.ar(sig, 30);
	//DetectSilence.ar(sig, doneAction: 2);
	Out.ar(out, sig);
}).add;




SynthDef(\bass, {
	arg fundamental=55, amp=0.25, pan=0, out=0, lfo=0.1, lpf=1000;
	var sig, moog;

	moog = LFNoise1.ar(lfo).exprange(200, 4000);

	sig = LFSaw.ar(fundamental.lag(0.5));
	sig = MoogFF.ar(sig, moog);
	sig = LPF.ar(sig, lpf);
	sig = sig * amp.lag(0.5);
	sig = Pan2.ar(sig, pan);
	sig = FreeVerb.ar(sig);

	Out.ar(out, sig);
}).add;

// basic pattern to control


Pbindef(\pattern,

	\instrument, \blip,
	\dur, Pdefn(\pDur),
	\ratio, Pseq([Pseries(Pdefn(\startPartial).asStream, Pdefn(\step), Pdefn(\numNotes).asStream)], inf),
	\fundamental, Pdefn(\fundamental),
	\amp, Pdefn(\pAmp),
	\atk, Pdefn(\pAtk),
	\rel, Pdefn(\pRel),
	\pan, 0,
	//\out, 0
	\out, ~reverbBus
);

// variables initial values

~dur = 1.0;
~atk = 0.05;
~rel = 0.1;
~amp = 0.25;
~bassAmp = 0.3;
~fundamental = 55;
~startPartial = 10;
~numNotes = 5;
~step = 1;

};
);
)

raw 6396 chars (focus & ctrl+a+c to copy)
/*



Simple GUI to generate scale and arpeggio segments of an overtone row above a given fundamental. This is the first GUI I've programmed, so it's certainly not perfect: most notably, all the numbers have to be typed into the boxes before the pattern will run. Feel free to contact me if you have any questions or feedback!



For non-experienced users: click in row 9 where it says "click here" and press CTRL+ENTER. Start with low volume to be safe :)



*/



( // click here

s.waitForBoot({ // GUI





var numButtons = 4;

var numSliders = 5;

var numNumberBoxes = 3;

var numLabels0 = 5;

var numLabels1 = 3;

var buttons, sliders, numberBoxes, labels0, labels1, sliderLayout, buttonLayout, numberBoxesLayout, labelsLayout0, labelsLayout1, layout, menu;



Window.closeAll;

w = Window.new;



// objects



buttons = numButtons.collect{

	Button.new

};



sliders = numSliders.collect{

	Slider.new.orientation_(\horizontal)

};



numberBoxes = numNumberBoxes.collect{

	NumberBox.new

};



labels0 = numLabels0.collect{

	StaticText.new

};



labels1 = numLabels1.collect{

	StaticText.new

};



menu = PopUpMenu.new;



// layout



buttonLayout = HLayout.new(*buttons);

sliderLayout = VLayout.new(*sliders);

numberBoxesLayout = HLayout.new(*numberBoxes);

labelsLayout0 = VLayout.new(*labels0);

labelsLayout1 = HLayout.new(*labels1);



//layout = VLayout(sliderLayout, buttonLayout, numberBoxesLayout);

layout = VLayout(HLayout(labelsLayout0, sliderLayout), HLayout(buttonLayout, menu), VLayout(numberBoxesLayout, labelsLayout1));





// sliders



// Slider 0 - change dur

sliders[0].action_({|obj|

	var val = obj.value;



	// Scale duration, make sure it is not zero

	val = val.linlin(0.0, 1.0, 2.0, 0.1);

	~dur = val;

	Pdefn(\pDur, ~dur)

});



// Slider 1 - change atk

sliders[1].action_({|obj|

	var val = obj.value;

	val = val.linlin(0.0, 1.0, 0.01, 0.3);

	~atk = val;

	Pdefn(\pAtk, ~atk)

});



// Slider 2 - change rel

sliders[2].action_({|obj|

	var val = obj.value;

	val = val.linlin(0.0, 1.0, 0.5, 10);

	~rel = val;



	Pdefn(\pRel, ~rel)

});



// Slider 3 - change amp

sliders[3].action_({|obj|

	var val = obj.value;

	val = val.linlin(0.0, 1.0, 0.0, 0.75);

	~amp = val;

	Pdefn(\pAmp, ~amp)

});



// Slider 4 - change bass amp

~slider4 = sliders[4].action_({|obj|

	var bassAmp = obj.value;

	bassAmp = bassAmp.linlin(0.0, 1.0, 0.05, 0.75);

	~bassAmp = bassAmp;

	//x.set(\amp, bassAmp);

	if(

		x.isPlaying,

		{x.set(\amp, ~bassAmp)}

	)

});



// numberBoxes



numberBoxes[0].value_(55)

.clipLo_(30)

.clipHi_(120)

.action_({

	arg obj; var val;

	val = obj.value;

	~fundamental = val;

	Pdefn(\fundamental, ~fundamental);

	//x.set(\fundamental, ~fundamental);

	if(

		x.isPlaying,

		{x.set(\fundamental, ~fundamental)}

	)

})



;



numberBoxes[1].value_(10)

.step_(1)

.clipLo_(5)

.clipHi_(30)

.action_({

	arg obj;

	var val = obj.value;

	~startPartial = val;

	Pdefn(\startPartial, ~startPartial)

});



numberBoxes[2].value_(5)

.step_(1)

.clipLo_(2)

.clipHi_(30)

.action_({

	arg obj;

	var val = obj.value;

	~numNotes = val;

	Pdefn(\numNotes, ~numNotes)

});



// buttons



// Start pattern

buttons[0].states_([["Start Pattern", Color.black, Color.gray]]).action_({|obj|

	Pbindef(\pattern).play;

	y = Synth(\reverb, [\in, ~reverbBus]);

});





// Stop pattern

buttons[1].states_([["Stop Pattern", Color.black, Color.gray]]).action_({|obj|

	Pbindef(\pattern).stop;

	y.free;

});





// Start bass note - to do, try out pmono

buttons[2].states_([["Start Bass Note", Color.black, Color.gray]]).action_({|obj|

	x = Synth(\bass, [\fundamental, ~fundamental.value, \amp, ~slider4.value]).register

});





// Stop bass note

buttons[3].states_([["Stop Bass Note", Color.black, Color.gray]]).action_({|obj|

	x.free;

});



// Scale or arpeggio

/*

buttons[4].states_([["Scale", Color.black, Color.gray], ["Arpeggio", Color.black, Color.gray]]).action_({

	|obj| var val;

	val = obj.value;

	~step = val + 1;

	Pdefn(\step, ~step)



});

*/



// popup menu



menu.items_(["Scale ascending", "Scale descending", "Small Arpeggio ascending", "Small Arpeggio descending", "Big Arpeggio ascending", "Big Arpeggio descending"])

.action_(

	{

		arg menu;

		var val = menu.value;

		case

		{val == 0} {~step = 1}

		{val == 1} {~step = -1}

		{val == 2} {~step = 2}

		{val == 3} {~step = -2}

		{val == 4} {~step = 3}

		{val == 5} {~step= -3};

		Pdefn(\step, ~step);

	}

);



// labels - fund, bass amp, start partial, num notes



labels0[0].string_("Speed");

labels0[1].string_("Attack");

labels0[2].string_("Release");

labels0[3].string_("Volume");

labels0[4].string_("Bass Volume");

labels1[0].string_("Fundamental");

labels1[1].string_("Start Partial");

labels1[2].string_("Scale Length");





// tidying up



w.layout = layout;

w.front;







// reverb



~reverbBus = Bus.alloc(\audio, s, 2);





SynthDef(\reverb, {

	arg in=0, out=0;

	var sig;



	sig = In.ar(in, 2);

	sig = FreeVerb.ar(sig);

	Out.ar(out, sig);

}).add;







// sounds





SynthDef(\blip, {

	arg fundamental=55, ratio=10, amp=0.25, pan=0, atk=0.02, rel=0.1, out=0;

	var sig, env;



	env = Env.perc(atk, rel);

	env = EnvGen.ar(env, doneAction: 2);



	sig = SinOsc.ar(fundamental.lag(0.5) * ratio);

	sig = sig * env * amp.lag(0.5);

	sig = Pan2.ar(sig, pan);

	//sig = FreeVerb.ar(sig);

	//sig = HPF.ar(sig, 30);

	//DetectSilence.ar(sig, doneAction: 2);

	Out.ar(out, sig);

}).add;









SynthDef(\bass, {

	arg fundamental=55, amp=0.25, pan=0, out=0, lfo=0.1, lpf=1000;

	var sig, moog;



	moog = LFNoise1.ar(lfo).exprange(200, 4000);



	sig = LFSaw.ar(fundamental.lag(0.5));

	sig = MoogFF.ar(sig, moog);

	sig = LPF.ar(sig, lpf);

	sig = sig * amp.lag(0.5);

	sig = Pan2.ar(sig, pan);

	sig = FreeVerb.ar(sig);



	Out.ar(out, sig);

}).add;



// basic pattern to control





Pbindef(\pattern,



	\instrument, \blip,

	\dur, Pdefn(\pDur),

	\ratio, Pseq([Pseries(Pdefn(\startPartial).asStream, Pdefn(\step), Pdefn(\numNotes).asStream)], inf),

	\fundamental, Pdefn(\fundamental),

	\amp, Pdefn(\pAmp),

	\atk, Pdefn(\pAtk),

	\rel, Pdefn(\pRel),

	\pan, 0,

	//\out, 0

	\out, ~reverbBus

);



// variables initial values



~dur = 1.0;

~atk = 0.05;

~rel = 0.1;

~amp = 0.25;

~bassAmp = 0.3;

~fundamental = 55;

~startPartial = 10;

~numNotes = 5;

~step = 1;



};

);

)
Tweet
reception
comments