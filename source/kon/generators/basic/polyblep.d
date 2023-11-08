module kon.generators.basic.polyblep;
import kon.generators;
import kon.generators.basic;

import dplug.core.math;

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
        if (t < _phaseDelta) {
            t /= _phaseDelta;
            return t+t - t*t - 1.0;
        } else if (t > 1.0 - _phaseDelta) {
            t = (t - 1.0) / dt;
            return t*t + t+t + 1.0;
        }

        return 0;
    }
public:

    override
    T nextSample() {
        T nSample = super.nextSample();

        switch(_oscShape) {
            default: break;

            // Sine waves are already band limited
            case BasicOSCShape.sine: break;

            // Saw Wave
            case BasicOSCShape.saw:
                nSample -= polyblep(_phase);
                break;
            
            // Square and Pulse Wave
            case BasicOSCShape.pulse:
                nSample += polyblep(t);
                nSample -= polyblep(fmod(t + _pulseWidth, 1.0));
                break;
            
            // Triangle Wave
            case BasicOSCShape.triangle:
                nSample = _phase * value + (1 - _phaseDelta) * _lastOutput;
                _lastOutput = nSample;
                break;
        }

        return nSample;
    }
    
}