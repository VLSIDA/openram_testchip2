`define WMASK_SIZE 4
`define ADDR_SIZE 16
`define DATA_SIZE 32
`define SELECT_SIZE 4
`define MAX_CHIPS 16
`define PORT_SIZE `ADDR_SIZE+`DATA_SIZE+`WMASK_SIZE+2
`define TOTAL_SIZE `PORT_SIZE+`PORT_SIZE+`SELECT_SIZE

`define MODE_SELECT0 36
`define MODE_SELECT1 37
`define GPIO_RESETN 5
`define GPIO_CLK 6
`define GPIO_SCAN 7
`define GPIO_SRAM_LOAD 8
`define GPIO_GLOBAL_CSB 9
`define GPIO_IN 10
`define GPIO_OUT 11
`define START 0
`define DONE  1
`define PVDD_HEADER0 12
`define PGND_HEADER0 13
`define PVDD_HEADER1 14
`define PGND_HEADER1 15

`define P1T1R_TE 9
`define P1T1R_WL 10
`define P036_SL 11
`define P100_SL 12
`define P300_SL 13
`define P700_SL 14
`define P1R_TE 15
`define P1R_SL 16
`define BL0 17
`define BL1 18
`define BR0 19
`define BR1 20
`define RE_BL0 21
`define RE_BL1 22
`define RE_BR0 23
`define RE_BR1 24
`define WL0 25
`define WL1 26
`define RE_WL0 27
`define RE_WL1 28


// packet order:

// 4 chip_select

// 16 addr0
// 32 din0
// 1 csb0
// 1 web0
// 4 wmask0

// 16 addr1
// 32 din1
// 1 csb1
// 1 web1
// 4 wmask1
