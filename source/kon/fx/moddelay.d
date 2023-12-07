module kon.fx.moddelay;
import kon.generators.basic;
import kon.fx;
import dplug.core;
import dplug.dsp;
import std.algorithm.comparison;

/**
    Modulator delay
*/
class KonModDelay(T) : KonFX!T {
nothrow:
@nogc:
private:
    Delayline!T _delayLine;
    KonBasicOSC!T _osc;

    T _modRate;
    T _modDepth;
    T _mix;
    T _feedback;
    T _delayOffset;

    T _maxDelay;
    T _minDelay;

    T calcDelayOffset(T lfoValue) {
        T startDelay = _minDelay + _delayOffset;
        T lfoOffset = _modDepth * ((lfoValue + 1) / 2 * (_maxDelay - _minDelay)) + _minDelay;
        return max(lfoOffset + startDelay, 0);
    }

public:

    /**
        Initializes the mod delay
    */
    this() {
        _delayLine.initialize(1024);
        _osc = mallocNew!(KonBasicOSC!T)();
        _osc.setShape(BasicOSCShape.sine);
    }

    /**
        Sets the delay range
    */
    void setDelayRange(T minDelay, T maxDelay) {
        _minDelay = minDelay;
        _maxDelay = maxDelay;

        if (_sampleRate != 0) {
            _delayLine.resize(cast(int)(_maxDelay*_sampleRate));
        }
    }

    /**
        Sets the rate of the modulator
    */
    void setModRate(T modRate) {
        _modRate = modRate;
        _osc.setFrequency(modRate);
    }

    /**
        Sets the modulator depth
    */
    void setModDepth(T modDepth) {
        _modDepth = modDepth;
    }

    /**
        Sets the mix level
    */
    void setMix(T mix) {
        _mix = mix;
    }

    /**
        Sets the delay feedback
    */
    void setFeedback(T feedback) {
        _feedback = feedback;
    }

    /**
        Sets the offset
    */
    void setOffset(T offset) {
        _delayOffset = offset;
    }

    /**
        Updates the sample rate
    */
    override
    void setSampleRate(T sampleRate) {
        super.setSampleRate(sampleRate);
        _osc.setSampleRate(sampleRate);

        if (_maxDelay != 0) {
            _delayLine.resize(cast(int)(_maxDelay*sampleRate));
        }
    }

    override
    T nextSample(T input) {
        T fYn = _osc.nextSample();
        T delaySamples = calcDelayOffset(fYn);
        _delayLine.feedSample(input);
        return _delayLine.sampleSpline4(cast(float)delaySamples);
    }

    override
    void reset() {
        _osc.reset();
    }

}

/**
    A Vibrato effect.
*/
class KonVibrato(T) : KonFX!T {
nothrow:
@nogc:
private:
    KonModDelay!T delay;

public:

    this() {
        delay = mallocNew!(KonModDelay!T)();
    }

    override 
    void setSampleRate(T sampleRate) {
        super.setSampleRate(sampleRate);
        delay.setSampleRate(sampleRate);
        delay.setDelayRange(0, 7);
        delay.setMix(1);
    }

    /**
        Sets the depth of the vibrato
    */
    void setDepth(T depth) {
        delay.setModDepth(depth);
    }

    /**
        Sets the rate of the vibrato
    */
    void setRate(T rate) {
        delay.setModRate(rate);
    }

    /**
        Gets the next sample
    */
    override
    T nextSample(T input) {
        return delay.nextSample(input);
    }

    /**
        Resets the vibrato
    */
    override
    void reset() {
        delay.reset();
    }
}

/**
    A Chorus effect.
*/
class KonChorus(T) : KonFX!T {
nothrow:
@nogc:
private:
    KonModDelay!T delay;

public:

    this() {
        delay = mallocNew!(KonModDelay!T)();
    }

    override 
    void setSampleRate(T sampleRate) {
        super.setSampleRate(sampleRate);
        delay.setSampleRate(sampleRate);
        delay.setDelayRange(5, 30);
        delay.setMix(0.5);
    }

    /**
        Sets the depth of the chorus
    */
    void setDepth(T depth) {
        delay.setModDepth(depth);
    }

    /**
        Sets the rate of the chorus
    */
    void setRate(T rate) {
        delay.setModRate(rate);
    }

    /**
        Gets the next sample
    */
    override
    T nextSample(T input) {
        return delay.nextSample(input);
    }

    /**
        Resets the chorus
    */
    override
    void reset() {
        delay.reset();
    }
}