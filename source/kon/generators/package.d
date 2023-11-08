module kon.generators;
import dplug.core;

abstract
class KonOSC(T) {
@nogc:
nothrow:
protected:
    T _phase = 0;
    T _phaseDelta = 0;
    T _oscRate = 0;
    T _sampleRate = 0;

    final
    void recalculateDelta() {
        this._phaseDelta = _oscRate / sampleRate; 
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
    void setRate(T rate) {
        _oscRate = rate;
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