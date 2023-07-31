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

`timescale 1 ns / 1 ps

module la_test_tb;
	reg clock;
	reg RSTB;
	reg CSB;
	reg power1, power2;
	reg power3, power4;

	wire gpio;
	wire [37:0] mprj_io;

	// External clock is used by default.  Make this artificially fast for the
	// simulation.  Normally this would be a slow clock and the digital PLL
	// would be the fast clock.

	// setting this pin makes the CSB in a known state causing no Xs in GL simulation
	//assign	mprj_io[3] = 1'b1;

	always #12.5 clock <= (clock === 1'b0);

	initial begin
		clock = 0;
	end
	wire gpio_clk = 1'b1;
	wire gpio_scan = 1'b0;
	wire gpio_sram_load = 1'b0;
	wire global_csb = 1'b1;
	wire gpio_in = 1'b0;
    wire gpio_out = mprj_io[`GPIO_OUT];
	wire start = mprj_io[`START];
    wire done = mprj_io[`DONE];

	assign mprj_io[`MODE_SELECT1] = 1'b0; // gpio/la test mode
	assign mprj_io[`MODE_SELECT0] = 1'b0; // la_clk select
	assign mprj_io[`GPIO_RESETN] = 1'b0; // reset
	assign mprj_io[`GPIO_CLK] = gpio_clk;
	assign mprj_io[`GPIO_IN] = gpio_in;
	assign mprj_io[`GPIO_SCAN] = gpio_scan;
	assign mprj_io[`GPIO_SRAM_LOAD] = gpio_sram_load;
	assign mprj_io[`GPIO_GLOBAL_CSB] = global_csb;

	initial begin

		wait(start == 1'b1);
		$display($time, " Saw bit 1: VCD starting");

		$dumpfile("la_test.vcd");
		$dumpvars(0, la_test_tb);

		wait(start == 1'b0);
		$display($time, " Saw bit 0: VCD stopping");
		$display("Done with tests");
		$finish;

	end // initial begin
	
	initial begin
		wait (done == 1'b1);
		$display($time, " Data mismatch while reading byte from SRAM !"); 
	end
	

   initial begin
      #10000000
      $display("Timeout");
      $finish;
   end





	initial begin
		RSTB <= 1'b0;
		CSB  <= 1'b1;		// Force CSB high
		#2000;
		RSTB <= 1'b1;	    	// Release reset
		#170000;
		CSB = 1'b0;		// CSB can be released
	end

	initial begin		// Power-up sequence
		power1 <= 1'b0;
		power2 <= 1'b0;
		power3 <= 1'b0;
		power4 <= 1'b0;
		#100;
		power1 <= 1'b1;
		#100;
		power2 <= 1'b1;
		#100;
		power3 <= 1'b1;
		#100;
		power4 <= 1'b1;
	end

	wire flash_csb;
	wire flash_clk;
	wire flash_io0;
	wire flash_io1;

	wire VDD3V3 = power1;
	wire VDD1V8 = power2;
	wire USER_VDD3V3 = power3;
	wire USER_VDD1V8 = power4;
	wire VSS = 1'b0;

	assign mprj_io[3] = (CSB == 1'b1) ? 1'b1 : 1'bz;

	caravel uut (
		.vddio	  (VDD3V3),
		.vssio	  (VSS),
		.vdda	  (VDD3V3),
		.vssa	  (VSS),
		.vccd	  (VDD1V8),
		.vssd	  (VSS),
		.vdda1    (USER_VDD3V3),
		.vdda2    (USER_VDD3V3),
		.vssa1	  (VSS),
		.vssa2	  (VSS),
		.vccd1	  (USER_VDD1V8),
		.vccd2	  (USER_VDD1V8),
		.vssd1	  (VSS),
		.vssd2	  (VSS),
		.clock	  (clock),
		.gpio     (gpio),
        	.mprj_io  (mprj_io),
		.flash_csb(flash_csb),
		.flash_clk(flash_clk),
		.flash_io0(flash_io0),
		.flash_io1(flash_io1),
		.resetb	  (RSTB)
	);

	spiflash #(
		.FILENAME("la_test.hex")
	) spiflash (
		.csb(flash_csb),
		.clk(flash_clk),
		.io0(flash_io0),
		.io1(flash_io1),
		.io2(),			// not used
		.io3()			// not used
	);

endmodule
`default_nettype wire
