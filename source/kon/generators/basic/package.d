/*
    Copyright © 2023, Kitsunebi Games
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module kon.generators.basic;
import kon.generators;
import dplug.core.math;

public import kon.generators.basic.polyblep;

enum BasicOSCShape {
    /// Sine Wave
    sine,

    /// Saw wave
    saw,

    /// Triangle wave
    triangle,

    /// Pulse/Square wave
    pulse
}

abstract
class KonBasicOSC(T) : KonOSC!T {
@nogc:
nothrow:
protected:
    BasicOSCShape _oscShape;
    T _pulseWidth;

public:

    override
    T nextSample() {
        T nSample = 0;

        switch(_oscShape) {

            // Sine Wave
            case BasicOSCShape.sine:
                nSample = fast_sin(_phase * PI);
                break;

            // Saw Wave
            case BasicOSCShape.saw:
                nSample = rawSawtooth(_phase);
                break;
            
            // Square and Pulse Wave
            case BasicOSCShape.pulse:
                nSample = _phase <= _pulseWidth ? 1 : 0;
                break;
            
            // Triangle Wave
            case BasicOSCShape.triangle:
                nSample = rawTriangle(_phase);
                break;

            // Something went wrong!!
            default: assert(0, "Tried to generate non-existent osc shape!");
        }

        _phase += _phaseDelta;
        if (_phase > 1) _phase -= 1;
        return nSample;
    }

    /**
        Sets the pulse width for square waves.
        By default 0.5
    */
    void setPulseWidth(T width) {
        _pulseWidth = width;
    }

    /**
        Gets the pulse width
    */
    T getPulseWidth() {
        return _pulseWidth;
    }

    /**
        Sets the shape of the basic oscillator
    */
    void setShape(BasicOSCShape shape) {
        _oscShape = shape;
    }

    /**
        Gets the shape of the basic oscillator
    */
    BasicOSCShape getShape() {
        return _oscShape;
    }
}