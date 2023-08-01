module rram_test (
`ifdef USE_POWER_PINS
    inout vccd1,
    inout vssd1,
`endif

    input pVDD_HEADER0,
    input pGND_HEADER0,
    input pVDD_HEADER1,
    input pGND_HEADER1,
    inout p1T1R_TE,
    inout p1T1R_WL,
    inout p036_SL,
    inout p100_SL,
    inout p300_SL,
    inout p700_SL,

    inout p1R_TE,
    inout p1R_SL,

    inout BL0,
    inout BL1,
    inout BR0,
    inout BR1,
    inout RE_BL0,
    inout RE_BL1,
    inout RE_BR0, 
    inout RE_BR1,
    inout WL0,
    inout WL1,
    inout RE_WL0,
    inout RE_WL1

);

endmodule
