# Zero-Knowledge Proofs Implementation with circom and snarkjs

This repository contains an implementation of Zero-Knowledge Proofs (zkSNARKs) using the `circom` circuit compiler and the `snarkjs` JavaScript library.

## Overview

Zero-Knowledge Proofs allow one party (the prover) to prove to another party (the verifier) that they know a value x, without conveying any information apart from the fact that they know the value x. This implementation demonstrates how to create, generate, and verify such proofs.

## Prerequisites

Before starting, ensure you have the following installed:

- Node.js (v16+ recommended)
- npm
- Rust (for compiling circom)
- circom
- snarkjs

## Installation

```bash
# Install circom
git clone https://github.com/iden3/circom.git
cd circom
cargo build --release
cargo install --path .

# Install snarkjs globally
npm install -g snarkjs

# Initialize the project
mkdir zkp-project
cd zkp-project
npm init -y
npm install snarkjs
```

## Project Structure

```
zkp-project/
├── circuits/               # Circuit definitions
│   └── multiplier.circom   # Example circuit that proves knowledge of factors
├── build/                  # Compiled circuit artifacts
├── zkproof/                # Proof generation and verification artifacts
├── package.json
└── README.md
```

## Step-by-Step Guide

### 1. Write a Circuit

The `multiplier.circom` circuit demonstrates a simple multiplication constraint:

```circom
pragma circom 2.0.0;

template Multiplier() {
    // Private inputs
    signal input a;
    signal input b;
    
    // Public output
    signal output c;
    
    // Constraint
    c <== a * b;
}

component main = Multiplier();
```

### 2. Compile the Circuit

```bash
mkdir -p build
circom circuits/multiplier.circom --r1cs --wasm --sym --c -o build
```

### 3. Setup the Trusted Ceremony

#### Phase 1: Powers of Tau
```bash
mkdir -p zkproof
cd zkproof

# Start a new Powers of Tau ceremony
snarkjs powersoftau new bn128 12 pot12_0000.ptau -v

# Contribute to the ceremony
snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v

# Verify the protocol
snarkjs powersoftau verify pot12_0001.ptau
```

#### Phase 2: Circuit-Specific Setup
```bash
# Prepare for phase 2
snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v

# Generate circuit-specific keys
snarkjs groth16 setup ../build/multiplier.r1cs pot12_final.ptau multiplier_0000.zkey

# Contribute to phase 2
snarkjs zkey contribute multiplier_0000.zkey multiplier_0001.zkey --name="First contribution" -v

# Export verification key
snarkjs zkey export verificationkey multiplier_0001.zkey verification_key.json
```

### 4. Generate and Verify a Proof

Create an `input.json` file with your private inputs:
```json
{"a": 3, "b": 8}
```

Generate the proof:
```bash
# Generate witness
node ../build/multiplier_js/generate_witness.js ../build/multiplier_js/multiplier.wasm input.json witness.wtns

# Generate proof
snarkjs groth16 prove multiplier_0001.zkey witness.wtns proof.json public.json

# Verify the proof
snarkjs groth16 verify verification_key.json public.json proof.json
```

### 5. Deploy on Blockchain (Optional)

Generate a Solidity verifier contract:
```bash
snarkjs zkey export solidityverifier multiplier_0001.zkey verifier.sol
```

Generate calldata for verification:
```bash
snarkjs zkey export soliditycalldata public.json proof.json
```

## Use Cases

- Private transactions
- Identity verification without revealing personal information
- Anonymous voting systems
- Supply chain verification
- And much more!

## Resources

- [circom Documentation](https://docs.circom.io/)
- [snarkjs GitHub Repository](https://github.com/iden3/snarkjs)
- [Zero Knowledge Proofs Explained](https://zkp.science/)

## License

This project is licensed under the MIT License - see the LICENSE file for details.