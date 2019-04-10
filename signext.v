`timescale 1ns / 1ps

module signext(
    input [15:0] inst16,
    output [31:0] SignImm
    );
assign SignImm = inst16[15:15]?{16'hffff, inst16} : {16'h0000, inst16};

endmodule
