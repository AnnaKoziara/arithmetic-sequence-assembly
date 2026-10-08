# Arithmetic Sequence Term Finder

An x86-64 assembly routine that calculates a specified term of an arithmetic
sequence using the formula:

```text
A_k = A_0 + k * (A_1 - A_0)
```

The routine is named `arithmetic_sequence`. It accepts `A_0` and `A_1` as
little-endian arrays of 64-bit words, the number of words, and the index `k`.
It writes the calculated term to a caller-provided output array. The index
`k` is zero-based, so `A_0` is the first term and `A_1` is the term at index 1.

The source file uses NASM-style x86-64 assembly syntax. It provides the
calculation routine; a calling program must allocate and pass the input and
output arrays.
