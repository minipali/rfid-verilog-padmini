//final as of 01-04-2023
`timescale 1ns/1ns

// CRC16 check: only diff with crc16 is that this has parallel output

//commands that need crc16 check are: 
//select, and all access commands - reqrn, read, write, sensdata

module crc16check(reset, crcinclk, crcbitin, crcout);
input reset, crcinclk, crcbitin;
output wire [15:0] crcout;
reg [15:0] crc;
assign	crcout[0] = crc[0] || reset;
assign	crcout[1] = crc[1] || reset;
assign	crcout[2] = crc[2] || reset;
assign	crcout[3] = crc[3] || reset;
assign	crcout[4] = crc[4] || reset;
assign	crcout[5] = crc[5] || reset;
assign	crcout[6] = crc[6] || reset;
assign	crcout[7] = crc[7] || reset;
assign	crcout[8] = crc[8] || reset;
assign	crcout[9] = crc[9] || reset;
assign	crcout[10] = crc[10] || reset;
assign	crcout[11] = crc[11] || reset;
assign	crcout[12] = crc[12] || reset;
assign	crcout[13] = crc[13] || reset;
assign	crcout[14] = crc[14] || reset;
assign	crcout[15] = crc[15] || reset;


always @ (posedge crcinclk) begin
  
    crc[0]  <= crcbitin ^ crcout[15];
    crc[1]  <= crcout[0];
    crc[2]  <= crcout[1];
    crc[3]  <= crcout[2];
    crc[4]  <= crcout[3];
    crc[5]  <= crcout[4] ^ crcbitin ^ crcout[15];
    crc[6]  <= crcout[5];
    crc[7]  <= crcout[6];
    crc[8]  <= crcout[7];
    crc[9]  <= crcout[8];
    crc[10] <= crcout[9];
    crc[11] <= crcout[10];
    crc[12] <= crcout[11] ^ crcbitin ^ crcout[15];
    crc[13] <= crcout[12];
    crc[14] <= crcout[13];
    crc[15] <= crcout[14];
    
  
end // always


endmodule
