module kon.fx;

abstract
class KonFX(T) {
nothrow:
@nogc:
protected:
    T _sampleRate = 0;

public:

    /**
        Processes the next sample of the effect
    */
    abstract T nextSample(T input);

    /**
        Reset state of FX.
    */
    abstract void reset();

    /**
        Sets the sample rate
    */
    void setSampleRate(T sampleRate) {
        _sampleRate = sampleRate;
    }
}