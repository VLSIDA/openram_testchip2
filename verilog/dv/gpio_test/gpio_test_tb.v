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

module gpio_test_tb;
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

	always #12.5 clock <= (clock === 1'b0);
	always #12.5 gpio_clk <= (gpio_clk === 1'b0);

	initial begin
	   clock = 0;
	   gpio_clk = 0;
	end

	reg gpio_clk;
	reg gpio_scan;
	reg gpio_sram_load;
	reg global_csb;
	reg gpio_in;
	reg done;

    wire gpio_out = mprj_io[`GPIO_OUT];
    wire start = mprj_io[`START];
	assign mprj_io[`DONE] = done;
	assign mprj_io[`MODE_SELECT1] = 1'b0; // gpio/la test mode
	assign mprj_io[`MODE_SELECT0] = 1'b1; // gpio_clk select
	assign mprj_io[`GPIO_RESETN] = 1'b1; // reset
	assign mprj_io[`GPIO_CLK] = gpio_clk;
	assign mprj_io[`GPIO_IN] = gpio_in;
	assign mprj_io[`GPIO_SCAN] = gpio_scan;
	assign mprj_io[`GPIO_SRAM_LOAD] = gpio_sram_load;
	assign mprj_io[`GPIO_GLOBAL_CSB] = global_csb;

	reg [111:0] in_data;

   	 integer i,j;


   task write_sram;
      input [3:0] sel;
      input 	  csb0;
      input 	  web0;
      input [15:0] addr0;
      input [31:0] din0;
      input 	   csb1;
      input 	   web1;
      input [15:0] addr1;
      input [31:0] din1;
      begin


	 global_csb = 1;
	 gpio_scan = 1;
	 gpio_sram_load = 0;
	 in_data = {sel, addr0, din0, csb0, web0, 4'hF, addr1, din1, csb1, web1, 4'hF};

	 for(j = 0; j < 112; j = j + 1) begin
	    gpio_in = in_data[111 - j];
	    #25;
	 end

	 gpio_scan = 0;
	 global_csb = 0;
	 #25;
	 global_csb = 1;

      end
   endtask // write_sram


   task read_sram;
      input [3:0] sel;
      input 	  csb0;
      input 	  web0;
      input [15:0] addr0;
      input [31:0] din0;
      input 	   csb1;
      input 	   web1;
      input [15:0] addr1;
      input [31:0] din1;
      begin


	 global_csb = 1;
	 gpio_scan = 1;
	 gpio_sram_load = 0;
	 in_data = {sel, addr0, 32'hFFFF, csb0, web0, 4'hF, addr1, 32'hFFFF, csb1, web1, 4'hF};

	 for(j = 0; j < 112; j = j + 1) begin
	    gpio_in = in_data[111 - j];
	    #25;
	 end

	 gpio_scan = 0;
         global_csb = 0;
	 // Do the SRAM Read
         #25;
	 // Store result in dout FF
         global_csb = 1;
         #25;
	 // Load dout FF into scan register
         gpio_sram_load = 1;
         #25;
	 // Start scanning
         gpio_sram_load = 0;

         gpio_scan = 1;

	 // This should scan out the results and check they match the same thing expected here:
	 in_data = {sel, addr0, din0, csb0, web0, 4'hF, addr1, din1, csb1, web1, 4'hF};
	 for(j = 0; j < 112; j = j + 1) begin
	    // Important to use !== so x is not don't care
	    if (in_data[111 - j] !== gpio_out) begin
	       $display($time, " Data read mismatch %b != %b", gpio_out, in_data[111 - j]);
	    end

	    #25;
	 end
      end
   endtask // read_sram

   initial begin
      #8000000
      $display("Timeout");
      $finish;
   end

	initial begin

        wait(start == 1'b1);
        $display($time, " Saw bit 1: VCD starting");
		$dumpfile("gpio_test.vcd");
		$dumpvars(0, gpio_test_tb);
    

		done = 0;
		global_csb = 1;

	   #50;

		//Testing all memories
		for(i = 0; i < 11; i = i + 1) begin
      // sram 0-5 and 9 are dual port memories
      // sram 6,7 does not exist
      // sram 8 and 10 are single port memories
      if (i < 6 || i == 9) begin
		    //Testing 32B Dual Port Memories
		     // write 1 to address 1
		     write_sram(
			  	  i,
			        1'b0,
			        1'b0,
			        16'd1,
			        i,
			        1'b1,
			        1'b1,
			        16'd0,
			        32'd0);

		     // write i*2^3 to address 2
		     write_sram(
			  	  i,
			        1'b0,
			        1'b0,
			        16'd2,
			        i<<3,
			        1'b1,
			        1'b1,
			        16'd0,
			        32'd0);

		     // read address 1 and 2
		     read_sram(
			  	 i,
			       1'b0,
			       1'b1,
			       16'd1,
			       i,
			       1'b0,
			       1'b1,
			       16'd2,
			       i<<3);

           end else if (i > 7 && i != 9) begin
        // for sram 8 and 10 
		    //Testing 32B Single Port Memories
		   // write 1 to address 1
		   write_sram(i,
			      1'b0,
			      1'b0,
			      16'd1,
			      32'hDEADBEEF,
			      1'b1,
			      1'b1,
			      16'd0,
			      32'd0);

		   // read address 1 and 2
		   read_sram(i,
			     1'b0,
			     1'b1,
			     16'd1,
			     32'hDEADBEEF,
			     1'b1,
			     1'b1,
			     16'd0,
			     32'd0);
          end

		end


      // for ROM
    read_sram(11,   // sel
      1'b0,   // csb0
      1'b1,   // web0
      16'd1,  // addr0
      32'd255,  // din0
      1'b1,   // csb1
      1'b1,   // web1
      16'd0,  // addr1
      32'd0   // din1
      );
		done = 1;
		
	   $display("Done with tests");

		#25; $finish;
	end

	initial begin
		RSTB <= 1'b0;
		CSB  <= 1'b1;		// Force CSB high
		#2000;
		RSTB <= 1'b1;	    	// Release reset
		#300000;
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
		.FILENAME("gpio_test.hex")
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
