/*
    Copyright © 2023, Kitsunebi Games
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module kon.env.adsr;
import dplug.core.math;
import std.algorithm.comparison : clamp;
import core.atomic : atomicLoad, atomicExchange;

/**
    The state of an ADSR envelope.
*/
enum ADSRState : int {
    idle,
    attack,
    decay,
    sustain,
    release
}

/**
    ADSR Envelope Generator
*/
struct ADSR {
nothrow:
@nogc:
private:
    ADSRState state = ADSRState.idle;
    float output = 0;

    float baseAttackRate = 0;
    float baseDecayRate = 0;
    float baseReleaseRate = 0;

    float attackRate = 0;
    float decayRate = 0;
    float releaseRate = 0;

    float attackCoefficient = 0;
    float decayCoefficient = 0;
    float releaseCoefficient = 0;

    float attackBase = 0;
    float decayBase = 0;
    float releaseBase = 0;

    float targetRatioAttack = 0;
    float targetRatioDecayRelease = 0;

    float sustainLevel = 0;

    float sampleRate = 0;
    bool gate = false;

    float calculateCoefficient(float rate, float ratio) {
        return fast_exp(-fast_log((1.0 + ratio) / ratio) / rate);
    }

public:
    static ADSR createNew() {
        ADSR adsr;

        adsr.kill();
        adsr.setAttack(0);
        adsr.setDecay(0);
        adsr.setRelease(0);
        adsr.setSustain(1);
        adsr.setAttackCurve(0.3);
        adsr.setDecayReleaseCurve(0.0001);
        return adsr;
    }

    /**
        Sets the attack rate
    */
    void setAttack(float rate) {
        this.baseAttackRate = rate;
        this.attackRate = rate*sampleRate;
        this.attackCoefficient = calculateCoefficient(attackRate, targetRatioAttack);
        this.attackBase = (1.0 + targetRatioAttack) * (1.0 - attackCoefficient);
    }

    /**
        Sets the decay rate
    */
    void setDecay(float rate) {
        this.baseDecayRate = rate;
        this.decayRate = rate*sampleRate;
        this.decayCoefficient = calculateCoefficient(decayRate, targetRatioDecayRelease);
        this.decayBase = (sustainLevel - targetRatioDecayRelease) * (1.0 - decayCoefficient);
    }

    /**
        Sets the release rate
    */
    void setRelease(float rate) {
        this.baseReleaseRate = rate;
        this.releaseRate = rate*sampleRate;
        this.releaseCoefficient = calculateCoefficient(releaseRate, targetRatioDecayRelease);
        this.releaseBase = -targetRatioDecayRelease * (1.0 - releaseCoefficient);
    }

    /**
        Sets the sustain level
    */
    void setSustain(float v) {
        sustainLevel = clamp(v, 0, 1);
        this.decayBase = (sustainLevel - targetRatioDecayRelease) * (1.0 - decayCoefficient);
    }

    /**
        Sets attack curve, close to 0 for exponential, 100 for mostly linear
    */
    void setAttackCurve(float curve) {
        if (curve < 0.000000001)
            curve = 0.000000001;

        this.targetRatioAttack = curve;
        this.attackBase = (1.0 + targetRatioAttack) * (1.0 - attackCoefficient);
    }

    /**
        Sets decay-release curve, close to 0 for exponential, 100 for mostly linear
    */
    void setDecayReleaseCurve(float curve) {
        if (curve < 0.000000001)
            curve = 0.000000001;

        this.targetRatioDecayRelease = curve;
        this.decayBase = (sustainLevel - targetRatioDecayRelease) * (1.0 - decayCoefficient);
        this.releaseBase = -targetRatioDecayRelease * (1.0 - releaseCoefficient);
    }

    /**
        Resets the envelope sample rate info
    */
    void reset(float sampleRate) {
        this.sampleRate = sampleRate;
        this.setAttack(baseAttackRate);
        this.setDecay(baseDecayRate);
        this.setRelease(baseReleaseRate);
    }

    /**
        Kills the envelope, stopping the note playing
    */
    void kill() {
        this.gate = false;
        this.state = ADSRState.idle;
        this.output = 0;
    }

    /**
        Calculates the next sample of the envelope
    */
    float nextSample() {
        switch(state) {
            default: assert(0);

            case ADSRState.idle: break;
            case ADSRState.sustain: break;

            case ADSRState.attack: 
                if (attackRate == 0) {
                    output = 1.0;
                    state = ADSRState.decay;
                    break;
                }

                output = attackBase + output * attackCoefficient;
                if (output >= 1) {
                    output = 1.0;
                    state = ADSRState.decay;
                } 
                break;

            case ADSRState.decay:
                output = decayBase + output * decayCoefficient;
                if (output <= sustainLevel) {
                    output = sustainLevel;
                    state = ADSRState.sustain;
                } 
                break;

            case ADSRState.release:
                output = releaseBase + output * releaseCoefficient;
                if (output <= 0) {
                    output = 0;
                    state = ADSRState.idle;
                } 
                break;

        }
        return output;
    }

    /**
        Returns output
    */
    ref float getOutput() return {
        return output;
    }

    /**
        Returns output
    */
    float getOutputAtomic() return {
        return atomicLoad(output);
    }

    /**
        Sets the envelope to play
    */
    void play() {
        if (gate == false) {
            gate = true;
            state = ADSRState.attack;
        }
    }

    /**
        Sets the envelope to release
    */
    void release() {
        if (gate == true) {
            gate = false;
            state = ADSRState.release;
        }
    }

    /**
        Whether the ADSR env is playing
    */
    bool isPlaying() {
        return state != ADSRState.idle;
    }

    /**
        Whether the ADSR env is releasing
    */
    bool isReleasing() {
        return state == ADSRState.release;
    }

    bool getGate() {
        return gate;
    }
    
    /**
        Gets the state of the ADSR env
    */
    ADSRState getState() {
        return state;
    }
}