// OpenROM ROM model
// Words: 1024
// Word size: 8
// Word per Row: 16
// Data Type: bin
// Data File: sky130_rom_1kbyte_8x1024.bin

module sky130_rom_1kbyte_8x1024_tapeout(
`ifdef USE_POWER_PINS
    vccd1,
    vssd1,
`endif
// Port 0: R
    clk,cs,addr,dout
  );

  parameter DATA_WIDTH = 8 ;
  parameter ADDR_WIDTH = 10 ;
  parameter ROM_DEPTH = 1 << ADDR_WIDTH;
  // FIXME: This delay is arbitrary.
  parameter DELAY = 3 ;
  parameter VERBOSE = 1 ; //Set to 0 to only display warnings
  parameter T_HOLD = 1 ; //Delay to hold dout value after posedge. Value is arbitrary

`ifdef USE_POWER_PINS
    inout vccd1;
    inout vssd1;
`endif
  input clk; // clock
  input wire  cs; // active high chip select
  input wire [ADDR_WIDTH-1:0]  addr;
  output reg [DATA_WIDTH-1:0] dout;

  reg [DATA_WIDTH-1:0]    mem [0:ROM_DEPTH-1];

  initial begin
    $readmemh("/home/hadirkhan/chipignite/openram_testchip2/verilog/rtl/sky130_rom_1kbyte_8x1024.hex",mem,0,ROM_DEPTH-1);
  end

  // reg  cs_reg;
  // reg [ADDR_WIDTH-1:0]  addr_reg;
  //wire [DATA_WIDTH-1:0]  dout;

  always @(posedge clk)
  begin : MEM_READ0
    #(T_HOLD) dout <= 8'bx;
    if ( cs && VERBOSE )
      $display($time," Reading %m addr=%b dout=%b",addr,mem[addr]);

    if ( cs )
      #(T_HOLD) dout <= #(DELAY) mem[addr];
  end

endmodule
