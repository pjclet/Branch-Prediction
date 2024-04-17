// Paul-John Clet
// Advanced VLSI Design - Final Project: Branch Prediction

`timescale 1ns / 1ps

// global history register - shift register to listen to all the branch decisions
module global_history_register (input logic clk, branch_decision, new_branch_decision, // probably do not need clock here
										  output logic [7:0] register_output);

	logic [7:0] GHR; // current program counter
	
	assign register_output = GHR;
	
	initial begin
		GHR = 8'b0;
	end
	
	always @(posedge new_branch_decision) begin
		// shift all the bits, then set the most recent bit as the most recent output for the branch decision
		GHR = GHR << 1;
		GHR[0] = branch_decision;
	end
	
endmodule
