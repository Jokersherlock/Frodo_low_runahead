`timescale 1ns / 1ns
`ifndef _GLOBAL_DEFINE_V_
`define _GLOBAL_DEFINE_V_

// Frodo参数定义
`define FRODO_1344 2'b11
`define FRODO_976  2'b10
`define FRODO_640  2'b01
`define KEYGEN 2'b01
`define ENCAP 2'b10
`define DECAP 2'b11

`define UINST_ADDR_WIDTH 8
`define UINST_WIDTH 25

`define INST_WIDTH 28


`define ABSORB    4'b1000
`define SQUEEZE   4'b1001
`define HASH_EX   4'b1010
`define SQUEEZE_L 4'b1100
`define ABSORB_B  4'b1101

// 仿真/综合模式切换宏定义
// 注释掉下面这行使用仿真模式（dual_ram, rom模块）
// 取消注释使用综合模式（IP核）
// `define USE_IP_CORE


`endif