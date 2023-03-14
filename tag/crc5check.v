//final as of 14-03-2023



`timescale 1ns/1ps

// CRC5

// inclk, inbit generate crc


module crc5(reset, crcinclk, crcbitin, crc);
input reset, crcinclk, crcbitin;
output reg [4:0] crc;


//reg [2:0] bitoutcounter; //8 bit counter
//wire crcdone;
//assign crcout = crc;
//assign crcbitout = 0;

//initial crc     <= 5'b01001;

always @ (posedge crcinclk or posedge reset) begin
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


