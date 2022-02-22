# %% Import libraries
from unittest import case
import numpy as np
import os
import sys
import soundfile as sf
os.chdir(os.path.dirname(os.path.abspath(__file__)))
from classes import Composer, Grammar_Sequence
from numpy import array

# import libraries for wav handling
from pydub import AudioSegment 
from pydub.playback import play 

import librosa


acousticness = float(sys.argv[1])
valence = float(sys.argv[2])
energy = float(sys.argv[3])
speechiness = float(sys.argv[4])
tempo = float(sys.argv[5])
danceability = float(sys.argv[6])
mode = float(sys.argv[7])
n_user = int(sys.argv[8])

# first sound is determined by acousticness and energy
def first_composer():
    if acousticness > 0.2 and energy > 0.5:
        return "sound14.wav"
    if acousticness > 0.2 and energy <= 0.5:
        return "sound13.wav"
    if acousticness < 0.2 and energy > 0.5:
        return "sound12.wav"
    else:
        return "sound11.wav"

def second_composer():
    return "sound21.wav"

composers = {
    1: first_composer,
    2: second_composer,
}



# ==== GRAMMARS
basic_grammar={
    "S":["M", "SM"],
    "M": ["HH"],    
    "H": ["h", "qq"],
}

slow_grammar={
    "S":["M", "SM"],
    "M": ["HH","w", "$w"],    
    "H": ["h", "$h"],
}

octave_grammar={
    "S":["M", "SM"],
    "M": ["HH"],    
    "H": ["h", "QQ"],
    "Q": ["q", "oo"],
}

triplet_grammar={
    "S":["M", "SM"],
    "M": ["HH", "ththth"],    
    "H": ["h", "QQ","tqtqtq","$h"],
    "Q": ["q", "OO", "oo", "tototo","$q"],
    "O": ["o", "$o"]
}
upbeat_grammar={
    "S":["M", "SM"],
    "M": ["HH", "ththth","VVV", "QHQ"],    
    "H": ["h", "QQ","tqtqtq","$h", "otototoo", "OQO"],
    "V": ["th", "ph"], 
    "Q": ["q", "OO", "oo", "tototo","$q", "potopo", "popoto"],
    "O": ["o", "$o"]
}

word_dur={"h":0.5, # half-measure
          "q":0.25, # quarter-measure
          "o":1/8, # octave-measure
          "$h": 0.5,
          "$q": 0.25,
          "$o": 1/8,
          "th": 1/3,
          "tq": 1/6,
          "to": 1/12,
          "ph": 1/3,
          "pq": 1/6,
          "po": 1/12,
          "w": 1,
          "$w": 1,          
}

class Track:
    def __init__(self, composer, grammar, gain, sr):
        self.composer=composer
        self.grammar=grammar
        self.gain=gain
        self.sr=sr
    def create_sequence(self, start_sequence):
        self.grammar.create_sequence(start_sequence)                    
        self.composer.create_sequence(self.grammar.sequence)
    
# write_mix
def write_mix(tracks, fn_out="out.wav"):
    max_size=0
    for track in tracks:
        max_size=max(max_size, track.composer.sequence.size)
    total_track=np.zeros((len(tracks), max_size))
    for i, track in enumerate(tracks):
        total_track[i, 0:track.composer.sequence.size]=track.gain*track.composer.sequence
    total_track = np.sum(total_track, axis=0)                            
    total_track=0.707*total_track/np.max(np.abs(total_track))
    sf.write(fn_out, total_track, track.sr)


# %% main script
if __name__=="__main__":
    
    NUM_M = 2
    START_SEQUENCE = "M"*NUM_M
    SR=44100
    BPM=120


    samples=[composers[n_user]()]
    grammars=[basic_grammar]
    gains = [1]
    
    tracks=[]
    single_track = []

    # output the sigle track composed by the current user 
    track=Track(Composer("sounds/"+samples[0], word_dur, BPM=50, sr=SR),
                Grammar_Sequence(grammars[0]), gains[0], SR)
    track.create_sequence(START_SEQUENCE)
    single_track.append(track)

    single_track_name = "out/composition" + str(n_user) + ".wav"
    write_mix(single_track, fn_out=single_track_name)
    
    # export final mix


    for i in range(0, n_user):
        # import and decrease gain according to number of tracks
        single_track_name = "out/composition" + str(i+1) + ".wav"
        wav_file, sample_rate = librosa.load(single_track_name, mono=True)
        #wav_file = AudioSegment.from_file(file = single_track_name, format = "wav") - (n_user-1)
        if i == 0:
            final_mix = wav_file
        else:
            final_mix += wav_file

    final_mix = final_mix / n_user

    # soundfile.write(file, data, samplerate, subtype=None, endian=None, format=None, closefd=True)
    sf.write("out/current_mix.wav", final_mix, sample_rate)
    # librosa.soundfile.write_wav('out/current_mix.wav', final_mix, sample_rate)
    #final_mix.export(out_f = "out/current_mix.wav", format = "wav")