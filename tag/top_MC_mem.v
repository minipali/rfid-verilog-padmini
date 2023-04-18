//final as of 18-04-2023


`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////


module top_MC_mem(
            //top and memory
           input reset, clk, 
           
           //directly top
           input demodin, 
           input use_q,
           input comm_enable,
           input debug_clk,
           
           
           //directly to memory
           input factory_reset,
           input ADC_data_ready, 
           input [7:0] ADC_data, 
           input [15:0] mem_read_in,
           
           //directly from memory
           output wire [15:0] mem_data_out, //data is given to the memory
           output wire PC_B,WE,SE,
           output wire [5:0] mem_address,  //this will enable WL
           output wire [2:0] mem_sel,
           
           
           //directly from top
           output wire modout, // regular IO
           output wire tx_enable,
           output wire debug_out,
           output wire pll_enable,
           output wire [3:0] freq_channel,
           output wire rforbase,
           output wire [2:0] senscode,
           output wire morb_trans,
           output wire [7:0] bf_dur,
           output wire bitout, calibration_control,
           output wire packet_complete);
         
         
//from top op to mem ip
    wire [12:0] rx_cmd;
    wire [2:0] sel_target, sel_action;
    wire [7:0] sel_ptr;
    wire [15:0] mask;   
    wire [1:0] readwritebank;
    wire [7:0] readwriteptr;
    wire [7:0] readwords;
    wire [15:0] EPC_data_in;
    wire EPC_data_ready;
    wire [7:0]sensor_time_stamp;    
    wire membitclk;
    
// from mem op to top ip
    wire memdatadone; 
    wire  membitsrc;
    wire sl_flag;//from memory to top
    
    //redundant
    wire mem_done;
    wire inven_flag;
    wire [1:0] session;
    
   
    top topinst(reset, clk, demodin, modout, // regular IO
           EPC_data_in, EPC_data_ready,
           readwritebank, readwriteptr, readwords, membitclk, membitsrc, memdatadone, 
           use_q, comm_enable, tx_enable,
           debug_clk, debug_out,
           rx_cmd,
           ///transmit clock
           pll_enable, freq_channel, rforbase,
           ////from sample data
           senscode,
           /////
           morb_trans, sensor_time_stamp, bf_dur,      
           bitout,
           calibration_control,
           //select
           sel_target, sel_action, sel_ptr, mask,
           sl_flag, packet_complete);
//         module top(reset, clk, demodin, modout, // regular IO
//           writedataout, epc_data_ready,
//           readwritebank, readwriteptr, readwords, membitclk, membitsrc, memdatadone, 
//           use_q, comm_enable, tx_enable,
//           debug_clk, debug_out,
//           rx_cmd,
//           ///transmit clock
//           pll_enable, freq_channel, rforbase,
//           ////from sample data
//           senscode,
//           /////
//           morb_trans, sensor_time_stamp, bf_dur,      
//           bitout,
//           calibration_control,
//           //select
//           sel_target, sel_action, sel_ptr, mask,
//           sl_flag, packet_complete);           
           
     mem m1(clk,factory_reset,reset,packet_complete,
                rx_cmd,
                sel_target,
                sel_action,
                sel_ptr,
                mask,  
                readwritebank,
                readwriteptr, 
                readwords,
                EPC_data_in,
                ADC_data_ready,
                EPC_data_ready,     
                ADC_data,
                senscode, // 3-bit flag to indicate the 3 sensors
                mem_read_in,  //data from memory
                sensor_time_stamp,   
                membitclk,
                tx_enable,
            //outputs
                mem_data_out, //data is given to the memory
                PC_B,WE,SE,
                mem_address,   //this will enable WL
                mem_sel,
                membitsrc,
                mem_done,
                sl_flag,
                inven_flag,
                session,
                memdatadone
                );       
//module mem(
//    input wire clk,factory_reset,reset,packetcomplete,
//    input wire [12:0] rx_cmd,
//    input wire [2:0] sel_target,
//    input wire [2:0] sel_action,
//    input wire [7:0] sel_ptr,
//    input wire [7:0] sel_masklen,
//    input wire [15:0] mask,  
//    input wire [1:0] readwritebank,
//    input wire [7:0] readwriteptr, 
//    input wire [7:0] readwords,
//    input wire [15:0]EPC_data_in,
//    input wire ADC_data_ready,
//    input wire EPC_data_ready,     
//    input wire [7:0]ADC_data,
//    input wire [2:0]sensor_code, // 3-bit flag to indicate the 3 sensors
//    input wire [15:0]mem_read_in,  //data from memory
//    input wire [7:0]sensor_time_stamp,   
//    input wire data_clk,

//    output reg [15:0] mem_data_out, //data is given to the memory
//    output reg PC_B,WE,SE,
//    output reg [5:0]mem_address,   //this will enable WL
//    output reg [2:0]mem_sel,
//    output reg tx_bit_src,
//    output reg mem_done,
//    output reg sl_flag,inven_flag,
//    output reg [1:0]session,RorW,
//    output reg tx_data_done
//);
    
    
    
    
    
    
    
endmodule
