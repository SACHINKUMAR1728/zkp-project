pragma  circom 2.0.0;

template Multiplier() {

    // Private inputs
    signal input a;
    signal input b;

    // Public output
    signal output c;

   
    c <== a * b; 

}

component main = Multiplier();