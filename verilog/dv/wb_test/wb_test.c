/*
 * SPDX-FileCopyrightText: 2020 Efabless Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * SPDX-License-Identifier: Apache-2.0
 */

// This include is relative to $CARAVEL_PATH (see Makefile)
//#include "verilog/dv/caravel/defs.h"
#include <defs.h>
//#include "verilog/dv/caravel/stub.c"
#include <stub.c>

// Caravel allows user project to use 0x30xx_xxxx address space on Wishbone bus
// OpenRAM
// 0x30c0_0000 till 30c0_03ff -> 256 Words of OpenRAM (1024 Bytes)
#define SRAM8_BASE_ADDRESS		0x30000000
#define SRAM8_SIZE_DWORDS		256ul			
#define SRAM8_SIZE_BYTES		(4ul * SRAM8_SIZE_DWORDS)
#define SRAM8_ADDRESS_MASK		(SRAM8_SIZE_BYTES - 1)
#define SRAM8_MEM(offset)		(*(volatile uint32_t*)(SRAM8_BASE_ADDRESS + offset))

#define SRAM9_BASE_ADDRESS		0x30010000
#define SRAM9_SIZE_DWORDS		512ul			
#define SRAM9_SIZE_BYTES		(4ul * SRAM9_SIZE_DWORDS)
#define SRAM9_ADDRESS_MASK		(SRAM9_SIZE_BYTES - 1)
//#define SRAM9_MEM(offset)		(*(volatile uint32_t*)(SRAM9_BASE_ADDRESS + (offset & SRAM9_ADDRESS_MASK)))
#define SRAM9_MEM(offset)		(*(volatile uint32_t*)(SRAM9_BASE_ADDRESS + offset ))

#define SRAM10_BASE_ADDRESS		0x30020000
#define SRAM10_SIZE_DWORDS		512ul			
#define SRAM10_SIZE_BYTES		(4ul * SRAM10_SIZE_DWORDS)
#define SRAM10_ADDRESS_MASK		(SRAM10_SIZE_BYTES - 1)
//#define SRAM10_MEM(offset)		(*(volatile uint32_t*)(SRAM10_BASE_ADDRESS + (offset & SRAM10_ADDRESS_MASK)))
#define SRAM10_MEM(offset)		(*(volatile uint32_t*)(SRAM10_BASE_ADDRESS + offset ))

#define SRAM0_BASE_ADDRESS		0x30030000
#define SRAM0_MEM(offset)		(*(volatile uint32_t*)(SRAM0_BASE_ADDRESS + offset ))

#define SRAM1_BASE_ADDRESS		0x30040000
#define SRAM1_MEM(offset)		(*(volatile uint32_t*)(SRAM1_BASE_ADDRESS + offset ))

#define SRAM2_BASE_ADDRESS		0x30050000
#define SRAM2_MEM(offset)		(*(volatile uint32_t*)(SRAM2_BASE_ADDRESS + offset ))

#define SRAM3_BASE_ADDRESS		0x30060000
#define SRAM3_MEM(offset)		(*(volatile uint32_t*)(SRAM3_BASE_ADDRESS + offset ))

#define SRAM4_BASE_ADDRESS		0x30070000
#define SRAM4_MEM(offset)		(*(volatile uint32_t*)(SRAM4_BASE_ADDRESS + offset ))

#define SRAM5_BASE_ADDRESS		0x30080000
#define SRAM5_MEM(offset)		(*(volatile uint32_t*)(SRAM5_BASE_ADDRESS + offset ))

#define SRAM6_BASE_ADDRESS		0x30090000
#define SRAM6_MEM(offset)		(*(volatile uint32_t*)(SRAM6_BASE_ADDRESS + offset ))



void main()
{

	/* 
	IO Control Registers
	| DM     | VTRIP | SLOW  | AN_POL | AN_SEL | AN_EN | MOD_SEL | INP_DIS | HOLDH | OEB_N | MGMT_EN |
	| 3-bits | 1-bit | 1-bit | 1-bit  | 1-bit  | 1-bit | 1-bit   | 1-bit   | 1-bit | 1-bit | 1-bit   |
	Output: 0000_0110_0000_1110  (0x1808) = GPIO_MODE_USER_STD_OUTPUT
	| DM     | VTRIP | SLOW  | AN_POL | AN_SEL | AN_EN | MOD_SEL | INP_DIS | HOLDH | OEB_N | MGMT_EN |
	| 110    | 0     | 0     | 0      | 0      | 0     | 0       | 1       | 0     | 0     | 0       |
	
	 
	Input: 0000_0001_0000_1111 (0x0402) = GPIO_MODE_USER_STD_INPUT_NOPULL
	| DM     | VTRIP | SLOW  | AN_POL | AN_SEL | AN_EN | MOD_SEL | INP_DIS | HOLDH | OEB_N | MGMT_EN |
	| 001    | 0     | 0     | 0      | 0      | 0     | 0       | 0       | 0     | 1     | 0       |
	*/

	/* Set up the housekeeping SPI to be connected internally so	*/
	/* that external pin changes don't affect it.			*/

	/* both of the following registers need to be enabled
	   enabling just one of them or none of them causes
	   the simulation to run infinitely and stopping after
	   the timeout number of cycles */


	reg_spi_enable = 1;
	reg_wb_enable = 1;


	reg_mprj_io_0 =  GPIO_MODE_USER_STD_INPUT_NOPULL;
	reg_mprj_io_1 =  GPIO_MODE_USER_STD_INPUT_NOPULL;
	reg_mprj_io_2 =  GPIO_MODE_USER_STD_INPUT_NOPULL;
	reg_mprj_io_3 =  GPIO_MODE_USER_STD_INPUT_NOPULL;


	// GPIO pin 9 Used to flag the start/end of a test 
	// GPIO pin 10 Used to indicate error in writing/reading sram 
	reg_mprj_io_9 = GPIO_MODE_MGMT_STD_OUTPUT;
	reg_mprj_io_10 = GPIO_MODE_MGMT_STD_OUTPUT;

	/* Apply configuration */
	reg_mprj_xfer = 1;
	while (reg_mprj_xfer == 1);

	// Flag start of the test
	reg_mprj_datal = 0x00000200;



	SRAM0_MEM(0) = 0x000000ef;		// 8 bit word
	SRAM1_MEM(0) = 0xcafebabe;
	SRAM2_MEM(0) = 0xfeedfeed;
	SRAM3_MEM(0) = 0xbeef5678;
	SRAM4_MEM(0) = 0xbeef9abc;
	SRAM5_MEM(0) = 0xdeeddeed;
	SRAM6_MEM(0) = 0xdeadcafe;
	SRAM8_MEM(0) = 0xdeadbeef;
	SRAM9_MEM(0) = 0xbeefdead;
	SRAM10_MEM(0) = 0xbeef1234;

	SRAM0_MEM(4) = 0x000000fe;		// 8 bit word
	SRAM1_MEM(4) = 0xbabecafe;
	SRAM2_MEM(4) = 0xdeefdeef;
	SRAM3_MEM(4) = 0xbee2dead;
	SRAM4_MEM(4) = 0xbee3dead;
	SRAM5_MEM(4) = 0xbeedbeed;
	SRAM6_MEM(4) = 0xcafedead;
	SRAM8_MEM(4) = 0xdeadbee0;
	SRAM9_MEM(4) = 0xbee0dead;
	SRAM10_MEM(4) = 0xbee1dead;

	SRAM0_MEM(8) = 0x000000ab;		// 8 bit word
	SRAM1_MEM(8) = 0xcafebaba;
	SRAM2_MEM(8) = 0xfeedfeeb;
	SRAM3_MEM(8) = 0xcdcdcdcd;
	SRAM4_MEM(8) = 0xefefefef;
	SRAM5_MEM(8) = 0xbedbedbe;
	SRAM6_MEM(8) = 0xdeadbaba;
	SRAM8_MEM(8) = 0xffffffff;
	SRAM9_MEM(8) = 0x12345678;
	SRAM10_MEM(8) = 0xabababab;

	SRAM0_MEM(2048) = 0x000000bb;		// 8 bit word
	SRAM1_MEM(12) = 0xcafeeeee;
	SRAM2_MEM(12) = 0xfeeddddd;
	SRAM3_MEM(12) = 0x30303030;
	SRAM4_MEM(12) = 0x40404040;
	SRAM5_MEM(12) = 0xdeeddddd;
	SRAM6_MEM(12) = 0xdeaddddd;
	SRAM8_MEM(12) = 0xdeaddead;
	SRAM9_MEM(12) = 0x10101010;
	SRAM10_MEM(12) = 0x20202020;

	if (SRAM0_MEM(0) != 0x000000ef) {
		// send an error signal to the testbench
		reg_mprj_datal = 0x00000600;
		reg_mprj_datal = 0x00000200;
	}
	if (SRAM0_MEM(4) != 0x000000fe) {
		// send an error signal to the testbench
		reg_mprj_datal = 0x00000600;
		reg_mprj_datal = 0x00000200;
	}
	if (SRAM0_MEM(8) != 0x000000ab) {
		// send an error signal to the testbench
		reg_mprj_datal = 0x00000600;
		reg_mprj_datal = 0x00000200;
	}
	if (SRAM0_MEM(2048) != 0x000000bb) {
		// send an error signal to the testbench
		reg_mprj_datal = 0x00000600;
		reg_mprj_datal = 0x00000200;
	}

	if (SRAM1_MEM(0) != 0xcafebabe) {
		// send an error signal to the testbench
		reg_mprj_datal = 0x00000600;
		reg_mprj_datal = 0x00000200;
	}
	if (SRAM1_MEM(4) != 0xbabecafe) {
		// send an error signal to the testbench
		reg_mprj_datal = 0x00000600;
		reg_mprj_datal = 0x00000200;
	}
	if (SRAM1_MEM(8) != 0xcafebaba) {
		// send an error signal to the testbench
		reg_mprj_datal = 0x00000600;
		reg_mprj_datal = 0x00000200;
	}
	if (SRAM1_MEM(12) != 0xcafeeeee) {
		// send an error signal to the testbench
		reg_mprj_datal = 0x00000600;
		reg_mprj_datal = 0x00000200;
	}

	if (SRAM2_MEM(0) != 0xfeedfeed) {
		// send an error signal to the testbench
		reg_mprj_datal = 0x00000600;
		reg_mprj_datal = 0x00000200;
	}
	if (SRAM2_MEM(4) != 0xdeefdeef) {
		// send an error signal to the testbench
		reg_mprj_datal = 0x00000600;
		reg_mprj_datal = 0x00000200;
	}
	if (SRAM2_MEM(8) != 0xfeedfeeb) {
		// send an error signal to the testbench
		reg_mprj_datal = 0x00000600;
		reg_mprj_datal = 0x00000200;
	}
	if (SRAM2_MEM(12) != 0xfeeddddd) {
		// send an error signal to the testbench
		reg_mprj_datal = 0x00000600;
		reg_mprj_datal = 0x00000200;
	}

	if (SRAM3_MEM(0) != 0xbeef5678) {
		// send an error signal to the testbench
		reg_mprj_datal = 0x00000600;
		reg_mprj_datal = 0x00000200;
	}
	if (SRAM3_MEM(4) != 0xbee2dead) {
		// send an error signal to the testbench
		reg_mprj_datal = 0x00000600;
		reg_mprj_datal = 0x00000200;
	}
	if (SRAM3_MEM(8) != 0xcdcdcdcd) {
		// send an error signal to the testbench
		reg_mprj_datal = 0x00000600;
		reg_mprj_datal = 0x00000200;
	}
	if (SRAM3_MEM(12) != 0x30303030) {
		// send an error signal to the testbench
		reg_mprj_datal = 0x00000600;
		reg_mprj_datal = 0x00000200;
	}

	if (SRAM4_MEM(0) != 0xbeef9abc) {
		// send an error signal to the testbench
		reg_mprj_datah = 0x00000600;
		reg_mprj_datal = 0x00000200;
	}
	if (SRAM4_MEM(4) != 0xbee3dead) {
		// send an error signal to the testbench
		reg_mprj_datah = 0x00000600;
		reg_mprj_datal = 0x00000200;
	}
	if (SRAM4_MEM(8) != 0xefefefef) {
		// send an error signal to the testbench
		reg_mprj_datah = 0x00000600;
		reg_mprj_datal = 0x00000200;
	}
	if (SRAM4_MEM(12) != 0x40404040) {
		// send an error signal to the testbench
		reg_mprj_datah = 0x00000600;
		reg_mprj_datal = 0x00000200;
	}

	if (SRAM5_MEM(0) != 0xdeeddeed) {
		// send an error signal to the testbench
		reg_mprj_datah = 0x00000600;
		reg_mprj_datal = 0x00000200;
	}
	if (SRAM5_MEM(4) != 0xbeedbeed) {
		// send an error signal to the testbench
		reg_mprj_datah = 0x00000600;
		reg_mprj_datal = 0x00000200;
	}
	if (SRAM5_MEM(8) != 0xbedbedbe) {
		// send an error signal to the testbench
		reg_mprj_datah = 0x00000600;
		reg_mprj_datal = 0x00000200;
	}
	if (SRAM5_MEM(12) != 0xdeeddddd) {
		// send an error signal to the testbench
		reg_mprj_datah = 0x00000600;
		reg_mprj_datal = 0x00000200;
	}

	if (SRAM6_MEM(0) != 0xdeadcafe) {
		// send an error signal to the testbench
		reg_mprj_datah = 0x00000600;
		reg_mprj_datal = 0x00000200;
	}
	if (SRAM6_MEM(4) != 0xcafedead) {
		// send an error signal to the testbench
		reg_mprj_datah = 0x00000600;
		reg_mprj_datal = 0x00000200;
	}
	if (SRAM6_MEM(8) != 0xdeadbaba) {
		// send an error signal to the testbench
		reg_mprj_datah = 0x00000600;
		reg_mprj_datal = 0x00000200;
	}
	if (SRAM6_MEM(12) != 0xdeaddddd) {
		// send an error signal to the testbench
		reg_mprj_datah = 0x00000600;
		reg_mprj_datal = 0x00000200;
	}

	if (SRAM8_MEM(0) != 0xdeadbeef) {
		// send an error signal to the testbench
		reg_mprj_datal = 0x00000600;
		reg_mprj_datal = 0x00000200;
	}
	if (SRAM8_MEM(4) != 0xdeadbee0) {
		// send an error signal to the testbench
		reg_mprj_datal = 0x00000600;
		reg_mprj_datal = 0x00000200;
	}
	if (SRAM8_MEM(8) != 0xffffffff) {
		// send an error signal to the testbench
		reg_mprj_datal = 0x00000600;
		reg_mprj_datal = 0x00000200;
	}
	if (SRAM8_MEM(12) != 0xdeaddead) {
		// send an error signal to the testbench
		reg_mprj_datal = 0x00000600;
		reg_mprj_datal = 0x00000200;
	}


	if (SRAM9_MEM(0) != 0xbeefdead) {
		// send an error signal to the testbench
		reg_mprj_datal = 0x00000600;
		reg_mprj_datal = 0x00000200;
	}
	if (SRAM9_MEM(4) != 0xbee0dead) {
		// send an error signal to the testbench
		reg_mprj_datal = 0x00000600;
		reg_mprj_datal = 0x00000200;
	}
	if (SRAM9_MEM(8) != 0x12345678) {
		// send an error signal to the testbench
		reg_mprj_datal = 0x00000600;
		reg_mprj_datal = 0x00000200;
	}
	if (SRAM9_MEM(12) != 0x10101010) {
		// send an error signal to the testbench
		reg_mprj_datal = 0x00000600;
		reg_mprj_datal = 0x00000200;
	}

	if (SRAM10_MEM(0) != 0xbeef1234) {
		// send an error signal to the testbench
		reg_mprj_datal = 0x00000600;
		reg_mprj_datal = 0x00000200;
	}
	if (SRAM10_MEM(4) != 0xbee1dead) {
		// send an error signal to the testbench
		reg_mprj_datal = 0x00000600;
		reg_mprj_datal = 0x00000200;
	}
	if (SRAM10_MEM(8) != 0xabababab) {
		// send an error signal to the testbench
		reg_mprj_datal = 0x00000600;
		reg_mprj_datal = 0x00000200;
	}
	if (SRAM10_MEM(12) != 0x20202020) {
		// send an error signal to the testbench
		reg_mprj_datal = 0x00000600;
		reg_mprj_datal = 0x00000200;
	}


	reg_mprj_datal = 0x00000000;			
}

