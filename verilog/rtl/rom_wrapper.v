module rom_wrapper (
`ifdef USE_POWER_PINS
    vccd1,
    vssd1,
`endif
clk, cs, addr, dout
);

  parameter DATA_WIDTH = 8 ;
  parameter ADDR_WIDTH = 10 ;

`ifdef USE_POWER_PINS
    inout vccd1;
    inout vssd1;
`endif

input clk; // clock
input cs; // active high chip select
input [ADDR_WIDTH-1:0]  addr;
output [DATA_WIDTH-1:0] dout;

reg cs_reg;
reg [ADDR_WIDTH-1:0] addr_reg;

// All inputs are registers
always @(posedge clk)
begin
  cs_reg = cs;
  addr_reg = addr;
end

sky130_rom_1kbyte_8x1024_tapeout rom (
 `ifdef USE_POWER_PINS
    .vccd1(vccd1),
    .vssd1(vssd1),
 `endif
  .clk(clk),
  .cs(cs_reg),
  .addr(addr_reg),
  .dout(dout)
);

endmodule
