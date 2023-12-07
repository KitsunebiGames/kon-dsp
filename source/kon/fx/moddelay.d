module kon.fx.moddelay;
import kon.fx.delay;
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
    KonDelay!T _delay;
    KonBasicOSC!T _osc;

    T _modRate = 0;
    T _modDepth = 1;
    T _mix = 1;
    T _feedback = 0;
    T _delayOffset = 0;

    T _maxDelay = 1;
    T _minDelay = 0;

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
        _delay = mallocNew!(KonDelay!T)();
        _osc = mallocNew!(KonBasicOSC!T)();
        _osc.setShape(BasicOSCShape.sine);
    }

    /**
        Sets the delay range
    */
    void setDelayRange(T minDelay, T maxDelay) {
        _minDelay = minDelay;
        _maxDelay = maxDelay;

        _delay.setDelay(maxDelay);
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
        _delay.setMix(_mix);
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
        _delay.setSampleRate(sampleRate);
    }

    override
    T nextSample(T input) {
        T fYn = _osc.nextSample();
        T delaySamples = calcDelayOffset(fYn);
        _delay.setDelay(delaySamples);
        return _delay.nextSample(input);
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
        delay.setModDepth(1);
        delay.setModRate(1);
        delay.setMix(1);
    }

    override 
    void setSampleRate(T sampleRate) {
        super.setSampleRate(sampleRate);
        delay.setSampleRate(sampleRate);
        delay.setDelayRange(1, 7);
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
        Sets the mix of the chorus
    */
    void setMix(T mix) {
        delay.setMix(mix);
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
        delay.setModDepth(0.25);
        delay.setModRate(1);
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
        Sets the mix of the chorus
    */
    void setMix(T mix) {
        delay.setMix(mix*0.5);
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