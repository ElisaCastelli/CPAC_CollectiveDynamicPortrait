s.boot;

s.meter;
s.plotTree;

//s.reboot;

//s.quit;

b = Buffer.alloc(s,44100 * 8.0,2);

~sound = b.read(s, "/Users/franc/Documents/GitHub/CPAC_CollectiveDynamicPortrait/supercollider/basic_composition.wav");
~sound.play;