/*
    Copyright © 2023, Kitsunebi Games
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module kon.generators.basic.polyblep;
import kon.generators;
import kon.generators.basic;

import dplug.core.math;
import std.math : fmod;

/**
    A band limited basic oscillator
*/
class KonPolyBLEPOSC(T) : KonBasicOSC!T {
@nogc:
nothrow:
private:
    // For saw
    T _lastOutput = 0;

    // Polyblep implementation
    T polyblep(T t) {
        T dt = _phaseDelta / TAU;

        if (t < dt) {
            t /= dt;
            return t+t - t*t - 1.0;
        } else if (t > 1.0 - dt) {
             t = (t - 1.0) / dt;
            return t*t + t+t + 1.0;
        } else return 0.0;
    }
public:

    override
    T nextSample() {
        T t = _phase / TAU;
        T nSample = super.nextSample();

        switch(_oscShape) {
            default: break;

            // Sine waves are already band limited
            case BasicOSCShape.sine: break;

            // Saw Wave
            case BasicOSCShape.saw:
                nSample -= polyblep(t);
                break;
            
            // Square and Pulse Wave
            case BasicOSCShape.pulse:
                nSample += polyblep(t);
                nSample -= polyblep(fmod(t + _pulseWidth, 1.0));
                break;
            
            // Triangle Wave
            case BasicOSCShape.triangle:
                nSample = t * nSample + (1 - _phaseDelta) * _lastOutput;
                _lastOutput = nSample;
                break;
        }

        return nSample;
    }
    
}