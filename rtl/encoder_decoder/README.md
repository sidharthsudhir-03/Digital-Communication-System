## Encoder / Decoder

### Module Functionality

#### Convolutional Encoder
A convolutional encoder is implemented with the following parameters:
- **Constraint length:** 4  
- **Traceback depth:** 16  
- **Generator polynomials:** 12₈ and 15₈  

The encoder uses **sequential logic** and therefore takes `clk` and `reset` inputs. The data input is a **single-bit serialized stream**, derived from the input sample data.

On each clock cycle:
- The current input bit is shifted through a register chain
- The generator polynomials are applied to the current and stored bits
- Two encoded output bits are produced per input bit

These two output bits are separated into:
- **Odd-position bit stream**
- **Even-position bit stream**

Both streams are forwarded to the modulator.

Once the encoder begins producing valid outputs, the `encode_valid` signal is asserted high and remains high for the duration of system operation, indicating that downstream blocks may accept encoded data.

---

#### Viterbi Decoder
After transmission through the channel, the **Viterbi decoder** reconstructs the original bitstream from the received data.

The decoder:
- Accepts **odd-position and even-position bits** from the demodulator
- Uses `clk` and `reset` due to extensive sequential logic
- Was generated using **HDL Coder**, resulting in multiple supporting submodules

The decoder operates using:
- A **trellis-based structure**
- **Recursive traceback logic** to correct flipped or missing bits caused by channel impairments

Due to the traceback depth, the decoder introduces **additional latency** into the system.

The output of the Viterbi decoder is a **single-bit stream**, which is passed to the deserializer to reconstruct the original **8-bit sample frames**.

Once valid output begins, the `decode_valid` signal is asserted high and held high for the remainder of system operation.

---

## Testing Strategy

### Encoder / Decoder Verification
A dedicated testbench was developed to verify the combined functionality of the encoder and decoder.

The testing process involved:
- Generating **random input bit streams**
- Feeding the data through the convolutional encoder
- Passing encoded data directly to the Viterbi decoder (without channel impairment)
- Comparing decoder output with the original encoder input

---

### Latency Characterization
The testbench was also used to:
- Measure the **system delay introduced by the Viterbi decoder**
- Determine the required delay compensation
- Enable the creation of a delay module with the appropriate latency alignment

---

### Test Coverage
- Approximately **200 randomized trials** were conducted
- All trials confirmed that:
  - Decoder output matched encoder input after the expected delay
  - The encoder and decoder functioned correctly as a pair

---

## Conclusion
Simulation results confirm that:
- The convolutional encoder correctly applies the specified generator polynomials
- The Viterbi decoder successfully reconstructs the original bitstream
- System latency introduced by decoding is well-characterized and compensated
- The encoder/decoder chain operates reliably under randomized testing
