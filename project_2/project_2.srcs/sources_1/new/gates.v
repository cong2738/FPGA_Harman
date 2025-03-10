`timescale 1ns / 1ps
// run time unit  / sym time unit 

//top modul
module gates(input a,
    input b, 
    output y0, 
    output y1,
    output y2, 
    output y3, 
    output y4, 
    output y5 
    );
//type Logic
    assign y0 = a & b;
    assign y1 = a | b;
    assign y2 = ~(a & b);    
    assign y3 = a ^ b; 
    assign y4 = ~(a | b);
    assign y5 = ~a;
    
endmodule