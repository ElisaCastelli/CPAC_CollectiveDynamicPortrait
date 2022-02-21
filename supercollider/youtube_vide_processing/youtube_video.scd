(
s.waitForBoot{
	fork{

		~b1=Buffer.read(s,"/Users/annar/Documents/GitHub/CPAC_CollectiveDynamicPortrait/supercollider/youtube_vide_processing/dontstop_level_3.wav");
		~bus1=Bus.control(s);
		~proc=NetAddr("127.0.0.1",12321);

		SynthDef(\sampy,{
			arg buf,kbs;
			var sig,rms;
			sig=PlayBuf.ar(1,buf,loop:1);
			rms=Amplitude.kr(sig).ampdb.linlin(-30.0,0.0,0.0,1.0);
			Out.kr(kbs,rms);
			Out.ar(0,sig);
		}).add;

		OSCdef(\getamp,{
			~proc.sendMsg("/amp1",~bus1.getSynchronous.asFloat);

		},"/getamp");

		0.1.wait;

		~s1=Synth(\sampy,[\buf,~b1, \kbs,~bus1]);
	}
}
)
~bus1.getSynchronous.asFloat
~s1.free;

