/*
    Copyright © 2023, Kitsunebi Games
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module kon.generators.basic.posc;
import kon.generators;

/**
    A phase oscillator that generates a steady phase
*/
class PhaseOSC(T) : KonOSC!T {
@nogc:
nothrow:
public:

    /**
        Gets the next oscillator sample
    */
    override
    T nextSample() {
        _phase += _phaseDelta;
        if (_phase > 1) _phase -= 1;

        return _phase;
    }
}