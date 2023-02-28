
`timescale 1ns/1ps

// CRC16 check: only diff with crc16 is that this has parallel output

//commands that need crc16 check are: 
//select, and all access commands - reqrn, read, write, sensdata

module crc16check(reset, crcinclk, crcbitin, crc);
input reset, crcinclk, crcbitin;
output reg [15:0] crc;

always @ (posedge crcinclk or posedge reset) begin
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


