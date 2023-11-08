/*
    Copyright © 2023, Kitsunebi Games
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module kon.generators;
import dplug.core;
import std.math;

/**
    Base class of all oscillators
*/
abstract
class KonOSC(T) {
@nogc:
nothrow:
protected:
    T _phase = 0;
    T _phaseDelta = 0;
    T _oscFreq = 0;
    T _sampleRate = 0;

    final
    void recalculateDelta() {
        this._phaseDelta = _oscFreq * cast(T)TAU / _sampleRate; 
    }

public:

    /**
        Gets the next oscillator sample
    */
    abstract T nextSample();

    /**
        Sets the samplerate of the oscillator
    */
    void setSampleRate(T sampleRate) {
        _sampleRate = sampleRate;
        this.recalculateDelta();
    }

    /**
        Sets the oscillator rate
    */
    void setFrequency(T freq) {
        _oscFreq = freq;
        this.recalculateDelta();
    }

    /**
        Resets the oscillator position
    */
    void reset() {
        _phase = 0;
    }

    /**
        Gets the phase of the oscillator 0..1
    */
    final
    float getPhase() {
        return _phase;
    }
}