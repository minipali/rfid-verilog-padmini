`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2023 05:54:31 PM
// Design Name: 
// Module Name: mem_always_on
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mem_always_on(
input wire [13:0]rx_cmd,
input wire packet_complete,tx_enable,ADC_data_ready,
input wire clk,factory_reset,current_inven_flag_in,current_sl_flag_in,
input wire [15:0]Code1_in,
input wire [5:0]Counter_EPC_in,Counter_s1_in,Counter_s2_in,
output reg [5:0]Counter_EPC_out,Counter_s1_out,Counter_s2_out,
output reg current_inven_flag_out,current_sl_flag_out,
output reg [15:0]Code1_out
);
//Used flags so that the output and input is updated inn one clock cycle
reg in_flag,out_flag;
reg current_inven_flag,current_sl_flag;
reg [15:0] Code1;
reg [5:0]Counter_EPC,Counter_s1,Counter_s2;

always@(posedge clk)begin
if(factory_reset)begin
    Counter_EPC = 6'd0;
    Counter_s1 = 6'd0;
    Counter_s2 = 6'd0;
    current_inven_flag = 1'd1;
    current_sl_flag = 1'd1;
    Code1 = 16'd0;
    out_flag = 1'd0;
    in_flag = 1'd0;
    Counter_EPC_out = 6'd0;
    Counter_s1_out = 6'd0;
    Counter_s2_out = 6'd0;
    current_inven_flag_out = 1'd1;
    current_sl_flag_out = 1'd1;
    Code1_out = 16'd0;
end else begin
//for select command - here Code1 is the word that we will match with the mask
    if(Counter_EPC == 6'd3)begin
        Code1 = Code1_in;
    end
//This is also for select command - here we store inven and sl flags 
    if(rx_cmd[4])begin
        if(!packet_complete)begin
            current_sl_flag_out = current_sl_flag;
            current_inven_flag_out = current_inven_flag;
            Code1_out = Code1;   
        end else begin
            current_sl_flag = current_sl_flag_in;
            current_inven_flag = current_inven_flag_in;
        end
    end   
//This is for read command - On reading Counter_s1,Counter_s2 will be updated(decrements)
    if(rx_cmd[11])begin
        Counter_s1_out = Counter_s1;
        Counter_s2_out = Counter_s2; 
        in_flag = 1'd1;   
    end 
    if(!tx_enable&&(in_flag == 1'd1))begin
        in_flag = 1'd0;
        Counter_s1 = Counter_s1_in;
        Counter_s2 = Counter_s2_in;
    end     
// this is for ACK command.
     if(rx_cmd[1])begin
        Counter_EPC_out = Counter_EPC;   
    end     
    
//This is for sensor write    
    if(rx_cmd[10] && (packet_complete))begin
        if(!ADC_data_ready)begin
        Counter_s1_out = Counter_s1;
        Counter_s2_out = Counter_s2;
        end else begin
        Counter_s1 = Counter_s1_in;
        Counter_s2 = Counter_s2_in;
        end
    end  
//This is for EPC_write    
    if(rx_cmd[8]&& (!packet_complete)&&(out_flag == 1'd0))begin
        Counter_EPC_out = Counter_EPC;
        out_flag = 1'd1;
        in_flag = 1'd1;
    end 
    if(rx_cmd[8] &&(in_flag == 1'd1))begin
        Counter_EPC = Counter_EPC_in;
        in_flag = 1'd0;
        out_flag = 1'd0;      
    end

end
end
endmodule
