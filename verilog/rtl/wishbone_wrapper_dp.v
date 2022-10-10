`default_nettype none

module wishbone_wrapper_dp
#(
    parameter NO_OF_ROWS = 0
)
(
	`ifdef USE_POWER_PINS
	    inout vccd1,	// User area 1 1.8V supply
	    inout vssd1,	// User area 1 digital ground
	`endif

    // Wishbone port A
    input           wb_clk_i,
    input           wb_rst_i,
    input           wbs_stb_i,
    input           wbs_cyc_i,
    input           wbs_we_i,
    input   [3:0]   wbs_sel_i,
    input   [31:0]  wbs_dat_i,
    input   [31:0]  wbs_adr_i,
    output          wbs_ack_o,
    output  [31:0]  wbs_dat_o,

    // OpenRAM interface - almost dual port: RW + R
    // Port 0: RW
    output                      ram_clk0,       // clock
    output                      ram_csb0,       // active low chip select
    output                      ram_web0,       // active low write control
    output  [3:0]              	ram_wmask0,     // write (byte) mask
    output  [13:0]    			ram_addr0,
    input   [31:0]              ram_din0,
    output  [31:0]              ram_dout0,
	
    // Port 1: R
	// add ports here
    output  					ram_clk1,
    output  					ram_csb1,
    output  [13:0]    			ram_addr1,
    input   [31:0]              ram_din1

);

//	parameter ADDR_LO_MASK = (1 << ADDR_WIDTH) - 1;
//	parameter ADDR_HI_MASK = 32'hffff_ffff - ADDR_LO_MASK;

    parameter WB_ADDR_RANGE = NO_OF_ROWS * 4; 	// since the mapping of addr is wb(0) -> sram row 0, wb(4) -> sram row 1 ...
	parameter LAST_ADDR = WB_ADDR_RANGE - 4;
	parameter CSB0_END = (WB_ADDR_RANGE/2) - 4;
	parameter CSB1_START = CSB0_END + 4;
	
	wire ram_cs;
//	aassign ram_cs = wbs_stb_i && wbs_cyc_i && ((wbs_adr_i & ADDR_HI_MASK) == BASE_ADDR) && !wb_rst_i;
    assign ram_cs = wbs_stb_i & wbs_cyc_i & !wb_rst_i;
	reg ram_cs_r;
	reg ram_wbs_ack_r;

	reg enable_csb0;
	reg enable_csb1;

	reg [31:0] sram_read_data;

	always @(negedge wb_clk_i) begin
	    if (wb_rst_i) begin
	        ram_cs_r <= 0;
	        ram_wbs_ack_r <= 0;
	    end
	    else begin
	        ram_cs_r <= !ram_cs_r && ram_cs;
	        ram_wbs_ack_r <= ram_cs_r;
	    end
	end

	always @(*) begin
		if (~wbs_we_i) begin
		    // reading operation. Detect whether to enable csb0 or csb1
			if (wbs_adr_i[15:0] <= CSB0_END) begin
				// enable csb0
				enable_csb0 = !ram_cs_r;
				enable_csb1 = 1'b1;
				sram_read_data = ram_din0;
			end
			else begin
				// enable csb1
				enable_csb1 = !ram_cs_r;
				enable_csb0 = 1'b1;
				sram_read_data = ram_din1;
			end
		end
		else begin
		    // writing operation. Only enable csb0
			enable_csb0 = !ram_cs_r;
			enable_csb1 = 1'b1;
			sram_read_data = ram_din0;		// don't care here
		end

	end
	     
	assign ram_clk0 = wb_clk_i;
	assign ram_csb0 = enable_csb0;
	assign ram_clk1 = wb_clk_i;
	assign ram_csb1 = enable_csb1;
	assign ram_web0 = ~wbs_we_i;
	assign ram_wmask0 = wbs_sel_i;
	assign ram_addr0 = wbs_adr_i[15:2];
	assign ram_addr1 = wbs_adr_i[15:2];
	assign ram_dout0 = wbs_dat_i;
	
	assign wbs_dat_o = sram_read_data;
	assign wbs_ack_o = ram_wbs_ack_r && ram_cs;




endmodule

`default_nettype wire
