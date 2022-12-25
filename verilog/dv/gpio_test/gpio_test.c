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
#include <defs.h>
#include <stub.c>

/*
	GPIO Test:
		- Reads to and writes from each SRAM
		- Uses Logic Analyzer interface for communication between SRAMs and CPU
*/

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

	reg_spi_enable = 1;

	reg_mprj_io_0 =  GPIO_MODE_MGMT_STD_OUTPUT;
	reg_mprj_io_1 =  GPIO_MODE_MGMT_STD_INPUT_NOPULL;

	reg_mprj_io_5  =  GPIO_MODE_USER_STD_INPUT_NOPULL;
	reg_mprj_io_6  =  GPIO_MODE_USER_STD_INPUT_NOPULL;
	reg_mprj_io_7  =  GPIO_MODE_USER_STD_INPUT_NOPULL;
	reg_mprj_io_8  =  GPIO_MODE_USER_STD_INPUT_NOPULL;
	reg_mprj_io_9  =  GPIO_MODE_USER_STD_INPUT_NOPULL;
	reg_mprj_io_10 =  GPIO_MODE_USER_STD_INPUT_NOPULL;
	reg_mprj_io_11 =  GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_36 =  GPIO_MODE_USER_STD_INPUT_NOPULL;
	reg_mprj_io_37 =  GPIO_MODE_USER_STD_INPUT_NOPULL;


	/* Apply configuration */
	reg_mprj_xfer = 1;
	while (reg_mprj_xfer == 1);
	// Set pin 0 to start 
	reg_mprj_datal = 0x00000001;
	while(1) {
		if (reg_mprj_io_1 == 1)
			break;
	}
}
