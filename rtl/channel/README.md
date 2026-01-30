## Channel Testing Strategy (Gilbert Fading + AWGN)

### Overview
The channel subsystem consists of two main components:
- **Gilbert Fading Module**: Models good and bad channel states
- **AWGN Channel**: Injects noise using a pre-generated lookup table

The Gilbert module controls the enable signal that determines when the AWGN channel affects the signal.

---

## Gilbert Fading Module

### Functionality
The Gilbert fading module outputs a **binary enable signal**:
- `1` → Good channel state
- `0` → Bad channel state

This enable signal is used to control whether the AWGN channel modifies the input signal.

---

### Testing Methodology

#### Enable Signal Verification
The first step in testing the channel is validating the Gilbert fading module.  
By observing the waveform:
- The enable signal toggles between high and low
- This confirms correct transitions between good and bad channel states

The waveform clearly shows the enable signal behavior, verifying proper state switching.

---

#### Steady-State Probability Verification
To further validate correctness:
- The number of good states is counted relative to the total number of states
- The expected steady-state ratio, calculated in **Demo 1**, is **80% good channel**

Simulation results confirm that:
- The observed ratio closely matches the expected 80%
- The Gilbert fading model is operating as designed

---

## AWGN Channel

### Implementation
The AWGN channel is implemented using a **pre-generated lookup table** stored in a `.mif` file.  
The noise values are indexed and applied based on the enable signal received from the Gilbert fading module.

---

### Testing Strategy
There is no direct analytical method to test the AWGN channel because:
- Noise samples are stored in memory
- Values are generated offline and accessed via lookup

To verify functionality:
- Selected noise samples were manually inspected from the `.mif` file
- These values were injected into the system during simulation
- The output signal showed clear influence from the noise samples

This confirms that the AWGN channel is correctly modifying the signal when enabled.

---

## Channel Integration Behavior
- The **Gilbert module** determines channel quality and outputs the enable signal
- The **AWGN channel** applies noise only when enabled
- Together, they accurately model a fading noisy communication channel

---

## Conclusion
Simulation results confirm that:
- The Gilbert fading module produces correct good/bad channel behavior
- The steady-state probability matches theoretical expectations
- The AWGN channel correctly injects noise using the lookup table
- The combined channel system functions as intended
