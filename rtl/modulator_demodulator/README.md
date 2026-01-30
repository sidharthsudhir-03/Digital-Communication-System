## Modulator  Demodulator

### Module Functionality

#### QPSK Modulator
The modulator accepts two input bits per symbol from the convolutional encoder
- One bit from the odd-position bitstream (MSB)
- One bit from the even-position bitstream (LSB)

These two bits are combined and mapped to a QPSK symbol using a lookup table (LUT).

The modulator outputs
- A real component
- An imaginary component

Both outputs are 16-bit signed fixed-point values, matching the expected data type for transmission through the channel.

---

### QPSK Symbol Mapping
The QPSK constellation is
- Gray-coded
- Located at angles
  - π4
  - 3π4
  - 5π4
  - 7π4  
  around the unit circle

Each symbol has rectangular coordinates with equal magnitude
[
pm frac{sqrt{2}}{2}
]

As a result
- The real and imaginary components only take on two possible values
  - ( +frac{sqrt{2}}{2} )
  - ( -frac{sqrt{2}}{2} )
- These values are represented in 16-bit signed fixed-point format

Because the real and imaginary parts have equal magnitude, they are output as two parallel data streams from the modulator.

---

#### QPSK Demodulator
The demodulator receives noisy, pulse-shaped approximations of the real and imaginary symbol components from the receiver.

To recover the transmitted data
- Comparators are used to determine whether each component is
  - Greater than zero
  - Less than zero
  - Equal to zero
- Based on these comparisons, the received symbol is mapped to one of the four predefined QPSK constellation points
- The selected symbol is then converted back into its corresponding 2-bit representation

The recovered odd and even bits are passed downstream to the decoder.

---

## Testing Strategy

### Functional Verification
A dedicated testbench was developed to verify the modulator and demodulator as a pair.

Testing steps included
- Comparing the modulator input bits with the demodulator output bits
- Ensuring correct recovery across the full modulation–demodulation chain

---

### Known Symbol Tests
- All four possible 2-bit input combinations were applied
- Each input was verified to
  - Map to the correct QPSK symbol
  - Be correctly demodulated back to its original 2-bit form

---

### Randomized Testing
- Random combinations of 2-bit inputs were generated
- Each input was passed through modulation and demodulation
- Output bits consistently matched the original inputs

---

## Conclusion
Simulation results confirm that
- QPSK symbol mapping and Gray coding are correctly implemented
- Fixed-point representation matches channel requirements
- The demodulator reliably recovers transmitted symbols
- The modulator demodulator pair functions correctly under randomized testing
