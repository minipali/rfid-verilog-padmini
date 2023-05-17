//final as of 15-05-2023


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
           input [3:0] debug_address,
           
           
           //directly to memory
           input factory_reset,
           input ADC_data_ready, 
           input [7:0] ADC_data, 
           input [15:0] mem_read_in,
           
           input wire [5:0]Counter_EPC_in,Counter_s1_in,Counter_s2_in,
           input wire current_inven_flag_in,current_sl_flag_in,
           input wire [15:0]Code1_in,
           
           //directly from memory
           output wire [15:0] mem_data_out, //data is given to the memory
           output wire PC_B,WE,SE,
           output wire [5:0] mem_address,  //this will enable WL
           output wire [2:0] mem_sel,
           
           
           //directly from top
           output wire modout, // regular IO
           output wire tx_enable,
           output wire debug_out,
           output wire osc_enable_pll,
           output wire pll_enable,
           output wire [3:0] freq_channel,
           output wire rforbase,
           output wire [2:0] senscode,
           output wire morb_trans,
           output wire [7:0] bf_dur,
           output wire backscatter_const,
           output wire bitout, calibration_control,
           output wire packet_complete,
           
           output wire current_inven_flag_out,current_sl_flag_out,
           output wire [15:0]Code1_out,
           output wire [5:0]Counter_EPC_out,Counter_s1_out,Counter_s2_out
               
           );
           
         
         
//from top op to mem ip
    wire [13:0] rx_cmd;
    wire [2:0] sel_target, sel_action;
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
    
//from mem op to mem_always_on ip
    
    
//from mem_always_on op to mem ip
    
 
   
    top topinst(reset, clk, demodin, modout, // regular IO
           EPC_data_in, EPC_data_ready,
           readwritebank, readwriteptr, readwords, membitclk, membitsrc, memdatadone, 
           use_q, comm_enable, tx_enable,
           debug_address, debug_out,
           rx_cmd,
           ///transmit clock
           osc_enable_pll, pll_enable, freq_channel, rforbase,
           ////from sample data
           senscode,
           /////
           morb_trans, sensor_time_stamp,
           bf_dur, backscatter_const,      
           bitout,
           calibration_control,
           //select
           sel_target, sel_action, mask,
           sl_flag, packet_complete
           );
//module top(reset, clk, demodin, modout, // regular IO
//           writedataout, epc_data_ready,
//           readwritebank, readwriteptr, readwords, membitclk, membitsrc, memdatadone, 
//           use_q, comm_enable, tx_enable,
//           debug_address, debug_out,
//           rx_cmd,
//           ///transmit clock
//           osc_enable_pll, pll_enable, freq_channel, rforbase,
//           ////from sample data
//           senscode,
//           /////
//           morb_trans, sensor_time_stamp,
//           bf_dur, backscatter_const,      
//           bitout,
//           calibration_control,
//           //select
//           sel_target, sel_action, sel_ptr, mask,
//           sl_flag, packet_complete);        
           
     mem m1(.clk(clk),.factory_reset(factory_reset),.reset(reset),.packetcomplete(packet_complete),
                .rx_cmd(rx_cmd),
                .sel_target(sel_target),
                .sel_action(sel_action),
                .mask(mask),  
                .readwritebank(readwritebank),
                .readwriteptr(readwriteptr), 
                .readwords(readwords),
                .EPC_data_in(EPC_data_in),
                .ADC_data_ready(ADC_data_ready),
                .EPC_data_ready(EPC_data_ready),     
                .ADC_data(ADC_data),
                .sensor_code(senscode), // 3-bit flag to indicate the 3 sensors
                .mem_read_in(mem_read_in),  //data from memory
                .sensor_time_stamp(sensor_time_stamp),   
                .data_clk(membitclk),
                .tx_enable(tx_enable),
                
                .inven_flag_in(current_inven_flag_in),.sl_flag_in(current_sl_flag_in),                       
                .Counter_EPC_in(Counter_EPC_in),.Counter_s1_in(Counter_s1_in),.Counter_s2_in(Counter_s2_in),
                .Code1_in(Code1_in),                                 
                
                
            //outputs
                .mem_data_out(mem_data_out), //data is given to the memory
                .PC_B(PC_B),.WE(WE),.SE(SE),
                .mem_address(mem_address),   //this will enable WL
                .mem_sel(mem_sel),
                .tx_bit_src(membitsrc),
                .mem_done(mem_done),
                .sl_flag(sl_flag),
                .inven_flag(inven_flag),
                .session(session),
                .tx_data_done(memdatadone),
                
                .inven_flag_out(current_inven_flag_out),.sl_flag_out(current_sl_flag_out),                       
                .Counter_EPC_out(Counter_EPC_out),.Counter_s1_out(Counter_s1_out),.Counter_s2_out(Counter_s2_out),
                .Code1_out(Code1_out)                                 
                
               );       
//module mem(
//    input wire clk,factory_reset,reset,packetcomplete,
//    input wire [12:0] rx_cmd,
//    input wire [2:0] sel_target,
//    input wire [2:0] sel_action
//    input wire [15:0] mask,  
//    input wire [1:0] readwritebank,
//    input wire [7:0] readwriteptr, 
//    input wire [7:0] readwords,
//    input wire [15:0]EPC_data_in,
//    input wire ADC_data_ready, 
//    input wire EPC_data_ready,    
//    input wire [7:0] ADC_data,
//    input wire [2:0]sensor_code, // 3-bit flag to indicate the 3 sensors
//    input wire [15:0]mem_read_in,  //data from memory
//    input wire [7:0]sensor_time_stamp,   
//    input wire data_clk,
//    input wire tx_enable,

//    output reg [15:0] mem_data_out, //data is given to the memory
//    output reg PC_B,WE,SE,
//    output reg [5:0]mem_address,   //this will enable WL
//    output reg [2:0]mem_sel,
//    output reg tx_bit_src,
//    output reg mem_done,
//    output reg sl_flag,inven_flag,
//    output reg [1:0]session,
//    output reg tx_data_done
//);
// mem_always_on m2(.rx_cmd(rx_cmd),.packet_complete(packet_complete),.tx_enable(tx_enable),.ADC_data_ready(ADC_data_ready),
//                    .clk(clk),.factory_reset(factory_reset),.current_sl_flag_in(current_sl_flag_in),
//                    .Code1_in(Code1_in),                       
//                    .Counter_EPC_in(Counter_EPC_in),.Counter_s1_in(Counter_s1_in),.Counter_s2_in(Counter_s2_in),
//                    .Counter_EPC_out(Counter_EPC_out),.Counter_s1_out(Counter_s1_out),.Counter_s2_out(Counter_s2_out),
//                    .current_sl_flag_out(current_sl_flag_out),                               
//                    .Code1_out(Code1_out)
//    );
//module mem_always_on(
//input wire [13:0]rx_cmd,
//input wire packet_complete,tx_enable,ADC_data_ready,
//input wire clk,factory_reset,
//input wire current_inven_flag_in,current_sl_flag_in,
//input wire [15:0]Code1_in,
//input wire [5:0]Counter_EPC_in,Counter_s1_in,Counter_s2_in,
//output reg [5:0]Counter_EPC_out,Counter_s1_out,Counter_s2_out,
//output reg current_inven_flag_out,current_sl_flag_out,
//output reg [15:0]Code1_out
//);
    
    
    
    
    
    
    
endmodule
