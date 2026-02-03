# MATLAB Simulation of the Communication System

## Overview
This project, part of **ELEC 391**, focuses on the reliable transfer of wireless information over a noisy channel. The system simulates a digital communication link with audio data transmitted through an AWGN channel with Gilbert fading. Our design incorporates key subsystems, including error correction, modulation/demodulation, and a transmitter/receiver pair with a raised cosine filter for pulse shaping.

## Objectives
The project meets the following specifications:
- **Message Transmission**: Reliable transfer of audio with an 8 kHz bandwidth
- **Processing Delay**: 25 ms (achieved 3 ms)
- **Bit Error Rate (BER)**: ≤ 10⁻⁴ (achieved 0 in simulation)
- **Average Transmit Power**: 1W
- **Channel Bandwidth**: 100 kHz (achieved 100 kHz)
- **Source & Sink**: WAV format audio file, DE1 microphone input/output

## System Design
The communication system comprises several subsystems:
1. **Source/Sink**: Handles stereo 32-bit WAV file input, with conversion to 16-bit for processing.
2. **A/D and D/A Conversion**: Uses Rate Transition and Integer to Bit conversion blocks to digitize the audio signal, following the Nyquist sampling rate.
3. **Error Correction (Convolutional Encoding)**: Implements a 1/2 rate (7, [171, 133]) convolutional encoder and a Viterbi decoder for robust error correction.
4. **Modulation/Demodulation (QPSK)**: Uses QPSK modulation to map the bits to symbols and limit the bandwidth.
5. **Transmitter/Receiver**: Implements raised cosine filtering for pulse shaping and matched filtering at the receiver end.
6. **Channel Model (Gilbert + AWGN)**: Simulates channel fading with a Gilbert model, switching between good and bad states, combined with AWGN.


