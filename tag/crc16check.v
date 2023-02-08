
`timescale 1ns/1ps

// CRC16 check 

//commands that need crc16 check are: 
//select, and all access commands - reqrn, read, write, sensdata

module crc16check(reset, crcinclk, crcbitin, crc);
input reset, crcinclk, crcbitin;
output reg [15:0] crc;
  
/*  
// working code
reg [3:0] bitoutcounter;
wire crcdone;
assign crcbitout = ~crc[~bitoutcounter]; 
//assign crcbitout = 0;
assign crcdone = (bitoutcounter == 15);

always @ (posedge crcoutclk or posedge reset) begin
  if (reset) begin
    bitoutcounter <= 0;
  end else if (!crcdone) begin
    bitoutcounter <= bitoutcounter + 4'd1;
  end // ~reset
end // always


always @ (posedge crcinclk or posedge reset) begin
  if (reset) begin
    crc     <= 'hFFFF;
  end else begin
    crc[0]  <= crcbitin ^ crc[15];
    crc[1]  <= crc[0];
    crc[2]  <= crc[1];
    crc[3]  <= crc[2];
    crc[4]  <= crc[3];
    crc[5]  <= crc[4] ^ crcbitin ^ crc[15];
    crc[6]  <= crc[5];
    crc[7]  <= crc[6];
    crc[8]  <= crc[7];
    crc[9]  <= crc[8];
    crc[10] <= crc[9];
    crc[11] <= crc[10];
    crc[12] <= crc[11] ^ crcbitin ^ crc[15];
    crc[13] <= crc[12];
    crc[14] <= crc[13];
    crc[15] <= crc[14];
  end // ~reset
end // always
*/



//reg [2:0] bitoutcounter; //8 bit counter
//wire crcdone;
//assign crcout = crc;
//assign crcbitout = 0;

//initial crc     <= 16'hFFFF;

always @ (posedge crcinclk or posedge reset or negedge reset) begin
  if (reset) begin
    crc     <= 16'hFFFF;
  end else begin
    crc[0]  <= crcbitin ^ crc[15];
    crc[1]  <= crc[0];
    crc[2]  <= crc[1];
    crc[3]  <= crc[2];
    crc[4]  <= crc[3];
    crc[5]  <= crc[4] ^ crcbitin ^ crc[15];
    crc[6]  <= crc[5];
    crc[7]  <= crc[6];
    crc[8]  <= crc[7];
    crc[9]  <= crc[8];
    crc[10] <= crc[9];
    crc[11] <= crc[10];
    crc[12] <= crc[11] ^ crcbitin ^ crc[15];
    crc[13] <= crc[12];
    crc[14] <= crc[13];
    crc[15] <= crc[14];
    
  end // ~reset
end // always

endmodule

