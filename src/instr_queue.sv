// Paul-John Clet
// Advanced VLSI Design - Final Project: Branch Prediction

`timescale 1ns / 1ps

// instruction queue
module instr_queue(input logic clk, 
						 input logic [31:0] PC,
						 output logic [31:0] instr_out, current_PC);
							
	logic [31:0] InstrRAM [32:0];
	
	// read instructions to RAM
	initial begin
		$readmemb("bp.txt", InstrRAM); current_PC = 32'b0;
		instr_out = 32'b0;
		$display("[INSTR QUEUE] Initialized.");
	end
	
	always @(posedge clk) begin
//		#7;
		instr_out = InstrRAM[PC];
		current_PC = PC;
		$display("[INSTR QUEUE] Output new instruction: %b", instr_out);
		$display("\t%d",PC);
	end
	

endmodule
