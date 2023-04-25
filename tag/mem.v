//final as of 25-04-2023


`timescale 1ns / 1ns

module mem(
    input wire clk,factory_reset,reset,packetcomplete,
    input wire [13:0] rx_cmd,
    input wire [2:0] sel_target,
    input wire [2:0] sel_action,
    input wire [7:0] sel_ptr,
    input wire [15:0] mask,  
    input wire [1:0] readwritebank,
    input wire [7:0] readwriteptr, 
    input wire [7:0] readwords,
    input wire [15:0]EPC_data_in,
    input wire ADC_data_ready, 
    input wire EPC_data_ready,    
    input wire [7:0] ADC_data,
    input wire [2:0]sensor_code, // 3-bit flag to indicate the 3 sensors
    input wire [15:0]mem_read_in,  //data from memory
    input wire [7:0]sensor_time_stamp,   
    input wire data_clk,
    input wire tx_enable,

    output reg [15:0] mem_data_out, //data is given to the memory
    output reg PC_B,WE,SE,
    output reg [5:0]mem_address,   //this will enable WL
    output reg [2:0]mem_sel,
    output reg tx_bit_src,
    output reg mem_done,
    output reg sl_flag,inven_flag,
    output reg [1:0]session,
    output reg tx_data_done
);

reg [5:0]counter_s1,counter_s2;
reg [5:0] counter_EPC_read;
reg words_done_final;
reg [5:0] counter_EPC ;
reg [15:0] StoredCRC, StoredPC, Code1;
reg curr_sl_flag,curr_inven_flag,adc_flag;
reg [3:0]current_cmd;
reg [3:0]write_state;
reg [3:0]read_state;
reg [5:0]temp_low;
reg [5:0]temp;
reg next_word;
reg [15:0]adc_temp_data;
reg [15:0] tx_out;
reg tx_start;
reg words_done;
reg [3:0] bit_counter;  
reg [15:0] bit_shift_reg;


//flags for command being executed once
reg myflag_ack; //ack epc whole bank read
reg myflag_read; //epc read
reg myflag; // epc write
reg myflag_s; //sensor read

reg [6:0]read_done_counter;
wire myclk;
assign myclk = !data_clk & clk;

// commands, stored as states
parameter CMD_RESET = 4'd0;
parameter CMD_ACK = 4'd1;
parameter CMD_EPC_READ = 4'd2;
parameter CMD_SENSOR_READ = 4'd4;
parameter CMD_EPC_WRITE = 4'd8;

reg [5:0] Read_or_Write;
parameter RorW_INITIAL = 6'd0;
parameter EPC_READ = 6'd1;
parameter SENSOR1_READ = 6'd2;
parameter SENSOR2_READ = 6'd4;
parameter EPC_WRITE = 6'd8;
parameter SENSOR1_WRITE = 6'd16;
parameter SENSOR2_WRITE = 6'd32;

//ADC
parameter ADC_DATA_READY_FLAG = 1'd1;

// read and write states
parameter STATE_INITIAL = 4'd1;
parameter STATE_RESET = 4'd2;
parameter STATE_1 = 4'd4;
parameter STATE_2 = 4'd8;

always@(posedge data_clk)begin 
        
        if((data_clk) && myflag_read == 1'b0)begin
            myflag_read = 1'b1;
            tx_start = 1'b1;   
        end else begin
            tx_start = 1'b0;
        end
        
        if(tx_start)begin
            next_word = 1'd1;
        end else if(bit_counter == 4'd15 && next_word == 1'd0 && words_done == 1'd0)begin
            next_word = 1'd1;
        end else begin
            next_word = 1'd0;
        end
             
//        if(bit_counter == 4'd0 && tx_data_done == 1'b0)begin
//            bit_shift_reg = tx_out;
//        end else begin
//            bit_shift_reg = bit_shift_reg;
//        end
        
        if(tx_data_done == 1'd0)begin
            tx_bit_src = bit_shift_reg[15-bit_counter];
        end else begin
            tx_bit_src = 1'b0;
        end
        
        if((words_done ==1'd1) & (bit_counter == 4'd15))begin
            tx_data_done = 1'd1;
            read_done_counter = 4'd0;
            next_word = 1'd0;
        end else begin
            tx_data_done = 1'd0;
            if(next_word == 1'b1)begin
                bit_counter = 4'd0;
            end else begin
                bit_counter = bit_counter +4'd1;
            end
        end 
      
end

always@(posedge myclk)begin
    if(factory_reset)begin
        counter_EPC = 6'd0;
        counter_s1 = 6'd0;
        counter_s2 = 6'd0;
        curr_inven_flag =1'd1;
        curr_sl_flag =1'd1;
        sl_flag = 1'd1; 
     end else if(reset)begin
        bit_counter = 4'd0;
        words_done = 1'd0;   
        mem_data_out = 16'd0;
        sl_flag = 1'd1;            
        inven_flag = 1'd1;         
        session = 2'd0;
        PC_B = 1'd1;
        SE = 1'd0;
        WE = 1'd0;
        mem_done =1'd0;
        read_state = STATE_INITIAL;
        write_state = STATE_INITIAL;
        Read_or_Write = RorW_INITIAL;
        mem_sel = 3'd0;
        mem_address = 6'd0;
        tx_data_done = 1'b0; 
        Code1 = 16'd0;
        tx_bit_src = 1'b0;
        myflag_read = 1'b0;
        bit_shift_reg = 16'd0;
    end else begin
    
//tx_data done needs to be on for at least ~100 input 2MHZ clock cycles
        if(tx_data_done == 1'b1)begin
        read_done_counter = read_done_counter + 2'd1;
        end
         
        if(tx_data_done == 1'd1 && read_done_counter == 7'd100)begin
            tx_data_done = 1'd0;
            bit_counter = 4'd0;
        end else begin
            bit_counter  = bit_counter;
        end


//tx_enable on during transmit, so it being off acts as a reset        
        if(!tx_enable)begin
            myflag_read = 1'b0;
            words_done = 1'b0;
        end 

//the fixed word that select mask compares to is at ptr = 3 (4th word) --> stored in Code1        
        if(counter_EPC == 6'd3)begin    //need to fix the ptr
           Code1 = EPC_data_in;
        end else begin
           Code1 = Code1; 
        end
        
//if command is select. packet complete only for 1 clock cycle, within that time operation will be done      
        if(packetcomplete)begin
            if(rx_cmd[4])begin
                if(readwritebank == 2'b01)begin // if membank is 01
                    case(sel_target)
                      3'b000: session = 2'b00;
                      3'b001: session = 2'b01;
                      3'b010: session = 2'b10;
                      3'b011: session = 2'b11;
                    endcase
                
                    if(mask == Code1)begin // if tag is matching
                        case(sel_action)
                          3'b000:if(sel_target < 3'b100)begin inven_flag = 1'b1; end else if(sel_target == 3'b100)begin sl_flag = 1'b1; end
                          3'b001:if(sel_target < 3'b100)begin inven_flag = 1'b1; end else if(sel_target == 3'b100)begin sl_flag = 1'b1; end
                          3'b011:if(sel_target < 3'b100)begin inven_flag = !curr_inven_flag; end else if(sel_target == 3'b100)begin sl_flag = !curr_sl_flag; end
                          3'b100:if(sel_target < 3'b100)begin inven_flag = 1'b0; end else if(sel_target == 3'b100)begin sl_flag = 1'b0; end
                          3'b101:if(sel_target < 3'b100)begin inven_flag = 1'b0; end else if(sel_target == 3'b100)begin sl_flag = 1'b0; end
                        endcase
                    end else begin //not matching
                        case(sel_action)
                          3'b000:if(sel_target < 3'b100)begin inven_flag = 1'b0; end else if(sel_target == 3'b100)begin sl_flag = 1'b0; end
                          3'b010:if(sel_target < 3'b100)begin inven_flag = 1'b0; end else if(sel_target == 3'b100)begin sl_flag = 1'b0; end
                          3'b100:if(sel_target < 3'b100)begin inven_flag = 1'b1; end else if(sel_target == 3'b100)begin sl_flag = 1'b1; end
                          3'b110:if(sel_target < 3'b100)begin inven_flag = 1'b1; end else if(sel_target == 3'b100)begin sl_flag = 1'b1; end
                          3'b111:if(sel_target < 3'b100)begin inven_flag = !curr_inven_flag; end else if(sel_target == 3'b100)begin sl_flag = !curr_sl_flag; end
                        endcase
                    end
                   end
                   curr_inven_flag = inven_flag;
                   curr_sl_flag = sl_flag;
                end //membank
            end else begin
                curr_inven_flag = inven_flag;
                curr_sl_flag = sl_flag;
         end  //select command

//Rest of the commands assigning current_cmd        
        if(rx_cmd[1])begin   //acknowledge command
            current_cmd = CMD_ACK;
            counter_EPC_read = counter_EPC;
            if(counter_EPC_read == 6'd0) begin
                bit_shift_reg = 16'd0;
            end 
        end else if(rx_cmd[7])begin  // read command (epc)
            current_cmd = CMD_EPC_READ;
        end else if(rx_cmd[11])begin
            current_cmd = CMD_SENSOR_READ;  // sensor read command
        end else if(rx_cmd[8])begin
            current_cmd = CMD_EPC_WRITE;   //write command (epc)
        end else if (tx_enable == 1'b0)begin // current _cmd needs to be on during the whole transmission part
            current_cmd = CMD_RESET; // tx_enable used as reset
            myflag = 1'b0;
        end else begin
            myflag_ack = 1'b0;
        end

// ACK - whole bank has to be transmitted, so store the ptr val (counter_EPC),
// till which we wrote EPC words in counter_EPC_read        
        if(current_cmd == CMD_ACK && myflag_ack == 1'b0)begin
            counter_EPC_read = counter_EPC;
        end else begin
           counter_EPC_read = counter_EPC_read; 
        end

//Read_or_Write - states stored in this reg. Assigned here       
        if(current_cmd == CMD_EPC_READ)begin
            if(packetcomplete)begin 
                if(readwritebank == 2'b01)begin
                    Read_or_Write = EPC_READ;
                    temp = readwriteptr+readwords-8'd1;
                    temp_low = readwriteptr -8'd1;
                end
            end
        end else if(current_cmd == CMD_SENSOR_READ)begin
            if(sensor_code == 3'd1)begin
                Read_or_Write = SENSOR1_READ;
            end
            else if(sensor_code == 3'd2)begin
                Read_or_Write = SENSOR2_READ;
            end
        end else if(current_cmd == CMD_EPC_WRITE)begin
            if(EPC_data_ready)begin 
               if(readwritebank == 2'b01)begin
                   Read_or_Write = EPC_WRITE; 
               end
            end
        end else begin
            Read_or_Write = RorW_INITIAL;
        end

//adc_flag is internal flag.         
        if(ADC_data_ready)begin //have to wait for one clock cycle
            adc_flag = ADC_DATA_READY_FLAG;
        end else begin
            adc_flag = 1'b0;
            myflag_s = 1'b0;
        end
        
        
//       
       if(adc_flag == ADC_DATA_READY_FLAG)begin 
          if(sensor_code == 3'b001)begin  //sensor 1
              Read_or_Write = SENSOR1_WRITE;
          end else if(sensor_code == 3'b010)begin  //sensor 2
              Read_or_Write = SENSOR2_WRITE;
          end else begin
               Read_or_Write = RorW_INITIAL;              
          end
          adc_temp_data = {sensor_time_stamp,ADC_data};
       end else begin
           adc_temp_data = 16'd0;
           
       end
        
       if(current_cmd == CMD_ACK)begin 
           myflag_ack = 1'b1;
           if(read_state == STATE_INITIAL)begin
               if(next_word)begin
                 mem_sel = 3'd1;
                 mem_address = counter_EPC_read;
                 PC_B = 1'd0;          
                 read_state = STATE_1;
                end
           end else if(read_state == STATE_1)begin
                 PC_B = 1'd1;
                 SE = 1'd1;
                 read_state = STATE_2;
           end else if(read_state == STATE_2)begin
                 bit_shift_reg = mem_read_in;
                 counter_EPC_read = counter_EPC_read -6'd1;               
                 read_state = STATE_RESET;
           end else begin
               if(counter_EPC_read == 6'd0)begin
                 words_done = 1'd1;   
                end else begin
                 words_done = 1'd0;
                 myflag_ack = 1'd0;
                end
                read_state = STATE_INITIAL;
                SE = 1'd0;
           end
        end else if(Read_or_Write == SENSOR1_WRITE && myflag_s == 1'b0)begin 
               if(write_state == STATE_INITIAL)begin
                      mem_sel = 3'd2;
                      PC_B = 1'b0;
                      mem_address = counter_s1;
                      write_state = STATE_1;
                          
                end else if(write_state == STATE_1)begin
                      PC_B = 1'd1;
                      mem_data_out = adc_temp_data;
                      WE = 1'd1;
                      write_state = STATE_2;
                end else if(write_state == STATE_2)begin
                      counter_s1 = counter_s1+6'd1;
                      mem_done = 1'd1;
                      write_state = STATE_RESET;
//                      myflag = 1'b1;
                end else begin
                      WE = 1'd0;
                      adc_flag = 1'd0;
                      write_state = STATE_INITIAL;
                      Read_or_Write = RorW_INITIAL;
                      myflag_s = 1'b1;
                      end
        end else if(Read_or_Write == SENSOR2_WRITE && myflag_s == 1'b0 )begin
            if(write_state == STATE_INITIAL)begin
                  mem_sel = 3'd4;
                  PC_B = 1'd0;
                  mem_address = counter_s2;  
                  write_state = STATE_1;          
            end else if(write_state == STATE_1)begin
                  PC_B = 1'd1;
                  mem_data_out = adc_temp_data;
                  WE = 1'd1;
                  write_state = STATE_2;
            end else if(write_state == STATE_2)begin    
                  counter_s2 = counter_s2+6'd1;
                  mem_done = 1;
                  write_state = STATE_RESET;
              
            end else begin
                  WE = 1'd0;
                  adc_flag = 1'd0;
                  write_state = STATE_INITIAL;
                  Read_or_Write = RorW_INITIAL;
                  myflag_s = 1'b1;
                  end
         end else if(Read_or_Write == EPC_WRITE  && myflag == 1'b0)begin
            if(write_state == STATE_INITIAL)begin
                  mem_sel = 3'd1;
                  PC_B = 1'd0;
                  mem_address = counter_EPC; 
                  write_state = STATE_1;    
            end else if(write_state == STATE_1)begin
                  PC_B = 1'd1;
                  mem_data_out = EPC_data_in;
                  WE = 1'd1;
                  write_state = STATE_2;
            end else if(write_state == STATE_2)begin
                  counter_EPC = counter_EPC+6'd1;
                  write_state = STATE_RESET;
            end else begin
                  WE = 1'd0;
                  write_state = STATE_INITIAL;
                  Read_or_Write = RorW_INITIAL;
                  myflag = 1'b1;
            end
        end else if(Read_or_Write == EPC_READ)begin     
            if(read_state == STATE_INITIAL)begin
                if(next_word)begin
                  mem_sel = 3'd1;
                  mem_address = temp; 
                  PC_B = 1'd0;
                  read_state = STATE_1;
                 end
            end else if(read_state == STATE_1)begin
                  PC_B = 1'd1;
                  SE = 1'd1;
                  read_state = STATE_2;
            end else if(read_state == STATE_2)begin
                   bit_shift_reg = mem_read_in;
                   temp = temp -8'd1;                  
                  read_state = STATE_RESET;
            end else begin
                if(temp == temp_low)begin
                  words_done = 1'd1;
                end else begin
                    words_done = words_done;
                end
                SE = 1'd0;
                read_state = STATE_INITIAL;
                next_word = 1'd0;
            end
        end else if(Read_or_Write == SENSOR1_READ)begin     
            if(read_state == STATE_INITIAL)begin
                if(next_word)begin
                  mem_sel = 3'd2;
                  mem_address = counter_s1-6'd1;
                  PC_B = 1'd0;
                  read_state = STATE_1;
                 end
            end else if(read_state == STATE_1)begin
                  PC_B = 1'd1;
                  SE = 1'd1;
                  read_state = STATE_2;
            end else if(read_state == STATE_2)begin 
                  bit_shift_reg = mem_read_in;
                  counter_s1 = counter_s1-6'd1;
                  read_state = STATE_RESET;
            end else begin
                if(counter_s1 == 6'd0)begin    
                 words_done = 1'd1;
                end else begin
                    words_done = words_done;
                end
                SE = 1'd0;
                next_word = 1'd0;
                read_state = STATE_INITIAL;
            end
        end else if(Read_or_Write == SENSOR2_READ)begin     
            if(read_state == STATE_INITIAL)begin
                if(next_word)begin
                  mem_sel = 3'd4;
                  mem_address = counter_s2-6'd1;
                  PC_B = 1'd0;
                  read_state = STATE_1;
                end
            end else if(read_state == STATE_1)begin
                  PC_B = 1'd1;
                  SE = 1'd1;
                  read_state = STATE_2;
            end else if(read_state == STATE_2)begin
                  bit_shift_reg = mem_read_in;
                  counter_s2 = counter_s2-6'd1;                 
                  read_state = STATE_RESET;
            end else begin
                if(counter_s2 ==0)begin         
                 words_done = 1'd1;
                end else begin
                    words_done = words_done;
                end
                read_state = STATE_INITIAL;
                SE = 1'd0;
                next_word = 1'd0;
            end
        end
    end
end//always
endmodule
