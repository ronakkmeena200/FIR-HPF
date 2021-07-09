

module FIR(
    input signed [7:0] Xin,
    output reg signed  [13:0] Out,
    input Clk
    );
    
    wire signed [12:0]  h [12:0];    // bit_length =13
    wire signed [20:0]  M [12:0];    // bit_length =21
    wire signed [14:0]  Ad [11:0];   // bit_length =14
    wire signed [13:0]  Q [11:0];
    //Coefficients
    assign h[0] = 13'b0000000001010;
    assign h[1] = 13'b0000000100101;
    assign h[2] = 13'b0000000111011;
    assign h[3] = 13'b1111110111000;
    assign h[4] = 13'b1111000100011;
    assign h[5] = 13'b1110000100100;
    assign h[6] = 13'b0101100101111;
    assign h[7] = 13'b1110000100100;
    assign h[8] = 13'b1111000100011;
    assign h[9] = 13'b1111110111000;
    assign h[10] = 13'b0000000111011;
    assign h[11] = 13'b0000000100101;    
    assign h[12] = 13'b0000000001010;
    
    //Multiple constant multiplications.
    assign M[0] = h[12]*Xin;     //20 = 13*8
    assign M[1] = h[11]*Xin; 
    assign M[2] = h[10]*Xin; 
    assign M[3] = h[9]*Xin; 
    assign M[4] = h[8]*Xin;  
    assign M[5] = h[7]*Xin;  
    assign M[6] = h[6]*Xin;  
    assign M[7] = h[5]*Xin;  
    assign M[8] = h[4]*Xin;  
    assign M[9] = h[3]*Xin;  
    assign M[10] = h[2]*Xin; 
    assign M[11] = h[1]*Xin; 
    assign M[12] = h[0]*Xin; 
    
    //adders
    assign Ad[0] = Q[0] + M[1][19:6]; //only selecting 
    assign Ad[1] = Q[1] + M[2][19:6];
    assign Ad[2] = Q[2] + M[3][19:6];
    assign Ad[3] = Q[3] + M[4][19:6];
    assign Ad[4] = Q[4] + M[5][19:6];
    assign Ad[5] = Q[5] + M[6][19:6];
    assign Ad[6] = Q[6] + M[7][19:6];
    assign Ad[7] = Q[7] + M[8][19:6];
    assign Ad[8] = Q[8] + M[9][19:6];
    assign Ad[9] = Q[9] + M[10][19:6];
    assign Ad[10] = Q[10] + M[11][19:6];
    assign Ad[11] = Q[11] + M[12][19:6];
    
    //flipflop instantiations (for introducing a delay).
     DFF dff1 (.Clk(Clk),.D(M[0][19:6]),.Q(Q[0]));
     DFF dff2 (.Clk(Clk),.D(Ad[0][13:0]),.Q(Q[1]));
     DFF dff3 (.Clk(Clk),.D(Ad[1][13:0]),.Q(Q[2]));
     DFF dff4 (.Clk(Clk),.D(Ad[2][13:0]),.Q(Q[3]));
     DFF dff5 (.Clk(Clk),.D(Ad[3][13:0]),.Q(Q[4]));
     DFF dff6 (.Clk(Clk),.D(Ad[4][13:0]),.Q(Q[5]));
     DFF dff7 (.Clk(Clk),.D(Ad[5][13:0]),.Q(Q[6]));
     DFF dff8 (.Clk(Clk),.D(Ad[6][13:0]),.Q(Q[7]));
     DFF dff9 (.Clk(Clk),.D(Ad[7][13:0]),.Q(Q[8]));
     DFF dff10 (.Clk(Clk),.D(Ad[8][13:0]),.Q(Q[9]));
     DFF dff11 (.Clk(Clk),.D(Ad[9][13:0]),.Q(Q[10]));
     DFF dff12 (.Clk(Clk),.D(Ad[10][13:0]),.Q(Q[11]));
     
     always @(posedge Clk)
     Out <=Ad[11][13:0];
     
endmodule

module DFF
        (input Clk,
        input [13:0] D,
        output reg [13:0]   Q
        );
    
    always@ (posedge Clk)
        Q <= D;
    
endmodule

module tb;

    // Inputs
    reg Clk;
    reg signed [7:0] Xin;
	reg signed [13:0] Ver; // Variable to store output estimated by Matlab
	reg signed [13:0] Check;// Variable to check if Out - Ver=0

    // Outputs
    wire signed [13:0] Out;
	integer   fd,fd1,fd2,r;

    // Instantiate the Unit Under Test (UUT)
    FIR uut (
        .Clk(Clk), 
        .Xin(Xin), 
        .Out(Out)
    );
    
    //Generate a clock with 10 ns clock period.
    initial Clk = 0;
    always #5 Clk =~Clk;

    
//Initialize and apply the inputs.
	
    initial begin
		fd = $fopen("exp.txt", "r");
		fd1=$fopen("out.txt","w");
		fd2 = $fopen("Verify.txt", "r");		
		
        Xin = 0;  #130;
		while (! $feof(fd)) begin
			r = $fscanf(fd,"%b\n", Xin);#6;
			r = $fscanf(fd2,"%b\n", Ver);
			Check=Out-Ver;
			$fdisplay(fd1,"%b %d \n",Out,Out);#4;
        end 
		$fclose(fd);
		#10 $finish;
    end
	
	 initial begin
        $dumpfile("test.vcd");
        $dumpvars(0, tb);
    end
      
endmodule
