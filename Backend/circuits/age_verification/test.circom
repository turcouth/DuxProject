pragma circom 2.0.0;

template Test() {
    signal input x;
    signal output y;
    y <== x;
}

component main = Test();