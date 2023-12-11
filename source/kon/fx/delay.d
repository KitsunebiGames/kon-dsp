module kon.fx.delay;
import kon.fx;
import dplug.dsp;
import dplug.dsp.window;
import dplug.core;

/**
    A digital delay with heavy inspiration taken from ddsp's DigitalDelay.
*/
class KonDelay(T) : KonFX!T {
nothrow:
@nogc:
private:
    Delayline!T _delayLine;

    size_t _size = 0;

    T _msDelay = 1;
    T _mix = 1;

    size_t delayInSamples() {
        return cast(size_t)(_msDelay * (_sampleRate / 1000.0));
    }

public:
    /// Destructor
    ~this() {
        destroyNoGC(_delayLine);
    }

    /// Constructor
    this() { }

    /**
        Sets the sample rate
    */
    override
    void setSampleRate(T sampleRate) {
        super.setSampleRate(sampleRate);
        
        _size = cast(size_t)sampleRate+1;
        _delayLine.resize(cast(int)_size);
    }

    /**
        Resets the delay
    */
    override
    void reset() {
        
        // Resize delay buffer if need be.
        size_t delaySamples = delayInSamples();
        if (delaySamples > _size) {
            _size = delaySamples;
            _delayLine.resize(cast(int)_size);
        }
    }

    override
    T nextSample(T input) {
        _delayLine.feedSample(input);
        T smpDelay = delayInSamples();
        return (_mix * _delayLine.sampleSpline4(smpDelay)) + ((1.0-_mix) * input);
    }

    /**
        Sets the delay
    */
    void setDelay(T msDelay) {
        _msDelay = msDelay;
        reset();
    }

    /**
        Sets effect wet/dry
    */
    void setMix(T mix) {
        _mix = mix;
    }
}