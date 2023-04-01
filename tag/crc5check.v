//final as of 1/4/23

`timescale 1ns/1ns
// CRC5
// inclk, inbit generate crc
module crc5check(reset, crcinclk, crcbitin, crcout);
input  reset, crcinclk, crcbitin;
output wire [4:0] crcout;
reg [4:0] crc;
//reg [2:0] bitoutcounter; //8 bit counter
//wire crcdone;
//assign crcout = crc;
//assign crcbitout = 0;
//initial crc     <= 5'b01001;

assign	crcout[0] = crc[0] || reset;
assign	crcout[1] = crc[1] & ~reset;
assign	crcout[2] = crc[2] & ~reset;
assign	crcout[3] = crc[3] || reset;
assign	crcout[4] = crc[4] & ~reset;

always @ (posedge crcinclk) begin
    crc[0]  <= (crcbitin ^ crcout[4]);
    crc[1]  <= crcout[0];
    crc[2]  <= crcout[1];
    crc[3]  <= crcout[2] ^ crcbitin ^ crcout[4];
    crc[4]  <= crcout[3];

end // always

endmodule

/*
`timescale 1ns/1ps
// CRC5
// inclk, inbit generate crc
module crc5check (reset, crcinclk, crcbitin, crc);
input reset, crcinclk, crcbitin;
output reg [4:0] crc;
//reg [2:0] bitoutcounter; //8 bit counter
//wire crcdone;
//assign crcout = crc;
//assign crcbitout = 0;
//initial crc     <= 5'b01001;
always @ ( posedge crcinclk or posedge reset) begin
  if (reset) begin
    crc     <= 5'b01001;
  end else begin
    crc[0]  <= (crcbitin ^ crc[4]);
    crc[1]  <= crc[0];
    crc[2]  <= crc[1];
    crc[3]  <= crc[2] ^ crcbitin ^ crc[4];
    crc[4]  <= crc[3];
  end // ~reset
end // always
always @ (negedge reset) begin
    if(reset) begin
        crc     <= 5'b01001;
    end else begin
       crc[0]  <= (crcbitin ^ crc[4]);
       crc[1]  <= crc[0];
       crc[2]  <= crc[1];
       crc[3]  <= crc[2] ^ crcbitin ^ crc[4];
       crc[4]  <= crc[3];
    end
end
endmodule
*/
