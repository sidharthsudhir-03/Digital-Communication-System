## System Testing Strategy (Top-Level Verification)

> **Note:** When running this testbench, a secondary top-level module named  
> `top_module_test` was used to remove all `AUDIOCODEC`-specific signals and dependencies.

---

### Testbench Overview
A comprehensive system-level testbench was developed to verify correct integration of all major subsystems, **excluding the channel**.  
This approach allows direct comparison of intermediate and final signals without channel-induced distortion.

The testbench instantiates:
- ADC and DAC
- Encoder and decoder
- Modulator and demodulator
- Serializer and deserializer
- Supporting control logic

---

### Input Stimulus
- A **24-bit signed input signal** is applied to the system
- This input mimics real microphone data from the audio codec
- Data is serialized and propagated through the full transmit and receive chain

---

### Output Verification
- The output of the system is compared against the original input
- An **appropriately determined system delay** is applied to account for:
  - Encoder latency
  - Viterbi decoder traceback delay
  - Pipeline delays in modulation and data path logic

After delay alignment:
- The output is expected to **exactly match the input**
- Successful matching confirms correct end-to-end system functionality

---

### Test Coverage
- The full system test was executed **200 times**
- Each iteration validated:
  - Correct data propagation through all subsystems
  - Proper timing alignment
  - Correct reconstruction of the original input signal

All trials produced the expected output, confirming system correctness.

---

### Debugging and Visualization
This testbench was also used extensively for debugging:
- All subsystem waveforms were visible in a **single waveform view**
- Enabled rapid identification of:
  - Timing mismatches
  - Data misalignment
  - Control signal issues

The centralized visualization significantly reduced debugging time and improved system reliability.

---

## Conclusion
System-level verification confirms that:
- All integrated subsystems function correctly together
- Latency is well-characterized and compensated
- The top-level RTL design operates as expected under repeated testing
- The design is ready for channel integration and hardware deployment
