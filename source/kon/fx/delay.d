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
    WindowDesc _delayWindow;

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
    this() {
        _delayWindow = WindowDesc(WindowType.blackmannHarris, WindowAlignment.right);
    }

    /**
        Sets the sample rate
    */
    override
    void setSampleRate(T sampleRate) {
        super.setSampleRate(sampleRate);
        reset();
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
            _delayLine.resize(_size);
        }
    }

    override
    T nextSample(T input) {
        _delayLine.feedSample(input);
        return ((1.0-_mix) * _delayLine.sampleFull(delayInSamples)) + (_mix * input);
    }

    /**
        Sets the delay
    */
    void setDelay(T msDelay) {
        _msDelay = msDelay;
        reset();
    }
}