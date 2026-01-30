## Raised Cosine Transmitter and Receiver

### Overview
The raised cosine transmitter and receiver are responsible for converting discrete QPSK symbols into continuous-time waveforms suitable for transmission through the channel, and then reconstructing noisy received waveforms back into symbol-level data for demodulation.

- **Transmitter:** Converts modulator symbols into oversampled, pulse-shaped waveforms
- **Receiver:** Filters and downsamples the received waveform to recover noisy symbols

---

## Module Interfaces

### Input / Output Port Description

| Port Type | Transmitter | Receiver |
|---------|------------|----------|
| **Inputs** | `clk` – Clock signal for filter synchronization<br>`reset` – Filter reset signal<br>`read_ready` – Indicates readiness to read input data<br>`data_in` – 16-bit signed input from modulator | `clk` – Clock signal for filter synchronization<br>`reset` – Filter reset signal<br>`data_in` – 16-bit signed input from channel |
| **Outputs** | `data_out` – 16-bit signed filtered waveform output to channel | `data_out` – 16-bit signed filtered output waveform |

---

## Filter Design

### FIR-Based Architecture
Both the transmitter and receiver are implemented using a **Finite Impulse Response (FIR) filter structure**.  
The general architecture follows the standard FIR form:

- Input samples are delayed through a register chain
- Each delayed sample is multiplied by a filter coefficient
- All products are summed to produce the output sample

The coefficients \( b_0, b_1, b_2, \dots, b_n \) are replaced with **raised cosine filter coefficients** generated via Simulink simulation.

---

### Fixed-Point Coefficient Quantization
To support FPGA implementation:
- Coefficients are multiplied by \( 2^{13} \)
- Values are rounded to the nearest integer
- Coefficients are treated as **16-bit signed fixed-point values**
  - 13 fractional bits
  - 3 integer/sign bits

This scaling aligns with the quantization requirements of the channel.

For the **receiver**, coefficients are additionally **scaled by the decimation factor**, which is **6**, to maintain correct amplitude after downsampling.

---

## Transmitter Control Logic

### Ready/Enable Counter
Beyond FIR filtering, the transmitter includes a **ready-enable counter mechanism** to ensure data integrity when receiving symbols from the QPSK modulator.

- Prevents data corruption due to timing mismatches
- Controls when new symbol values are accepted
- Ensures correct oversampling behavior

This logic can be represented conceptually using a bubble/state diagram.

---

## Receiver Downsampling

After filtering, the receiver output is passed through a **downsampler**.

### Purpose of Downsampling
- Reduces the oversampled waveform back to symbol rate
- Attempts to recover the pulse-like structure of the QPSK symbols
- Uses the **same factor as transmitter oversampling (×6)**

This step is critical for accurate demodulation.

---

## Testing Strategy

### Testbench Methodology
The transmitter and receiver were verified using a dedicated testbench that:
- Supplies **randomized QPSK symbol values**
- Operates at **160 kHz**, matching the oversampled transmit rate
- Feeds transmitter output directly into the receiver

---

### Expected Behavior
- The transmitter outputs a **pulse-shaped version** of the QPSK input symbols
- The receiver outputs a **filtered and downsampled reconstruction**
- The reconstructed output matches the expected symbol values after filtering

---

### Simulation Results
Simulation waveforms demonstrate:
1. **First waveform:** QPSK symbol values input to the transmitter
2. **Second waveform:** Pulse-shaped output of the transmitter
3. **Third waveform:** Filtered and downsampled output of the receiver

The results show that:
- The transmitter correctly captures and shapes QPSK pulses
- The receiver successfully reconstructs the transmitted signal

---

## Conclusion
Simulation confirms that:
- Raised cosine filtering is correctly implemented in both transmitter and receiver
- Fixed-point coefficient quantization meets channel requirements
- Oversampling and downsampling are correctly matched
- The transmitter/receiver pair meets all functional requirements for pulse shaping and recovery
