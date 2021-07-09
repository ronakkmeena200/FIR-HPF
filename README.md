# FIR-HPF
The code contains MATLAB part which generates coefficients of filter and 2 files containing binary value of input and output for verilog file. The verilog code reads the input which is then compared to output generated by Matlab code.

## FIR.m
A white noise signal is generated which is quantized to be used as input for verilog file. File name is 'exp.txt'. This file when placed in same folder as 'FIR1.v' is read and output is produced which is compared with output present in 'verify.txt'.

## FIR1.v
Verilog code already contains coefficients for a 13-bit quantized High pass filter with cut off of 0.3 cycles/sample. Also a clock signal of 10ns is being used to change the input and calculate the corresponding output during the cycle.
