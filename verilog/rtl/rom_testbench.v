`timescale 1ns/1ps
module testbench();

    localparam WAVEFORM   = 1;
    localparam DATA_WIDTH = 8 ;
    localparam ADDR_WIDTH = 10 ;
    localparam ROM_DEPTH  = 1 << ADDR_WIDTH;

    reg             [0:0] clk;
    reg             [0:0] cs;
    reg  [ADDR_WIDTH-1:0] addr;
    wire [DATA_WIDTH-1:0] dout;

    reg  [DATA_WIDTH-1:0] mem [0:ROM_DEPTH-1];

    /* verilator lint_off WIDTH */
    sky130_rom_1kbyte_8x1024
    rom_inst
        (.clk(clk)
        ,.cs(cs)
        ,.addr(addr)
        ,.dout(dout)
        );
    /* verilator lint_on WIDTH */

    initial begin
        clk = 1;
        forever
            #5 clk = ~clk;
    end

    integer file, value, ret_code;
    initial begin
        if (WAVEFORM) begin
`ifdef VERILATOR
            $dumpfile("verilator.fst");
`else
            $dumpfile("iverilog.vcd");
`endif
            $dumpvars;
        end

        $display("Begin Test:");

        $display("   Reading data file: sky130_rom_1kbyte_8x1024.hex");
        $readmemh("sky130_rom_1kbyte_8x1024.hex", mem);
        
        @(negedge clk);

        cs = 1'b1; // enable
        addr = {ADDR_WIDTH{1'b0}}; // address

        @(negedge clk);
        #(1);
        while (addr < ADDR_WIDTH - 1) begin
            if (mem[addr] != dout) begin
                $display("Unexpected value read at address %d. Expected %d, received %d.", addr, mem[addr], dout);
                $finish();
            end
            addr = addr + 1'b1;
            @(negedge clk);
            #(1);
        end

        if (mem[addr] != dout) begin
            $display("Unexpected value read at address %d. Expected %d, received %d.", addr, mem[addr], dout);
            $finish();
        end

        $display("Test passed.");
        $finish();
    end

endmodule
