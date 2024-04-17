// Paul-John Clet
// Advanced VLSI Design - Final Project: Branch Prediction

`timescale 1ns / 1ps

// branch target buffer - hold addresses for PC jumps
module branch_target_buffer (input logic clk, 
									  input logic [31:0] pc, // get full 32 bits of the PC
									  
									  // used to update the btb
									  input logic [63:0] tag_and_target_address, // 29 tag bits + 3 index bits + 32 address bits = 64 bits
									  input logic valid_tag_and_target,
									  
									  // outputs
									  output logic hit, 
									  output logic [31:0] target_address); 
	
	logic [61:0] BTB [7:0]; // full BTB = 1 valid bit + 29 tag bits + 32 address bits = 62 bits
	
	initial begin
		// pre load the BTB
		$readmemb("btb.txt", BTB); // load btb to always jump
		target_address = 32'b0; hit = 1'b0;
		$display("[BP] Initialized and pre-loaded BTB.");
	end
	
	// at every clock edge, check for a hit on the PC
	always @(posedge clk) begin
		hit = 1'b0;
		#1;
		$display("%b", BTB[pc[2:0]]);
		// if there is a hit on the current PC index
		if (BTB[pc[2:0]][61] == 1'b1) begin
			
			if (pc[31:3] == BTB[pc[2:0]][60:32]) begin
				$display("[BTB] Tag hit!\n\t%b | %b", pc[31:3], BTB[pc[2:0]][60:32]);
				target_address = BTB[pc[2:0]][31:0]; // update the data
				hit = 1'b1; // send a hit signal out
			end 
			// error handling
			else begin
				$display("[BTB] Valid entry, but tags did not match. \n\t%b | %b", pc[31:3], BTB[pc[2:0]][60:32]);
			end
		end
	end 
	
	// ability to update the BTB
	always @(posedge valid_tag_and_target) begin
		// update entry, use the last three of the received PC address (in tag_and_target_address) as the index
		
		BTB[tag_and_target_address[34:32]] = {1'b1, tag_and_target_address[63:35], tag_and_target_address[31:0]};
		$display("[BTB] Updated BTB with a new entry: %d - %h", tag_and_target_address[34:32], BTB[tag_and_target_address[34:32]]);
		
	end
	
	
endmodule
