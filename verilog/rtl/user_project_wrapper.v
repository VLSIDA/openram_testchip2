// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * user_project_wrapper
 *
 * This wrapper enumerates all of the pins available to the
 * user for the user project.
 *
 * An example user project is provided in this wrapper.  The
 * example should be removed and replaced with the actual
 * user project.
 *
 *-------------------------------------------------------------
 */
module user_project_wrapper #(
    parameter BITS = 32
) (
`ifdef USE_POWER_PINS
    inout vdda1,	// User area 1 3.3V supply
    inout vdda2,	// User area 2 3.3V supply
    inout vssa1,	// User area 1 analog ground
    inout vssa2,	// User area 2 analog ground
    inout vccd1,	// User area 1 1.8V supply
    inout vccd2,	// User area 2 1.8v supply
    inout vssd1,	// User area 1 digital ground
    inout vssd2,	// User area 2 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,

    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb,

    // Analog (direct connection to GPIO pad---use with caution)
    // Note that analog I/O is not available on the 7 lowest-numbered
    // GPIO pads, and so the analog_io indexing is offset from the
    // GPIO indexing by 7 (also upper 2 GPIOs do not have analog_io).
    inout [`MPRJ_IO_PADS-10:0] analog_io,

    // Independent clock (on independent integer divider)
    input   user_clock2,

    // User maskable interrupt signals
    output [2:0] user_irq
);


   assign la_data_out[127:112] = 0;

   // Shared control/data to the SRAMs
   wire [`ADDR_SIZE-1:0] addr0;
   wire [`DATA_SIZE-1:0] din0;
   wire 		 web0;
   wire [`WMASK_SIZE-1:0] wmask0;
   wire [`ADDR_SIZE-1:0]  addr1;
   wire [`DATA_SIZE-1:0]  din1;
   wire 		  web1;
   wire [`WMASK_SIZE-1:0] wmask1;
   // One CSB for each SRAM
   wire [`MAX_CHIPS-1:0]  csb0;
   wire [`MAX_CHIPS-1:0]  csb1;

   // specifies whether to use wishbone interface or gpio/la mode
   // mode_select[1] -> wishbone mode
   // mode_select[0] -> gpio or la (wishbone takes priority)
   wire [1:0]    mode_select = {io_in[`MODE_SELECT1],io_in[`MODE_SELECT0]};
   wire     gpio_resetn = io_in[`GPIO_RESETN];
   wire     gpio_clk = io_in[`GPIO_CLK];
   wire     gpio_scan = io_in[`GPIO_SCAN];
   wire     gpio_sram_load = io_in[`GPIO_SRAM_LOAD];
   wire     gpio_global_csb = io_in[`GPIO_GLOBAL_CSB];
   wire     gpio_in = io_in[`GPIO_IN];
   wire     la_clk = la_data_in[127];
   wire     la_reset = la_data_in[126];
   wire     la_in_load = la_data_in[125];
   wire     la_sram_load = la_data_in[124];
   wire     la_global_cs = la_data_in[123];

   // Only io_out[`GPIO_OUT] is output
   assign io_oeb = ~(1'b1 << `GPIO_OUT);

   wire     gpio_out;
   assign io_out[`GPIO_OUT] = gpio_out;
   // Assign other outputs to 0
   assign io_out[`MPRJ_IO_PADS-1:`GPIO_OUT+1] = 0;
   assign io_out[`GPIO_OUT-1:0] = 0;

   // not using them
   assign user_irq[2:0] = 0;

    rram_test rram_test_0
    (
      `ifdef USE_POWER_PINS
     .vccd1(vccd1),
     .vssd1(vssd1),
      `endif
    .pVDD_HEADER0(io_in[`PVDD_HEADER0]),
    .pGND_HEADER0(io_in[`PGND_HEADER0]),
    .pVDD_HEADER1(io_in[`PVDD_HEADER1]),
    .pGND_HEADER1(io_in[`PGND_HEADER1]),
    .p1T1R_TE(analog_io[`P1T1R_TE]),
    .p1T1R_WL(analog_io[`P1T1R_WL]),
    .p036_SL(analog_io[`P036_SL]),
    .p100_SL(analog_io[`P100_SL]),
    .p300_SL(analog_io[`P300_SL]),
    .p700_SL(analog_io[`P700_SL]),
    .p1R_TE(analog_io[`P1R_TE]),
    .p1R_SL(analog_io[`P1R_SL]),
    .BL0(analog_io[`BL0]),
    .BL1(analog_io[`BL1]),
    .BR0(analog_io[`BR0]),
    .BR1(analog_io[`BR1]),
    .RE_BL0(analog_io[`RE_BL0]),
    .RE_BL1(analog_io[`RE_BL1]),
    .RE_BR0(analog_io[`RE_BR0]),
    .RE_BR1(analog_io[`RE_BR1]),
    .WL0(analog_io[`WL0]),
    .WL1(analog_io[`WL1]),
    .RE_WL0(analog_io[`RE_WL0]),
    .RE_WL1(analog_io[`RE_WL1])
    );

   // Selecting clock and reset pin
   reg clk;
   reg rstn;
   reg global_csb;

   // 4 modes
   // 00 <- la test mode
   // 01 <- gpio test mode
   // 10 <- wb test mode
   // 11 <- rram test mode
   always @(*) begin
	  case (mode_select)
	  	2'b00 : clk = la_clk;
		2'b01 : clk = gpio_clk;
		2'b10 : clk = wb_clk_i;
		default : clk = 1'b0;
	  endcase
   end

   always @(*) begin
	  case (mode_select)
	  	2'b00 : rstn = ~la_reset;
		2'b01 : rstn = gpio_resetn;
		default : rstn = 1'b1;
	  endcase
   end

   always @(*) begin
	  case (mode_select)
	  	2'b00 : global_csb   = ~la_global_cs;
		2'b01 : global_csb   = gpio_global_csb;
		default : global_csb = 1'b1;
	  endcase
   end

   // global csb is low with either GPIO or LA csb
   // la_global_cs is low because default LA values are 0
   //wire global_csb = gpio_global_csb & ~la_global_cs;
   // rstn is low with either GPIO or LA reset
   // la_reset is not active low because default LA values are 0
   //wire rstn = gpio_resetn & ~la_reset;

   wire wb_select = mode_select[1] & ~mode_select[0];

   openram_testchip CONTROL_LOGIC(
				  .resetn(rstn),
				  .clk(clk),
				  .global_csb(global_csb),
				  .wb_select(wb_select),
				  // gpio related control signals
				  .gpio_scan(gpio_scan),
				  .gpio_sram_load(gpio_sram_load),
				  .gpio_in(gpio_in),
				  .gpio_out(gpio_out),
				  // la related control signals
				  .la_in_load(la_in_load),
				  .la_sram_load(la_sram_load),
				  .la_data_in(la_data_in[111:0]),
				  .la_data_out(la_data_out[111:0]),
				  // wishbone related control signals
    			  .wb_clk_i(wb_clk_i),
    			  .wb_rst_i(wb_rst_i),
    			  .wbs_stb_i(wbs_stb_i),
    			  .wbs_cyc_i(wbs_cyc_i),
    			  .wbs_we_i(wbs_we_i),
    			  .wbs_sel_i(wbs_sel_i),
    			  .wbs_dat_i(wbs_dat_i),
    			  .wbs_adr_i(wbs_adr_i),
    			  .wbs_ack_o(wbs_ack_o),
    			  .wbs_dat_o(wbs_dat_o),
				  .wbs_sram8_data(sram8_dout0),
				  .wbs_sram9_data0(sram9_dout0),
				  .wbs_sram9_data1(sram9_dout1),
				  .wbs_sram10_data(sram10_dout0),
				  .wbs_sram0_data0(sram0_dout0),
				  .wbs_sram0_data1(sram0_dout1),
				  .wbs_sram1_data0(sram1_dout0),
				  .wbs_sram1_data1(sram1_dout1),
				  .wbs_sram2_data0(sram2_dout0),
				  .wbs_sram2_data1(sram2_dout1),
				  .wbs_sram3_data0(sram3_dout0),
				  .wbs_sram3_data1(sram3_dout1),
				  .wbs_sram4_data0(sram4_dout0),
				  .wbs_sram4_data1(sram4_dout1),
				  .wbs_sram5_data0(sram5_dout0),
				  .wbs_sram5_data1(sram5_dout1),
				  .wbs_rom0_data(rom0_dout),
				  // Shared control/data to the SRAMs
				  .addr0(addr0),
				  .din0(din0),
				  // One CSB for each SRAM
				  .csb0(csb0),
				  .web0(web0),
				  .wmask0(wmask0),
				  .addr1(addr1),
				  .din1(din1),
				  // One CSB for each SRAM
				  .csb1(csb1),
				  .web1(web1),
				  .wmask1(wmask1),

				  // SRAM data outputs to be captured
				  .sram0_data0(sram0_data0),
				  .sram0_data1(sram0_data1),
				  .sram1_data0(sram1_data0),
				  .sram1_data1(sram1_data1),
				  .sram2_data0(sram2_data0),
				  .sram2_data1(sram2_data1),
				  .sram3_data0(sram3_data0),
				  .sram3_data1(sram3_data1),
				  .sram4_data0(sram4_data0),
				  .sram4_data1(sram4_data1),
				  .sram5_data0(sram5_data0),
				  .sram5_data1(sram5_data1),
				  .rom0_data(rom0_data),
				  .sram6_data0(sram6_data0),
				  .sram6_data1(sram6_data1),
				  .sram7_data0(sram7_data0),
				  .sram7_data1(sram7_data1),
				  .sram8_data0(sram8_data0),
				  .sram8_data1(sram8_data1),
				  .sram9_data0(sram9_data0),
				  .sram9_data1(sram9_data1),
				  .sram10_data0(sram10_data0),
				  .sram10_data1(sram10_data1),
				  .sram11_data0(sram11_data0),
				  .sram11_data1(sram11_data1),
				  .sram12_data0(sram12_data0),
				  .sram12_data1(sram12_data1),
				  .sram13_data0(sram13_data0),
				  .sram13_data1(sram13_data1),
				  .sram14_data0(sram14_data0),
				  .sram14_data1(sram14_data1),
				  .sram15_data0(sram15_data0),
				  .sram15_data1(sram15_data1)

				  );

   wire [`DATA_SIZE-1:0]  sram0_dout0;
   wire [`DATA_SIZE-1:0]  sram0_dout1;
   wire [`DATA_SIZE-1:0]  sram1_dout0;
   wire [`DATA_SIZE-1:0]  sram1_dout1;
   wire [`DATA_SIZE-1:0]  sram2_dout0;
   wire [`DATA_SIZE-1:0]  sram2_dout1;
   wire [`DATA_SIZE-1:0]  sram3_dout0;
   wire [`DATA_SIZE-1:0]  sram3_dout1;
   wire [`DATA_SIZE-1:0]  sram4_dout0;
   wire [`DATA_SIZE-1:0]  sram4_dout1;
   wire [`DATA_SIZE-1:0]  sram5_dout0;
   wire [`DATA_SIZE-1:0]  sram5_dout1;
   wire [`DATA_SIZE-1:0]  rom0_dout;
   wire [`DATA_SIZE-1:0]  sram6_dout0 = 0;
   wire [`DATA_SIZE-1:0]  sram6_dout1 = 0;
   wire [`DATA_SIZE-1:0]  sram7_dout0 = 0;
   wire [`DATA_SIZE-1:0]  sram7_dout1 = 0;
   wire [`DATA_SIZE-1:0]  sram8_dout0;
   wire [`DATA_SIZE-1:0]  sram8_dout1 = 0;
   wire [`DATA_SIZE-1:0]  sram9_dout0;
   wire [`DATA_SIZE-1:0]  sram9_dout1;
   wire [`DATA_SIZE-1:0]  sram10_dout0;
   wire [`DATA_SIZE-1:0]  sram10_dout1 = 0;
   wire [`DATA_SIZE-1:0]  sram11_dout0 = 0;
   wire [`DATA_SIZE-1:0]  sram11_dout1 = 0;
   wire [`DATA_SIZE-1:0]  sram12_dout0 = 0;
   wire [`DATA_SIZE-1:0]  sram12_dout1 = 0;
   wire [`DATA_SIZE-1:0]  sram13_dout0 = 0;
   wire [`DATA_SIZE-1:0]  sram13_dout1 = 0;
   wire [`DATA_SIZE-1:0]  sram14_dout0 = 0;
   wire [`DATA_SIZE-1:0]  sram14_dout1 = 0;
   wire [`DATA_SIZE-1:0]  sram15_dout0 = 0;
   wire [`DATA_SIZE-1:0]  sram15_dout1 = 0;

sky130_sram_1kbyte_1rw1r_8x1024_8 SRAM0
     (
     `ifdef USE_POWER_PINS
      .vccd1(vccd1),
      .vssd1(vssd1),
      `endif
      .clk0   (clk),
      .csb0   (csb0[0]),
      .web0   (web0),
      .addr0  (addr0[9:0]),
      .din0   (din0[7:0]),
      .dout0  (sram0_dout0[7:0]),
      .clk1   (clk),
      .csb1   (csb1[0]),
      .addr1  (addr1[9:0]),
      .dout1  (sram0_dout1[7:0])
      );
   assign sram0_dout0[`DATA_SIZE-1:8] = 0;
   assign sram0_dout1[`DATA_SIZE-1:8] = 0;
		
sky130_sram_1kbyte_1rw1r_32x256_8 SRAM1
     (
     `ifdef USE_POWER_PINS
      .vccd1(vccd1),
      .vssd1(vssd1),
      `endif
      .clk0   (clk),
      .csb0   (csb0[1]),
      .web0   (web0),
      .wmask0 (wmask0),
      .addr0  (addr0[7:0]),
      .din0   (din0),
      .dout0  (sram1_dout0),
      .clk1   (clk),
      .csb1   (csb1[1]),
      .addr1  (addr1[7:0]),
      .dout1  (sram1_dout1)
      );

sram_2kbyte_32b_2bank SRAM2
     (
     `ifdef USE_POWER_PINS
      .vccd1(vccd1),
      .vssd1(vssd1),
      `endif
      .clk0   (clk),
      .csb0   (csb0[2]),
      .web0   (web0),
      .wmask0 (wmask0),
      .addr0  (addr0[8:0]),
      .din0   (din0),
      .dout0  (sram2_dout0),
      .clk1   (clk),
      .csb1   (csb1[2]),
      .addr1  (addr1[8:0]),
      .dout1  (sram2_dout1)
      );

sky130_sram_2kbyte_1rw1r_32x512_8 SRAM3
     (
     `ifdef USE_POWER_PINS
      .vccd1(vccd1),
      .vssd1(vssd1),
      `endif
      .clk0   (clk),
      .csb0   (csb0[3]),
      .web0   (web0),
      .wmask0 (wmask0),
      .addr0  (addr0[8:0]),
      .din0   (din0),
      .dout0  (sram3_dout0),
      .clk1   (clk),
      .csb1   (csb1[3]),
      .addr1  (addr1[8:0]),
      .dout1  (sram3_dout1)
      );

sky130_sram_4kbyte_1rw1r_32x1024_8 SRAM4
     (
     `ifdef USE_POWER_PINS
      .vccd1(vccd1),
      .vssd1(vssd1),
      `endif
      .clk0   (clk),
      .csb0   (csb0[4]),
      .web0   (web0),
      .wmask0 (wmask0),
      .addr0  (addr0[9:0]),
      .din0   (din0),
      .dout0  (sram4_dout0),
      .clk1   (clk),
      .csb1   (csb1[4]),
      .addr1  (addr1[9:0]),
      .dout1  (sram4_dout1)
      );

sky130_sram_2kbyte_1rw1r_32x512_8 SRAM5
     (
     `ifdef USE_POWER_PINS
      .vccd1(vccd1),
      .vssd1(vssd1),
      `endif
      .clk0   (clk),
      .csb0   (csb0[5]),
      .web0   (web0),
      .wmask0 (wmask0),
      .addr0  (addr0[8:0]),
      .din0   (din0),
      .dout0  (sram5_dout0),
      .clk1   (clk),
      .csb1   (csb1[5]),
      .addr1  (addr1[8:0]),
      .dout1  (sram5_dout1)
      );

 rom_wrapper ROM0
      (
      `ifdef USE_POWER_PINS
       .vccd1(vccd1),
       .vssd1(vssd1),
       `endif
       .clk   (clk),
       .cs   (~csb0[11]),
       .addr  (addr0[9:0]),
       .dout  (rom0_dout[7:0])
       );

   assign rom0_dout[`DATA_SIZE-1:8] = 0;

 /* sky130_sram_4kbyte_1rw1r_32x1024_8 SRAM6 */
 /*      ( */
 /*      `ifdef USE_POWER_PINS */
 /*       .vccd1(vccd1), */
 /*       .vssd1(vssd1), */
 /*       `endif */
 /*       .clk0   (clk), */
 /*       .csb0   (csb0[6]), */
 /*       .web0   (web0), */
 /*       .wmask0 (wmask0), */
 /*       .addr0  (addr0[9:0]), */
 /*       .din0   (din0), */
 /*       .dout0  (sram6_dout0), */
 /*       .clk1   (clk), */
 /*       .csb1   (csb1[6]), */
 /*       .addr1  (addr1[9:0]), */
 /*       .dout1  (sram6_dout1) */
 /*       ); */



// Single port memories

wire disconn8, disconn9, disconn10, disconn11, disconn12;

sky130_sram_1kbyte_1rw_32x256_8 SRAM8
    (
      `ifdef USE_POWER_PINS
     .vccd1(vccd1),
     .vssd1(vssd1),
      `endif
     .clk0   (clk),
     .csb0   (csb0[8]),
     .web0   (web0),
     .wmask0 (wmask0),
     .addr0  (addr0[8:0]),
     .din0   ({1'b0, din0}),
     .dout0  ({disconn8, sram8_dout0}),
     .spare_wen0(1'b0)
     );

 sky130_sram_1kbyte_1rw1r_8x1024_8_norbl SRAM9 (
     `ifdef USE_POWER_PINS
      .vccd1(vccd1),
      .vssd1(vssd1),
      `endif
      .clk0   (clk),
      .csb0   (csb0[9]),
      .web0   (web0),
      .addr0  (addr0[9:0]),
      .din0   (din0[7:0]),
      .dout0  (sram9_dout0[7:0]),
      .clk1   (clk),
      .csb1   (csb1[9]),
      .addr1  (addr1[9:0]),
      .dout1  (sram9_dout1[7:0])
 );
   assign sram9_dout0[`DATA_SIZE-1:8] = 0;
   assign sram9_dout1[`DATA_SIZE-1:8] = 0;

//sky130_sram_2kbyte_1rw_32x512_8 SRAM9
//    (
//      `ifdef USE_POWER_PINS
//     .vccd1(vccd1),
//     .vssd1(vssd1),
//      `endif
//     .clk0   (clk),
//     .csb0   (csb0[9]),
//     .web0   (web0),
//     .wmask0 (wmask0),
//     .addr0  (addr0[9:0]),
//     .din0   ({1'b0, din0}),
//     .dout0  ({disconn9, sram9_dout0}),
//     .spare_wen0(1'b0)
//     );


sky130_sram_2kbyte_1rw_32x512_8 SRAM10
    (
      `ifdef USE_POWER_PINS
     .vccd1(vccd1),
     .vssd1(vssd1),
      `endif
     .clk0   (clk),
     .csb0   (csb0[10]),
     .web0   (web0),
     .wmask0 (wmask0),
     .addr0  (addr0[9:0]),
     .din0   ({1'b0, din0}),
     .dout0  ({disconn10, sram10_dout0}),
     .spare_wen0(1'b0)
     );
//   wire [63:0] temp_sram11_dout0;
//sky130_sram_4kbyte_1rw_64x512_8 SRAM11
//    (
//      `ifdef USE_POWER_PINS
//     .vccd1(vccd1),
//     .vssd1(vssd1),
//      `endif
//     .clk0   (clk),
//     .csb0   (csb0[11]),
//     .web0   (web0),
//     .wmask0 ({wmask0[3:2],4'hF,wmask0[1:0]}),
//     .addr0  (addr0),
//     .din0   ({1'b0, din0, din0}),
//     .dout0  ({disconn11, temp_sram11_dout0}),
//     .spare_wen0(1'b0)
//     );
//   assign sram11_dout0 = {temp_sram11_dout0[63:48], temp_sram11_dout0[15:0]};

//   wire [63:0] temp_sram12_dout0;
//sky130_sram_8kbyte_1rw_64x1024_8 SRAM12
//    (
//      `ifdef USE_POWER_PINS
//     .vccd1(vccd1),
//     .vssd1(vssd1),
//      `endif
//     .clk0   (clk),
//     .csb0   (csb0[12]),
//     .web0   (web0),
//     .wmask0 ({wmask0[3:2],4'hF,wmask0[1:0]}),
//     .addr0  (addr0),
//     .din0   ({1'b0, din0, din0}),
//     .dout0  ({disconn12, temp_sram12_dout0}),
//     .spare_wen0(1'b0)
//     );
//   assign sram12_dout0 = {temp_sram12_dout0[63:48], temp_sram12_dout0[15:0]};

   // Hold dout from SRAM
   // clocked by SRAM clk
   reg [`DATA_SIZE-1:0] sram0_data0;
   reg [`DATA_SIZE-1:0] sram0_data1;
   reg [`DATA_SIZE-1:0] sram1_data0;
   reg [`DATA_SIZE-1:0] sram1_data1;
   reg [`DATA_SIZE-1:0] sram2_data0;
   reg [`DATA_SIZE-1:0] sram2_data1;
   reg [`DATA_SIZE-1:0] sram3_data0;
   reg [`DATA_SIZE-1:0] sram3_data1;
   reg [`DATA_SIZE-1:0] sram4_data0;
   reg [`DATA_SIZE-1:0] sram4_data1;
   reg [`DATA_SIZE-1:0] sram5_data0;
   reg [`DATA_SIZE-1:0] sram5_data1;
   reg [`DATA_SIZE-1:0] rom0_data;
   reg [`DATA_SIZE-1:0] sram6_data0;
   reg [`DATA_SIZE-1:0] sram6_data1;
   reg [`DATA_SIZE-1:0] sram7_data0;
   reg [`DATA_SIZE-1:0] sram7_data1;
   reg [`DATA_SIZE-1:0] sram8_data0;
   reg [`DATA_SIZE-1:0] sram8_data1;
   reg [`DATA_SIZE-1:0] sram9_data0;
   reg [`DATA_SIZE-1:0] sram9_data1;
   reg [`DATA_SIZE-1:0] sram10_data0;
   reg [`DATA_SIZE-1:0] sram10_data1;
   reg [`DATA_SIZE-1:0] sram11_data0;
   reg [`DATA_SIZE-1:0] sram11_data1;
   reg [`DATA_SIZE-1:0] sram12_data0;
   reg [`DATA_SIZE-1:0] sram12_data1;
   reg [`DATA_SIZE-1:0] sram13_data0;
   reg [`DATA_SIZE-1:0] sram13_data1;
   reg [`DATA_SIZE-1:0] sram14_data0;
   reg [`DATA_SIZE-1:0] sram14_data1;
   reg [`DATA_SIZE-1:0] sram15_data0;
   reg [`DATA_SIZE-1:0] sram15_data1;

   always @(posedge clk) begin
      if (!rstn) begin
	 sram0_data0 <= 0;
	 sram0_data1 <= 0;
	 sram1_data0 <= 0;
	 sram1_data1 <= 0;
	 sram2_data0 <= 0;
	 sram2_data1 <= 0;
	 sram3_data0 <= 0;
	 sram3_data1 <= 0;
	 sram4_data0 <= 0;
	 sram4_data1 <= 0;
	 sram5_data0 <= 0;
	 sram5_data1 <= 0;
	 rom0_data   <= 0;
	 sram6_data0 <= 0;
	 sram6_data1 <= 0;
	 sram7_data0 <= 0;
	 sram7_data1 <= 0;
	 sram8_data0 <= 0;
	 sram8_data1 <= 0;
	 sram9_data0 <= 0;
	 sram9_data1 <= 0;
	 sram10_data0 <= 0;
	 sram10_data1 <= 0;
	 sram11_data0 <= 0;
	 sram11_data1 <= 0;
	 sram12_data0 <= 0;
	 sram12_data1 <= 0;
	 sram13_data0 <= 0;
	 sram13_data1 <= 0;
	 sram14_data0 <= 0;
	 sram14_data1 <= 0;
	 sram15_data0 <= 0;
	 sram15_data1 <= 0;
      end
      else begin
	 sram0_data0 <= sram0_dout0;
	 sram0_data1 <= sram0_dout1;
	 sram1_data0 <= sram1_dout0;
	 sram1_data1 <= sram1_dout1;
	 sram2_data0 <= sram2_dout0;
	 sram2_data1 <= sram2_dout1;
	 sram3_data0 <= sram3_dout0;
	 sram3_data1 <= sram3_dout1;
	 sram4_data0 <= sram4_dout0;
	 sram4_data1 <= sram4_dout1;
	 sram5_data0 <= sram5_dout0;
	 sram5_data1 <= sram5_dout1;
   rom0_data   <= rom0_dout;
	 sram6_data0 <= sram6_dout0;
	 sram6_data1 <= sram6_dout1;
	 sram7_data0 <= sram7_dout0;
	 sram7_data1 <= sram7_dout1;
	 sram8_data0 <= sram8_dout0;
	 sram8_data1 <= sram8_dout1;
	 sram9_data0 <= sram9_dout0;
	 sram9_data1 <= sram9_dout1;
	 sram10_data0 <= sram10_dout0;
	 sram10_data1 <= sram10_dout1;
	 sram11_data0 <= sram11_dout0;
	 sram11_data1 <= sram11_dout1;
	 sram12_data0 <= sram12_dout0;
	 sram12_data1 <= sram12_dout1;
	 sram13_data0 <= sram13_dout0;
	 sram13_data1 <= sram13_dout1;
	 sram14_data0 <= sram14_dout0;
	 sram14_data1 <= sram14_dout1;
	 sram15_data0 <= sram15_dout0;
	 sram15_data1 <= sram15_dout1;
      end
   end



endmodule	// user_project_wrapper

`default_nettype wire
