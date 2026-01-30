# ADC/DAC RTL Communication System

## Overview
This repository contains the RTL implementation of the **ADC and DAC blocks** for a digital communication system.  
The design performs **sampling rate conversion** and **bit-width quantization** to interface between an audio codec, FPGA memory, and internal processing channels.

The system supports:
- Audio codec input and output
- Memory-based (WAV/MIF) input and output
- Quantization reduction and expansion
- Sampling rate downconversion and reconstruction

---

## System Architecture
The communication system consists of two primary processing paths:

### 1. ADC Path
- Downsamples incoming signals to **20 kHz**
- Reduces input bit-width to **8-bit signed format**

### 2. DAC Path
- Expands internal 8-bit data back to output bit-width
- Reconstructs signals for audio codec or memory output

These blocks are first verified independently and then integrated with the audio codec.

---

## Data Paths and Bit-Width Summary

| Source / Destination | Input Bit-Width | Internal Bit-Width | Output Bit-Width |
|---------------------|----------------|-------------------|-----------------|
| Audio Codec         | 24 bits        | 8 bits            | 24 bits         |
| Memory (MIF/WAV)    | 16 bits        | 8 bits            | 16 bits         |

---

## ADC Module

### Functionality
The ADC module (`data_shift_sampling`) performs:
- **Sampling rate reduction to 20 kHz**
- **Quantization reduction to 8-bit signed data**

#### Quantization Details
- Audio codec input: **24 bits → 8 bits**
- Memory input: **16 bits → 8 bits**

This matches the channel requirements of the internal communication system.

---

### ADC Verification

#### Quantization & Sampling Test
- RTL simulation confirms:
  - Correct downsampling behavior
  - Output waveform is an **8-bit signed signal**
- Simulation results meet design expectations

#### Memory Input Test
- 16-bit values from memory are passed through:
  1. ADC (16 → 8 bits)
  2. DAC (8 → 16 bits)
  3. Written back to memory

The output data matches the most significant bits of the original value, as expected.

---

## DAC Module

### Functionality
The DAC module (`data_resampling`) reconstructs signals by expanding the quantized data:

#### Quantization Expansion
- Audio codec output: **8 bits → 24 bits**
- Memory output: **8 bits → 16 bits**

Note that while the word size is restored, **lost quantization information cannot be recovered**.

---

### DAC Verification

#### Audio Codec Test
- Expected output: **24-bit signed signal**
- RTL simulation confirms correct signal reconstruction
- When integrated with the audio codec, speaker output matches microphone input

#### Memory Loopback Test
- The first two hexadecimal digits of the output match the original memory values
- Remaining bits differ due to quantization loss
- This behavior aligns with theoretical expectations

---

## Audio Codec Integration
After successful ADC and DAC testbench verification:
- The system was integrated with the audio codec
- Real-time audio loopback was tested
- Output from speakers matches microphone input, confirming correct end-to-end operation

---

## Known Limitations
- Quantization from higher bit-widths to 8 bits causes irreversible information loss
- DAC expansion restores format but not original precision

---

## Conclusion
The ADC and DAC RTL modules successfully meet all functional and verification requirements for the communication system.  
Both audio codec and memory-based data paths behave as expected, validating the design for FPGA deployment.
