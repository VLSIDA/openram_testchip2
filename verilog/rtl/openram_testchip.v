
module openram_testchip(
`ifdef USE_POWER_PINS
			inout vdda1,        // User area 1 3.3V supply
			inout vdda2,        // User area 2 3.3V supply
			inout vssa1,        // User area 1 analog ground
			inout vssa2,        // User area 2 analog ground
			inout vccd1,        // User area 1 1.8V supply
			inout vccd2,        // User area 2 1.8v supply
			inout vssd1,        // User area 1 digital ground
			inout vssd2,        // User area 2 digital ground
`endif
			input         resetn,
			input         clk,
			input 		  wb_select,
			input         la_in_load,
			input         la_sram_load,
			input  [`TOTAL_SIZE-1:0] la_data_in,
			// GPIO bit to clock control register
			input         gpio_in,
			input         gpio_scan,
			input         gpio_sram_load,
			input         global_csb,
			// wishbone related control signals
    		input wb_clk_i,
    		input wb_rst_i,
    		input wbs_stb_i,
    		input wbs_cyc_i,
    		input wbs_we_i,
    		input [3:0] wbs_sel_i,
    		input [31:0] wbs_dat_i,
    		input [31:0] wbs_adr_i,
			input  [`DATA_SIZE-1:0] wbs_sram8_data,
			input  [`DATA_SIZE-1:0] wbs_sram9_data,
			input  [`DATA_SIZE-1:0] wbs_sram10_data,
			input  [`DATA_SIZE-1:0] wbs_sram0_data0,
			input  [`DATA_SIZE-1:0] wbs_sram0_data1,
			input  [`DATA_SIZE-1:0] wbs_sram1_data0,
			input  [`DATA_SIZE-1:0] wbs_sram1_data1,
			input  [`DATA_SIZE-1:0] wbs_sram2_data0,
			input  [`DATA_SIZE-1:0] wbs_sram2_data1,
			input  [`DATA_SIZE-1:0] wbs_sram3_data0,
			input  [`DATA_SIZE-1:0] wbs_sram3_data1,
			input  [`DATA_SIZE-1:0] wbs_sram4_data0,
			input  [`DATA_SIZE-1:0] wbs_sram4_data1,
			input  [`DATA_SIZE-1:0] wbs_sram5_data0,
			input  [`DATA_SIZE-1:0] wbs_sram5_data1,
			input  [`DATA_SIZE-1:0] wbs_sram6_data0,
			input  [`DATA_SIZE-1:0] wbs_sram6_data1,
    		output wbs_ack_o,
    		output [31:0] wbs_dat_o,
			// SRAM data outputs to be captured
			input  [`DATA_SIZE-1:0] sram0_data0,
			input  [`DATA_SIZE-1:0] sram0_data1,
			input  [`DATA_SIZE-1:0] sram1_data0,
			input  [`DATA_SIZE-1:0] sram1_data1,
			input  [`DATA_SIZE-1:0] sram2_data0,
			input  [`DATA_SIZE-1:0] sram2_data1,
			input  [`DATA_SIZE-1:0] sram3_data0,
			input  [`DATA_SIZE-1:0] sram3_data1,
			input  [`DATA_SIZE-1:0] sram4_data0,
			input  [`DATA_SIZE-1:0] sram4_data1,
			input  [`DATA_SIZE-1:0] sram5_data0,
			input  [`DATA_SIZE-1:0] sram5_data1,
			input  [`DATA_SIZE-1:0] sram6_data0,
			input  [`DATA_SIZE-1:0] sram6_data1,
			input  [`DATA_SIZE-1:0] sram7_data0,
			input  [`DATA_SIZE-1:0] sram7_data1,
			input  [`DATA_SIZE-1:0] sram8_data0,
			input  [`DATA_SIZE-1:0] sram8_data1,
			input  [`DATA_SIZE-1:0] sram9_data0,
			input  [`DATA_SIZE-1:0] sram9_data1,
			input  [`DATA_SIZE-1:0] sram10_data0,
			input  [`DATA_SIZE-1:0] sram10_data1,
			input  [`DATA_SIZE-1:0] sram11_data0,
			input  [`DATA_SIZE-1:0] sram11_data1,
			input  [`DATA_SIZE-1:0] sram12_data0,
			input  [`DATA_SIZE-1:0] sram12_data1,
			input  [`DATA_SIZE-1:0] sram13_data0,
			input  [`DATA_SIZE-1:0] sram13_data1,
			input  [`DATA_SIZE-1:0] sram14_data0,
			input  [`DATA_SIZE-1:0] sram14_data1,
			input  [`DATA_SIZE-1:0] sram15_data0,
			input  [`DATA_SIZE-1:0] sram15_data1,

			// Shared control/data to the SRAMs
			output reg [`ADDR_SIZE-1:0] addr0,
			output reg [`DATA_SIZE-1:0] din0,
			output reg 	  web0,
			output reg [`WMASK_SIZE-1:0]  wmask0,
			output reg [`ADDR_SIZE-1:0] addr1,
			output reg [`DATA_SIZE-1:0] din1,
			output reg 	  web1,
			output reg [`WMASK_SIZE-1:0]  wmask1,
			// One CSB for each SRAM
			// One CSB for each SRAM
			output reg [`MAX_CHIPS-1:0] csb0,
			output reg [`MAX_CHIPS-1:0] csb1,

			output reg [`TOTAL_SIZE-1:0] la_data_out,
			output reg gpio_out
);

// Store input instruction
   reg [`TOTAL_SIZE-1:0] sram_register;
   reg 		       csb0_temp;
   reg 		       csb1_temp;

   // Mux output to connect final output data
   // into sram_register
   reg [`DATA_SIZE-1:0] read_data0;
   reg [`DATA_SIZE-1:0] read_data1;

   // SRAM input connections
   reg [`SELECT_SIZE-1:0]  chip_select;

// wires connecting sram8 wrapper to sram8 macro
	wire ram8_clk0;
	wire ram8_csb0;
	wire ram8_web0;
	wire [`WMASK_SIZE-1:0] ram8_wmask0;
	wire [`ADDR_SIZE-1:0] ram8_addr0;
	wire [`DATA_SIZE-1:0] ram8_din0;
// wires connecting sram9 wrapper to sram9 macro
	wire ram9_clk0;
	wire ram9_csb0;
	wire ram9_web0;
	wire [`WMASK_SIZE-1:0] ram9_wmask0;
	wire [`ADDR_SIZE-1:0] ram9_addr0;
	wire [`DATA_SIZE-1:0] ram9_din0;
// wires connecting sram10 wrapper to sram10 macro
	wire ram10_clk0;
	wire ram10_csb0;
	wire ram10_web0;
	wire [`WMASK_SIZE-1:0] ram10_wmask0;
	wire [`ADDR_SIZE-1:0] ram10_addr0;
	wire [`DATA_SIZE-1:0] ram10_din0;
// wires connecting sram0 wrapper to sram0 macro
    // PORT RW
	wire ram0_clk0;
	wire ram0_csb0;
	wire ram0_web0;
	wire [`WMASK_SIZE-1:0] ram0_wmask0;
	wire [`ADDR_SIZE-1:0] ram0_addr0;
	wire [`DATA_SIZE-1:0] ram0_din0;
	// PORT R
	wire ram0_clk1;
	wire ram0_csb1;
	wire [`ADDR_SIZE-1:0] ram0_addr1;
// wires connecting sram1 wrapper to sram1 macro
	// PORT RW
	wire ram1_clk0;
	wire ram1_csb0;
	wire ram1_web0;
	wire [`WMASK_SIZE-1:0] ram1_wmask0;
	wire [`ADDR_SIZE-1:0] ram1_addr0;
	wire [`DATA_SIZE-1:0] ram1_din0;
	// PORT R
	wire ram1_clk1;
	wire ram1_csb1;
	wire [`ADDR_SIZE-1:0] ram1_addr1;
// wires connecting sram2 wrapper to sram2 macro
	// PORT RW
	wire ram2_clk0;
	wire ram2_csb0;
	wire ram2_web0;
	wire [`WMASK_SIZE-1:0] ram2_wmask0;
	wire [`ADDR_SIZE-1:0] ram2_addr0;
	wire [`DATA_SIZE-1:0] ram2_din0;
	// PORT R
	wire ram2_clk1;
	wire ram2_csb1;
	wire [`ADDR_SIZE-1:0] ram2_addr1;
// wires connecting sram3 wrapper to sram3 macro
	// PORT RW
	wire ram3_clk0;
	wire ram3_csb0;
	wire ram3_web0;
	wire [`WMASK_SIZE-1:0] ram3_wmask0;
	wire [`ADDR_SIZE-1:0] ram3_addr0;
	wire [`DATA_SIZE-1:0] ram3_din0;
	// PORT R
	wire ram3_clk1;
	wire ram3_csb1;
	wire [`ADDR_SIZE-1:0] ram3_addr1;
// wires connecting sram4 wrapper to sram4 macro
	// PORT RW
	wire ram4_clk0;
	wire ram4_csb0;
	wire ram4_web0;
	wire [`WMASK_SIZE-1:0] ram4_wmask0;
	wire [`ADDR_SIZE-1:0] ram4_addr0;
	wire [`DATA_SIZE-1:0] ram4_din0;
	// PORT R
	wire ram4_clk1;
	wire ram4_csb1;
	wire [`ADDR_SIZE-1:0] ram4_addr1;
// wires connecting sram5 wrapper to sram5 macro
	// PORT RW
	wire ram5_clk0;
	wire ram5_csb0;
	wire ram5_web0;
	wire [`WMASK_SIZE-1:0] ram5_wmask0;
	wire [`ADDR_SIZE-1:0] ram5_addr0;
	wire [`DATA_SIZE-1:0] ram5_din0;
	// PORT R
	wire ram5_clk1;
	wire ram5_csb1;
	wire [`ADDR_SIZE-1:0] ram5_addr1;
// wires connecting sram6 wrapper to sram6 macro
	// PORT RW
	wire ram6_clk0;
	wire ram6_csb0;
	wire ram6_web0;
	wire [`WMASK_SIZE-1:0] ram6_wmask0;
	wire [`ADDR_SIZE-1:0] ram6_addr0;
	wire [`DATA_SIZE-1:0] ram6_din0;
	// PORT R
	wire ram6_clk1;
	wire ram6_csb1;
	wire [`ADDR_SIZE-1:0] ram6_addr1;
// wires connecting between mux & sram8
	wire wbs_or8_stb;
	wire wbs_or8_cyc;
	wire wbs_or8_we;
	wire [3:0] wbs_or8_sel;
	wire [31:0] wbs_or8_dat_i;
	wire wbs_or8_ack;
	wire [31:0] wbs_or8_dat_o;
// wires connecting between mux & sram9
	wire wbs_or9_stb;
	wire wbs_or9_cyc;
	wire wbs_or9_we;
	wire [3:0] wbs_or9_sel;
	wire [31:0] wbs_or9_dat_i;
	wire wbs_or9_ack;
	wire [31:0] wbs_or9_dat_o;
// wires connecting between mux & sram10
	wire wbs_or10_stb;
	wire wbs_or10_cyc;
	wire wbs_or10_we;
	wire [3:0] wbs_or10_sel;
	wire [31:0] wbs_or10_dat_i;
	wire wbs_or10_ack;
	wire [31:0] wbs_or10_dat_o;
// wires connecting between mux & sram0
	wire wbs_or0_stb;
	wire wbs_or0_cyc;
	wire wbs_or0_we;
	wire [3:0] wbs_or0_sel;
	wire [31:0] wbs_or0_dat_i;
	wire wbs_or0_ack;
	wire [31:0] wbs_or0_dat_o;
// wires connecting between mux & sram1
	wire wbs_or1_stb;
	wire wbs_or1_cyc;
	wire wbs_or1_we;
	wire [3:0] wbs_or1_sel;
	wire [31:0] wbs_or1_dat_i;
	wire wbs_or1_ack;
	wire [31:0] wbs_or1_dat_o;
// wires connecting between mux & sram2
	wire wbs_or2_stb;
	wire wbs_or2_cyc;
	wire wbs_or2_we;
	wire [3:0] wbs_or2_sel;
	wire [31:0] wbs_or2_dat_i;
	wire wbs_or2_ack;
	wire [31:0] wbs_or2_dat_o;
// wires connecting between mux & sram3
	wire wbs_or3_stb;
	wire wbs_or3_cyc;
	wire wbs_or3_we;
	wire [3:0] wbs_or3_sel;
	wire [31:0] wbs_or3_dat_i;
	wire wbs_or3_ack;
	wire [31:0] wbs_or3_dat_o;
// wires connecting between mux & sram4
	wire wbs_or4_stb;
	wire wbs_or4_cyc;
	wire wbs_or4_we;
	wire [3:0] wbs_or4_sel;
	wire [31:0] wbs_or4_dat_i;
	wire wbs_or4_ack;
	wire [31:0] wbs_or4_dat_o;
// wires connecting between mux & sram5
	wire wbs_or5_stb;
	wire wbs_or5_cyc;
	wire wbs_or5_we;
	wire [3:0] wbs_or5_sel;
	wire [31:0] wbs_or5_dat_i;
	wire wbs_or5_ack;
	wire [31:0] wbs_or5_dat_o;
// wires connecting between mux & sram6
	wire wbs_or6_stb;
	wire wbs_or6_cyc;
	wire wbs_or6_we;
	wire [3:0] wbs_or6_sel;
	wire [31:0] wbs_or6_dat_i;
	wire wbs_or6_ack;
	wire [31:0] wbs_or6_dat_o;

always @ (posedge clk) begin
   if(!resetn) begin
      sram_register <= {`TOTAL_SIZE{1'b0}};
   end
   // GPIO scanning for transfer
   else if(gpio_scan) begin
      sram_register <= {sram_register[`TOTAL_SIZE-2:0], gpio_in};
   end
   // LA parallel load
   else if(la_in_load) begin
      sram_register <= la_data_in;
   end
   // Store results for read out
   else if(gpio_sram_load || la_sram_load) begin

      sram_register <= {sram_register[`TOTAL_SIZE-1:`TOTAL_SIZE-`SELECT_SIZE-`ADDR_SIZE],
			read_data0,
			sram_register[`ADDR_SIZE+`DATA_SIZE+`WMASK_SIZE+`WMASK_SIZE+3:`DATA_SIZE+`WMASK_SIZE+2],
			read_data1,
			sram_register[`WMASK_SIZE+1:0]};
   end
end

	wishbone_ram_mux WB_RAM_MUX(
    	.wb_clk_i(wb_clk_i),
    	.wb_rst_i(wb_rst_i),
		// main wishbone signals coming here
    	.wbs_ufp_stb_i(wbs_stb_i),
    	.wbs_ufp_cyc_i(wbs_cyc_i),
    	.wbs_ufp_we_i(wbs_we_i),
    	.wbs_ufp_sel_i(wbs_sel_i),
    	.wbs_ufp_dat_i(wbs_dat_i),
    	.wbs_ufp_adr_i(wbs_adr_i),
    	.wbs_ufp_ack_o(wbs_ack_o),
    	.wbs_ufp_dat_o(wbs_dat_o),
		// wishbone signals to sram 8
    	.wbs_or8_stb_o(wbs_or8_stb),
    	.wbs_or8_cyc_o(wbs_or8_cyc),
    	.wbs_or8_we_o(wbs_or8_we),
    	.wbs_or8_sel_o(wbs_or8_sel),
    	.wbs_or8_dat_i(wbs_or8_dat_i),
    	.wbs_or8_ack_i(wbs_or8_ack),
    	.wbs_or8_dat_o(wbs_or8_dat_o),
		// wishbone signals to sram 9
    	.wbs_or9_stb_o(wbs_or9_stb),
    	.wbs_or9_cyc_o(wbs_or9_cyc),
    	.wbs_or9_we_o(wbs_or9_we),
    	.wbs_or9_sel_o(wbs_or9_sel),
    	.wbs_or9_dat_i(wbs_or9_dat_i),
    	.wbs_or9_ack_i(wbs_or9_ack),
    	.wbs_or9_dat_o(wbs_or9_dat_o),
		// wishbone signals to sram 10
    	.wbs_or10_stb_o(wbs_or10_stb),
    	.wbs_or10_cyc_o(wbs_or10_cyc),
    	.wbs_or10_we_o(wbs_or10_we),
    	.wbs_or10_sel_o(wbs_or10_sel),
    	.wbs_or10_dat_i(wbs_or10_dat_i),
    	.wbs_or10_ack_i(wbs_or10_ack),
    	.wbs_or10_dat_o(wbs_or10_dat_o),
		// wishbone signals to sram 0
    	.wbs_or0_stb_o(wbs_or0_stb),
    	.wbs_or0_cyc_o(wbs_or0_cyc),
    	.wbs_or0_we_o(wbs_or0_we),
    	.wbs_or0_sel_o(wbs_or0_sel),
    	.wbs_or0_dat_i(wbs_or0_dat_i),
    	.wbs_or0_ack_i(wbs_or0_ack),
    	.wbs_or0_dat_o(wbs_or0_dat_o),
		// wishbone signals to sram 1
    	.wbs_or1_stb_o(wbs_or1_stb),
    	.wbs_or1_cyc_o(wbs_or1_cyc),
    	.wbs_or1_we_o(wbs_or1_we),
    	.wbs_or1_sel_o(wbs_or1_sel),
    	.wbs_or1_dat_i(wbs_or1_dat_i),
    	.wbs_or1_ack_i(wbs_or1_ack),
    	.wbs_or1_dat_o(wbs_or1_dat_o),
		// wishbone signals to sram 2
    	.wbs_or2_stb_o(wbs_or2_stb),
    	.wbs_or2_cyc_o(wbs_or2_cyc),
    	.wbs_or2_we_o(wbs_or2_we),
    	.wbs_or2_sel_o(wbs_or2_sel),
    	.wbs_or2_dat_i(wbs_or2_dat_i),
    	.wbs_or2_ack_i(wbs_or2_ack),
    	.wbs_or2_dat_o(wbs_or2_dat_o),
		// wishbone signals to sram 3
    	.wbs_or3_stb_o(wbs_or3_stb),
    	.wbs_or3_cyc_o(wbs_or3_cyc),
    	.wbs_or3_we_o(wbs_or3_we),
    	.wbs_or3_sel_o(wbs_or3_sel),
    	.wbs_or3_dat_i(wbs_or3_dat_i),
    	.wbs_or3_ack_i(wbs_or3_ack),
    	.wbs_or3_dat_o(wbs_or3_dat_o),
		// wishbone signals to sram 4
    	.wbs_or4_stb_o(wbs_or4_stb),
    	.wbs_or4_cyc_o(wbs_or4_cyc),
    	.wbs_or4_we_o(wbs_or4_we),
    	.wbs_or4_sel_o(wbs_or4_sel),
    	.wbs_or4_dat_i(wbs_or4_dat_i),
    	.wbs_or4_ack_i(wbs_or4_ack),
    	.wbs_or4_dat_o(wbs_or4_dat_o),
		// wishbone signals to sram 5
    	.wbs_or5_stb_o(wbs_or5_stb),
    	.wbs_or5_cyc_o(wbs_or5_cyc),
    	.wbs_or5_we_o(wbs_or5_we),
    	.wbs_or5_sel_o(wbs_or5_sel),
    	.wbs_or5_dat_i(wbs_or5_dat_i),
    	.wbs_or5_ack_i(wbs_or5_ack),
    	.wbs_or5_dat_o(wbs_or5_dat_o),
		// wishbone signals to sram 6
    	.wbs_or6_stb_o(wbs_or6_stb),
    	.wbs_or6_cyc_o(wbs_or6_cyc),
    	.wbs_or6_we_o(wbs_or6_we),
    	.wbs_or6_sel_o(wbs_or6_sel),
    	.wbs_or6_dat_i(wbs_or6_dat_i),
    	.wbs_or6_ack_i(wbs_or6_ack),
    	.wbs_or6_dat_o(wbs_or6_dat_o)
	);

	wishbone_wrapper SRAM8_WRAPPER(
    	.wb_clk_i(wb_clk_i),
    	.wb_rst_i(wb_rst_i),
    	.wbs_stb_i(wbs_or8_stb),
    	.wbs_cyc_i(wbs_or8_cyc),
    	.wbs_we_i(wbs_or8_we),
    	.wbs_sel_i(wbs_or8_sel),
    	.wbs_dat_i(wbs_or8_dat_o),
    	.wbs_adr_i(wbs_adr_i),
    	.wbs_ack_o(wbs_or8_ack),
    	.wbs_dat_o(wbs_or8_dat_i),
		// OpenRAM interface
    	.ram_clk0(ram8_clk0),       // (output) clock
    	.ram_csb0(ram8_csb0),       // (output) active low chip select
    	.ram_web0(ram8_web0),       // (output) active low write control
    	.ram_wmask0(ram8_wmask0),   // (output) write (byte) mask
    	.ram_addr0(ram8_addr0),	   // (output)
    	.ram_din0(wbs_sram8_data),	   // (input) read from sram and sent through wb 
    	.ram_dout0(ram8_din0)	   // (output) read from wb and sent to sram
	);

	wishbone_wrapper SRAM9_WRAPPER(
    	.wb_clk_i(wb_clk_i),
    	.wb_rst_i(wb_rst_i),
    	.wbs_stb_i(wbs_or9_stb),
    	.wbs_cyc_i(wbs_or9_cyc),
    	.wbs_we_i(wbs_or9_we),
    	.wbs_sel_i(wbs_or9_sel),
    	.wbs_dat_i(wbs_or9_dat_o),
    	.wbs_adr_i(wbs_adr_i),
    	.wbs_ack_o(wbs_or9_ack),
    	.wbs_dat_o(wbs_or9_dat_i),
		// OpenRAM interface
    	.ram_clk0(ram9_clk0),       // (output) clock
    	.ram_csb0(ram9_csb0),       // (output) active low chip select
    	.ram_web0(ram9_web0),       // (output) active low write control
    	.ram_wmask0(ram9_wmask0),   // (output) write (byte) mask
    	.ram_addr0(ram9_addr0),	   // (output)
    	.ram_din0(wbs_sram9_data),	   // (input) read from sram and sent through wb 
    	.ram_dout0(ram9_din0)	   // (output) read from wb and sent to sram
	);

	wishbone_wrapper SRAM10_WRAPPER(
    	.wb_clk_i(wb_clk_i),
    	.wb_rst_i(wb_rst_i),
    	.wbs_stb_i(wbs_or10_stb),
    	.wbs_cyc_i(wbs_or10_cyc),
    	.wbs_we_i(wbs_or10_we),
    	.wbs_sel_i(wbs_or10_sel),
    	.wbs_dat_i(wbs_or10_dat_o),
    	.wbs_adr_i(wbs_adr_i),
    	.wbs_ack_o(wbs_or10_ack),
    	.wbs_dat_o(wbs_or10_dat_i),
		// OpenRAM interface
    	.ram_clk0(ram10_clk0),     		// (output) clock
    	.ram_csb0(ram10_csb0),     		// (output) active low chip select
    	.ram_web0(ram10_web0),     		// (output) active low write control
    	.ram_wmask0(ram10_wmask0), 		// (output) (byte) mask from wb sent to sram
    	.ram_addr0(ram10_addr0),   		// (output) addr from wb sent to sram
    	.ram_din0(wbs_sram10_data),		// (input) read from sram and sent to wb 
    	.ram_dout0(ram10_din0)	   		// (output) for writing into the sram through wb
	);

	wishbone_wrapper_dp #(.NO_OF_ROWS(1024)) SRAM0_WRAPPER(
    	.wb_clk_i(wb_clk_i),
    	.wb_rst_i(wb_rst_i),
    	.wbs_stb_i(wbs_or0_stb),
    	.wbs_cyc_i(wbs_or0_cyc),
    	.wbs_we_i(wbs_or0_we),
    	.wbs_sel_i(wbs_or0_sel),
    	.wbs_dat_i(wbs_or0_dat_o),
    	.wbs_adr_i(wbs_adr_i),
    	.wbs_ack_o(wbs_or0_ack),
    	.wbs_dat_o(wbs_or0_dat_i),
		// OpenRAM interface
		// PORT RW
    	.ram_clk0(ram0_clk0),       	// (output) clock
    	.ram_csb0(ram0_csb0),       	// (output) active low chip select
    	.ram_web0(ram0_web0),       	// (output) active low write control
    	.ram_wmask0(ram0_wmask0),   	// (output) (byte) mask from wb sent to sram
    	.ram_addr0(ram0_addr0),	   		// (output) addr from wb sent to sram
    	.ram_din0(wbs_sram0_data0),	   	// (input) read from sram and sent to wb 
    	.ram_dout0(ram0_din0),	   		// (output) for writing into the sram through wb
		// PORT R
    	.ram_clk1(ram0_clk1),       	// (output) clock
    	.ram_csb1(ram0_csb1),       	// (output) active low chip select
    	.ram_addr1(ram0_addr1),	   		// (output) addr from wb sent to sram
    	.ram_din1(wbs_sram0_data1)	   	// (input) read from sram and sent to wb 
	);

	wishbone_wrapper_dp #(.NO_OF_ROWS(256)) SRAM1_WRAPPER(
    	.wb_clk_i(wb_clk_i),
    	.wb_rst_i(wb_rst_i),
    	.wbs_stb_i(wbs_or1_stb),
    	.wbs_cyc_i(wbs_or1_cyc),
    	.wbs_we_i(wbs_or1_we),
    	.wbs_sel_i(wbs_or1_sel),
    	.wbs_dat_i(wbs_or1_dat_o),
    	.wbs_adr_i(wbs_adr_i),
    	.wbs_ack_o(wbs_or1_ack),
    	.wbs_dat_o(wbs_or1_dat_i),
		// OpenRAM interface
		// PORT RW
    	.ram_clk0(ram1_clk0),     		// (output) clock                                 
    	.ram_csb0(ram1_csb0),     		// (output) active low chip select                
    	.ram_web0(ram1_web0),     		// (output) active low write control              
    	.ram_wmask0(ram1_wmask0), 		// (output) (byte) mask from wb sent to sram      
    	.ram_addr0(ram1_addr0),	  		// (output) addr from wb sent to sram            
    	.ram_din0(wbs_sram1_data0),		// (input) read from sram and sent to wb        	
    	.ram_dout0(ram1_din0),	  		// (output) for writing into the sram through wb
		// PORT R
    	.ram_clk1(ram1_clk1),       	// (output) clock
    	.ram_csb1(ram1_csb1),       	// (output) active low chip select
    	.ram_addr1(ram1_addr1),	   		// (output) addr from wb sent to sram
    	.ram_din1(wbs_sram1_data1)	   	// (input) read from sram and sent to wb 
	);

	wishbone_wrapper_dp #(.NO_OF_ROWS(512)) SRAM2_WRAPPER(
    	.wb_clk_i(wb_clk_i),
    	.wb_rst_i(wb_rst_i),
    	.wbs_stb_i(wbs_or2_stb),
    	.wbs_cyc_i(wbs_or2_cyc),
    	.wbs_we_i(wbs_or2_we),
    	.wbs_sel_i(wbs_or2_sel),
    	.wbs_dat_i(wbs_or2_dat_o),
    	.wbs_adr_i(wbs_adr_i),
    	.wbs_ack_o(wbs_or2_ack),
    	.wbs_dat_o(wbs_or2_dat_i),
		// OpenRAM interface
		// PORT RW
    	.ram_clk0(ram2_clk0),       // (output) clock
    	.ram_csb0(ram2_csb0),       // (output) active low chip select
    	.ram_web0(ram2_web0),       // (output) active low write control
    	.ram_wmask0(ram2_wmask0),   // (output) write (byte) mask
    	.ram_addr0(ram2_addr0),	   // (output)
    	.ram_din0(wbs_sram2_data0),	   // (input) read from sram and sent through wb 
    	.ram_dout0(ram2_din0),	   // (output) read from wb and sent to sram
		// PORT R
    	.ram_clk1(ram2_clk1),       	// (output) clock
    	.ram_csb1(ram2_csb1),       	// (output) active low chip select
    	.ram_addr1(ram2_addr1),	   		// (output) addr from wb sent to sram
    	.ram_din1(wbs_sram2_data1)	   	// (input) read from sram and sent to wb 
	);

	wishbone_wrapper_dp #(.NO_OF_ROWS(512)) SRAM3_WRAPPER(
    	.wb_clk_i(wb_clk_i),
    	.wb_rst_i(wb_rst_i),
    	.wbs_stb_i(wbs_or3_stb),
    	.wbs_cyc_i(wbs_or3_cyc),
    	.wbs_we_i(wbs_or3_we),
    	.wbs_sel_i(wbs_or3_sel),
    	.wbs_dat_i(wbs_or3_dat_o),
    	.wbs_adr_i(wbs_adr_i),
    	.wbs_ack_o(wbs_or3_ack),
    	.wbs_dat_o(wbs_or3_dat_i),
		// OpenRAM interface
		// PORT RW
    	.ram_clk0(ram3_clk0),       // (output) clock
    	.ram_csb0(ram3_csb0),       // (output) active low chip select
    	.ram_web0(ram3_web0),       // (output) active low write control
    	.ram_wmask0(ram3_wmask0),   // (output) write (byte) mask
    	.ram_addr0(ram3_addr0),	   // (output)
    	.ram_din0(wbs_sram3_data0),	   // (input) read from sram and sent through wb 
    	.ram_dout0(ram3_din0),	   // (output) read from wb and sent to sram
		// PORT R
    	.ram_clk1(ram3_clk1),       	// (output) clock
    	.ram_csb1(ram3_csb1),       	// (output) active low chip select
    	.ram_addr1(ram3_addr1),	   		// (output) addr from wb sent to sram
    	.ram_din1(wbs_sram3_data1)	   	// (input) read from sram and sent to wb 
	);

	wishbone_wrapper_dp #(.NO_OF_ROWS(1024)) SRAM4_WRAPPER(
    	.wb_clk_i(wb_clk_i),
    	.wb_rst_i(wb_rst_i),
    	.wbs_stb_i(wbs_or4_stb),
    	.wbs_cyc_i(wbs_or4_cyc),
    	.wbs_we_i(wbs_or4_we),
    	.wbs_sel_i(wbs_or4_sel),
    	.wbs_dat_i(wbs_or4_dat_o),
    	.wbs_adr_i(wbs_adr_i),
    	.wbs_ack_o(wbs_or4_ack),
    	.wbs_dat_o(wbs_or4_dat_i),
		// OpenRAM interface
		// PORT RW
    	.ram_clk0(ram4_clk0),       // (output) clock
    	.ram_csb0(ram4_csb0),       // (output) active low chip select
    	.ram_web0(ram4_web0),       // (output) active low write control
    	.ram_wmask0(ram4_wmask0),   // (output) write (byte) mask
    	.ram_addr0(ram4_addr0),	   // (output)
    	.ram_din0(wbs_sram4_data0),	   // (input) read from sram and sent through wb 
    	.ram_dout0(ram4_din0),	   // (output) read from wb and sent to sram
		// PORT R
    	.ram_clk1(ram4_clk1),       	// (output) clock
    	.ram_csb1(ram4_csb1),       	// (output) active low chip select
    	.ram_addr1(ram4_addr1),	   		// (output) addr from wb sent to sram
    	.ram_din1(wbs_sram4_data1)	   	// (input) read from sram and sent to wb 
	);

	wishbone_wrapper_dp #(.NO_OF_ROWS(512)) SRAM5_WRAPPER(
    	.wb_clk_i(wb_clk_i),
    	.wb_rst_i(wb_rst_i),
    	.wbs_stb_i(wbs_or5_stb),
    	.wbs_cyc_i(wbs_or5_cyc),
    	.wbs_we_i(wbs_or5_we),
    	.wbs_sel_i(wbs_or5_sel),
    	.wbs_dat_i(wbs_or5_dat_o),
    	.wbs_adr_i(wbs_adr_i),
    	.wbs_ack_o(wbs_or5_ack),
    	.wbs_dat_o(wbs_or5_dat_i),
		// OpenRAM interface
		// PORT RW
    	.ram_clk0(ram5_clk0),       // (output) clock
    	.ram_csb0(ram5_csb0),       // (output) active low chip select
    	.ram_web0(ram5_web0),       // (output) active low write control
    	.ram_wmask0(ram5_wmask0),   // (output) write (byte) mask
    	.ram_addr0(ram5_addr0),	   // (output)
    	.ram_din0(wbs_sram5_data0),	   // (input) read from sram and sent through wb 
    	.ram_dout0(ram5_din0),	   // (output) read from wb and sent to sram
		// PORT R
    	.ram_clk1(ram5_clk1),       	// (output) clock
    	.ram_csb1(ram5_csb1),       	// (output) active low chip select
    	.ram_addr1(ram5_addr1),	   		// (output) addr from wb sent to sram
    	.ram_din1(wbs_sram5_data1)	   	// (input) read from sram and sent to wb 
	);

	wishbone_wrapper_dp #(.NO_OF_ROWS(1024)) SRAM6_WRAPPER(
    	.wb_clk_i(wb_clk_i),
    	.wb_rst_i(wb_rst_i),
    	.wbs_stb_i(wbs_or6_stb),
    	.wbs_cyc_i(wbs_or6_cyc),
    	.wbs_we_i(wbs_or6_we),
    	.wbs_sel_i(wbs_or6_sel),
    	.wbs_dat_i(wbs_or6_dat_o),
    	.wbs_adr_i(wbs_adr_i),
    	.wbs_ack_o(wbs_or6_ack),
    	.wbs_dat_o(wbs_or6_dat_i),
		// OpenRAM interface
		// PORT RW
    	.ram_clk0(ram6_clk0),       // (output) clock
    	.ram_csb0(ram6_csb0),       // (output) active low chip select
    	.ram_web0(ram6_web0),       // (output) active low write control
    	.ram_wmask0(ram6_wmask0),   // (output) write (byte) mask
    	.ram_addr0(ram6_addr0),	   // (output)
    	.ram_din0(wbs_sram6_data0),	   // (input) read from sram and sent through wb 
    	.ram_dout0(ram6_din0),	   // (output) read from wb and sent to sram
		// PORT R
    	.ram_clk1(ram6_clk1),       	// (output) clock
    	.ram_csb1(ram6_csb1),       	// (output) active low chip select
    	.ram_addr1(ram6_addr1),	   		// (output) addr from wb sent to sram
    	.ram_din1(wbs_sram6_data1)	   	// (input) read from sram and sent to wb 
	);
// Splitting register bits into fields
always @(*) begin
	if (wb_select) begin
		if(wbs_stb_i && wbs_cyc_i) begin
			// select on the basis of strobe signals here
			// for example:
			// at any given time wbs_or8_stb or wbs_or9_stb will be active
			// based on that take their values and provide to the sram control signals 
			chip_select = 0;

			if(wbs_or8_stb) begin
				csb0_temp = ram8_csb0;
   				addr0 = ram8_addr0;
   				din0 = ram8_din0;
   				web0 = ram8_web0;
   				wmask0 = ram8_wmask0;
				// dont cares since sp sram
   				addr1 = sram_register[`PORT_SIZE-1:`DATA_SIZE+`WMASK_SIZE+2];
   				din1 = sram_register[`DATA_SIZE+`WMASK_SIZE+1:`WMASK_SIZE+2];
   				csb1_temp = global_csb | sram_register[`WMASK_SIZE+1];
   				web1 = sram_register[`WMASK_SIZE];
   				wmask1 = sram_register[`WMASK_SIZE-1:0];
			end

			if(wbs_or9_stb) begin
				csb0_temp = ram9_csb0;
   				addr0 = ram9_addr0;
   				din0 = ram9_din0;
   				web0 = ram9_web0;
   				wmask0 = ram9_wmask0;
				// dont cares since sp sram
   				addr1 = sram_register[`PORT_SIZE-1:`DATA_SIZE+`WMASK_SIZE+2];
   				din1 = sram_register[`DATA_SIZE+`WMASK_SIZE+1:`WMASK_SIZE+2];
   				csb1_temp = global_csb | sram_register[`WMASK_SIZE+1];
   				web1 = sram_register[`WMASK_SIZE];
   				wmask1 = sram_register[`WMASK_SIZE-1:0];
			end

			if(wbs_or10_stb) begin
				csb0_temp = ram10_csb0;
   				addr0 = ram10_addr0;
   				din0 = ram10_din0;
   				web0 = ram10_web0;
   				wmask0 = ram10_wmask0;
				// dont cares since sp sram
   				addr1 = sram_register[`PORT_SIZE-1:`DATA_SIZE+`WMASK_SIZE+2];
   				din1 = sram_register[`DATA_SIZE+`WMASK_SIZE+1:`WMASK_SIZE+2];
   				csb1_temp = global_csb | sram_register[`WMASK_SIZE+1];
   				web1 = sram_register[`WMASK_SIZE];
   				wmask1 = sram_register[`WMASK_SIZE-1:0];
			end

			if(wbs_or0_stb) begin 
				csb0_temp = ram0_csb0;
   				addr0 = ram0_addr0;
   				din0 = ram0_din0;
   				web0 = ram0_web0;
   				wmask0 = ram0_wmask0;
				// PORT R
   				addr1 = ram0_addr1;
   				din1 = sram_register[`DATA_SIZE+`WMASK_SIZE+1:`WMASK_SIZE+2]; // dont care since we never write from port1 on any sram
   				csb1_temp = ram0_csb1; 
   				web1 = sram_register[`WMASK_SIZE];			// dont care since we never write from port1 on any sram
   				wmask1 = sram_register[`WMASK_SIZE-1:0];    // dont care since we never write from port1 on any sram
			end

			if(wbs_or1_stb) begin
				csb0_temp = ram1_csb0;
   				addr0 = ram1_addr0;
   				din0 = ram1_din0;
   				web0 = ram1_web0;
   				wmask0 = ram1_wmask0;
				// FIXME: change this since now we are testing the dp sram
				// PORT R
   				addr1 = ram1_addr1;
   				din1 = sram_register[`DATA_SIZE+`WMASK_SIZE+1:`WMASK_SIZE+2]; // dont care since we never write from port1 on any sram
   				csb1_temp = ram1_csb1; 
   				web1 = sram_register[`WMASK_SIZE];			// dont care since we never write from port1 on any sram
   				wmask1 = sram_register[`WMASK_SIZE-1:0];    // dont care since we never write from port1 on any sram
			end

			if(wbs_or2_stb) begin
				csb0_temp = ram2_csb0;
   				addr0 = ram2_addr0;
   				din0 = ram2_din0;
   				web0 = ram2_web0;
   				wmask0 = ram2_wmask0;
				// PORT R
   				addr1 = ram2_addr1;
   				din1 = sram_register[`DATA_SIZE+`WMASK_SIZE+1:`WMASK_SIZE+2]; // dont care since we never write from port1 on any sram
   				csb1_temp = ram2_csb1; 
   				web1 = sram_register[`WMASK_SIZE];			// dont care since we never write from port1 on any sram
   				wmask1 = sram_register[`WMASK_SIZE-1:0];    // dont care since we never write from port1 on any sram
			end

			if(wbs_or3_stb) begin
				csb0_temp = ram3_csb0;
   				addr0 = ram3_addr0;
   				din0 = ram3_din0;
   				web0 = ram3_web0;
   				wmask0 = ram3_wmask0;
				// PORT R
   				addr1 = ram3_addr1;
   				din1 = sram_register[`DATA_SIZE+`WMASK_SIZE+1:`WMASK_SIZE+2]; // dont care since we never write from port1 on any sram
   				csb1_temp = ram3_csb1; 
   				web1 = sram_register[`WMASK_SIZE];			// dont care since we never write from port1 on any sram
   				wmask1 = sram_register[`WMASK_SIZE-1:0];    // dont care since we never write from port1 on any sram
			end

			if(wbs_or4_stb) begin
				csb0_temp = ram4_csb0;
   				addr0 = ram4_addr0;
   				din0 = ram4_din0;
   				web0 = ram4_web0;
   				wmask0 = ram4_wmask0;
				// PORT R
   				addr1 = ram4_addr1;
   				din1 = sram_register[`DATA_SIZE+`WMASK_SIZE+1:`WMASK_SIZE+2]; // dont care since we never write from port1 on any sram
   				csb1_temp = ram4_csb1; 
   				web1 = sram_register[`WMASK_SIZE];			// dont care since we never write from port1 on any sram
   				wmask1 = sram_register[`WMASK_SIZE-1:0];    // dont care since we never write from port1 on any sram
			end

			if(wbs_or5_stb) begin
				csb0_temp = ram5_csb0;
   				addr0 = ram5_addr0;
   				din0 = ram5_din0;
   				web0 = ram5_web0;
   				wmask0 = ram5_wmask0;
				// PORT R
   				addr1 = ram5_addr1;
   				din1 = sram_register[`DATA_SIZE+`WMASK_SIZE+1:`WMASK_SIZE+2]; // dont care since we never write from port1 on any sram
   				csb1_temp = ram5_csb1; 
   				web1 = sram_register[`WMASK_SIZE];			// dont care since we never write from port1 on any sram
   				wmask1 = sram_register[`WMASK_SIZE-1:0];    // dont care since we never write from port1 on any sram
			end

			if(wbs_or6_stb) begin
				csb0_temp = ram6_csb0;
   				addr0 = ram6_addr0;
   				din0 = ram6_din0;
   				web0 = ram6_web0;
   				wmask0 = ram6_wmask0;
				// PORT R
   				addr1 = ram6_addr1;
   				din1 = sram_register[`DATA_SIZE+`WMASK_SIZE+1:`WMASK_SIZE+2]; // dont care since we never write from port1 on any sram
   				csb1_temp = ram6_csb1; 
   				web1 = sram_register[`WMASK_SIZE];			// dont care since we never write from port1 on any sram
   				wmask1 = sram_register[`WMASK_SIZE-1:0];    // dont care since we never write from port1 on any sram
			end
		end else begin
			// wishbone mode but did not receive request (stb && cyc != 1)
			chip_select = 0;

   			addr0 = sram_register[`ADDR_SIZE+`DATA_SIZE+`PORT_SIZE+`WMASK_SIZE+1:`DATA_SIZE+`PORT_SIZE+`WMASK_SIZE+2];
   			din0 = sram_register[`DATA_SIZE+`PORT_SIZE+`WMASK_SIZE+1:`PORT_SIZE+`WMASK_SIZE+2];
   			csb0_temp = 1'b1;
   			web0 = sram_register[`PORT_SIZE+`WMASK_SIZE];
   			wmask0 = sram_register[`PORT_SIZE+`WMASK_SIZE-1:`PORT_SIZE];

   			addr1 = sram_register[`PORT_SIZE-1:`DATA_SIZE+`WMASK_SIZE+2];
   			din1 = sram_register[`DATA_SIZE+`WMASK_SIZE+1:`WMASK_SIZE+2];
   			csb1_temp = 1'b1;
   			web1 = sram_register[`WMASK_SIZE];
   			wmask1 = sram_register[`WMASK_SIZE-1:0];
   		end
	end else begin
		// gpio/la mode
		chip_select = sram_register[`TOTAL_SIZE-1:`TOTAL_SIZE-`SELECT_SIZE];

   		addr0 = sram_register[`ADDR_SIZE+`DATA_SIZE+`PORT_SIZE+`WMASK_SIZE+1:`DATA_SIZE+`PORT_SIZE+`WMASK_SIZE+2];
   		din0 = sram_register[`DATA_SIZE+`PORT_SIZE+`WMASK_SIZE+1:`PORT_SIZE+`WMASK_SIZE+2];
   		csb0_temp = global_csb | sram_register[`PORT_SIZE+`WMASK_SIZE+1];
   		web0 = sram_register[`PORT_SIZE+`WMASK_SIZE];
   		wmask0 = sram_register[`PORT_SIZE+`WMASK_SIZE-1:`PORT_SIZE];

 		addr1 = sram_register[`PORT_SIZE-1:`DATA_SIZE+`WMASK_SIZE+2];
   		din1 = sram_register[`DATA_SIZE+`WMASK_SIZE+1:`WMASK_SIZE+2];
   		csb1_temp = global_csb | sram_register[`WMASK_SIZE+1];
   		web1 = sram_register[`WMASK_SIZE];
   		wmask1 = sram_register[`WMASK_SIZE-1:0];

	end

end

// Apply the correct CSB
always @(*) begin
	// this can be improved like the following:
	if(wb_select) begin
		if(wbs_stb_i && wbs_cyc_i) begin
		    if(wbs_or8_stb) begin 
				csb0 = {7'b1111111, csb0_temp, 8'b11111111};
				csb1 = {16{1'b1}};
			end
			if(wbs_or9_stb) begin
				csb0 = {6'b111111, csb0_temp, 9'b111111111};
				csb1 = {16{1'b1}};
			end
			if(wbs_or10_stb) begin 
				csb0 = {5'b11111, csb0_temp, 10'b1111111111};
				csb1 = {16{1'b1}};
			end
			if(wbs_or0_stb) begin
				csb0 = {15'b111111111111111, csb0_temp};
				csb1 = {15'b111111111111111, csb1_temp};
			end
			if(wbs_or1_stb) begin
				csb0 = {14'b11111111111111, csb0_temp, 1'b1};
				csb1 = {14'b11111111111111, csb1_temp, 1'b1};
			end
			if(wbs_or2_stb) begin
				csb0 = {13'b1111111111111, csb0_temp, 2'b11};
				csb1 = {13'b1111111111111, csb1_temp, 2'b11};
			end
			if(wbs_or3_stb) begin
				csb0 = {12'b111111111111, csb0_temp, 3'b111};
				csb1 = {12'b111111111111, csb1_temp, 3'b111};
			end
			if(wbs_or4_stb) begin
				csb0 = {11'b11111111111, csb0_temp, 4'b1111};
				csb1 = {11'b11111111111, csb1_temp, 4'b1111};
			end
			if(wbs_or5_stb) begin
				csb0 = {10'b1111111111, csb0_temp, 5'b11111};
				csb1 = {10'b1111111111, csb1_temp, 5'b11111};
			end
			if(wbs_or6_stb) begin
				csb0 = {9'b111111111, csb0_temp, 6'b111111};
				csb1 = {9'b111111111, csb1_temp, 6'b111111};
			end
		end
		else begin
			// wishbone mode but did not receive request (stb && cyc != 1)
				csb0 = {16{1'b1}};
				csb1 = {16{1'b1}};
		end
	end
	else begin
		// gpio/la mode	
   		csb0 = ~( (~{15'b111111111111111, csb0_temp}) << chip_select);
   		csb1 = ~(  (~{15'b111111111111111, csb1_temp}) << chip_select);
	end
end

// Mux value of correct SRAM data input to feed into
// DFF clocked by la/gpio clk
always @ (*) begin
    case(chip_select)
    4'd0: begin
       read_data0 = sram0_data0;
       read_data1 = sram0_data1;
    end
    4'd1: begin
       read_data0 = sram1_data0;
       read_data1 = sram1_data1;
    end
    4'd2: begin
       read_data0 = sram2_data0;
       read_data1 = sram2_data1;
    end
    4'd3: begin
       read_data0 = sram3_data0;
       read_data1 = sram3_data1;
    end
    4'd4: begin
       read_data0 = sram4_data0;
       read_data1 = sram4_data1;
    end
    4'd5: begin
       read_data0 = sram5_data0;
       read_data1 = sram5_data1;
    end
    4'd6: begin
       read_data0 = sram6_data0;
       read_data1 = sram6_data1;
    end
    4'd7: begin
       read_data0 = sram7_data0;
       read_data1 = sram7_data1;
    end
    4'd8: begin
       read_data0 = sram8_data0;
       read_data1 = sram8_data1;
    end
    4'd9: begin
       read_data0 = sram9_data0;
       read_data1 = sram9_data1;
    end
    4'd10: begin
       read_data0 = sram10_data0;
       read_data1 = sram10_data1;
    end
    4'd11: begin
       read_data0 = sram11_data0;
       read_data1 = sram11_data1;
    end
    4'd12: begin
       read_data0 = sram12_data0;
       read_data1 = sram12_data1;
    end
    4'd13: begin
       read_data0 = sram13_data0;
       read_data1 = sram13_data1;
    end
    4'd14: begin
       read_data0 = sram14_data0;
       read_data1 = sram14_data1;
    end
    4'd15: begin
       read_data0 = sram15_data0;
       read_data1 = sram15_data1;
    end
	default: begin
       read_data0 = sram0_data0;
       read_data1 = sram0_data1;
	end
    endcase
end

// Output logic
always @ (*) begin
   gpio_out = sram_register[`TOTAL_SIZE-1];
   la_data_out = sram_register;
end

endmodule
