// Paul-John Clet
// Advanced VLSI Design - Final Project: Branch Prediction

`timescale 1ns / 1ps

// simplified execution pipeline, includes ALU, BNE, and JAL instruction execution
// also simplifies writeback since the data is saved in here
module execution_pipeline (input logic clk,
									input logic [4:0] rs1, rs2, rd,
									input logic is_add, is_nop, is_jump, is_branch,
									input logic [31:0] next_address, current_PC,
									
									// bp inputs
									input logic prediction,
									
									// outputs
									output logic [31:0] next_PC,
									output logic flush_pipeline,
									
									// output to update actual prediction
									output logic new_branch_decision, branch_decision,
									
									// output to branch target buffer
									output logic [63:0] tag_and_target_address,  // 29 tag bits + 3 index bits + 32 address bits = 64 bits
									output logic valid_tag_and_target);
	
	
	logic [31:0] RF [31:0];
	logic [31:0] third_recent_PC, second_recent_PC, recent_PC;
	logic branch_taken, recent_pred;
	
	initial begin
		// initialize data to simplify load and store operations
		// registers are valid, and each register has its respective value
		for (int i = 0; i < 32; i++) begin
			RF[i] = i;
			$display("[EX] Set register %0d to value %0d", i, RF[i]);
		end
		
		RF[2] = 32'b0; RF[3] = 32'b0; flush_pipeline = 1'b0; next_PC = 32'b0; branch_taken = 1'b0;
		branch_decision = 1'b0; new_branch_decision = 1'b0; recent_pred = 1'b0; recent_PC = 32'b0; second_recent_PC = 32'b0; third_recent_PC = 32'b0;
		tag_and_target_address = 61'b0; valid_tag_and_target = 1'b0;
	end
	
	always @(posedge clk) begin
		recent_pred <= prediction;
		third_recent_PC <= current_PC;
		second_recent_PC <= third_recent_PC;
		recent_PC = second_recent_PC;
	end
	
	
	// begin execution
	always @(posedge clk) begin
	
		// reset the flush
		flush_pipeline = 1'b0;
		
		
//		#3;
//		#4;
		
	
		
		// try executing the instructions
		if (is_add) begin
			// perform the addition, update the register file, then display the output
			
			RF[rd] = RF[rs1] + RF[rs2];
			$display("[EX] Added $r%0d and $r%0d, saving it to $r%0d -> %0d", rs1, rs2, rd, RF[rd]);
			
		end 
		else if (is_branch) begin
			// check the branch condition, then check against the four cases
			$display("[EX] Processing BNE instruction.");
			// bne
			branch_taken = (RF[rs1] != RF[rs2]); 
			
			// if predicted taken, and actually taken, print successful branch prediction
			if (recent_pred & branch_taken) begin
				$display("[EX] [SUCCESS] Successful prediction - Predicted taken, actually taken.");
				// update BTB *****
				tag_and_target_address = {current_PC, next_address}; // send all 64 bits
				valid_tag_and_target = 1'b1; #1; valid_tag_and_target = 1'b0;
			end
			
			// if predicted taken, and actually not taken, then we need to flush the pipeline
			else if (recent_pred & ~branch_taken) begin
				$display("[EX] Misprediction - Predicted taken, actually not taken.");
				next_PC = recent_PC + 2; 
				flush_pipeline = 1'b1;
				$display("[EX] Next PC: %0d", next_PC);
			end
			// if predicted not taken, and actually taken, then flush the pipeline and take the branch
			else if (~recent_pred & branch_taken) begin
				$display("[EX] Misprediction - Predicted not taken, actually taken.");
				$display("\tRegisters: %0d | %0d",rs1, rs2);
				$display("%0d | %0d", RF[rs1], RF[rs2]);
				next_PC = next_address;
				flush_pipeline = 1'b1;
				$display("[EX] Next PC: %0d", next_PC);
			end
			// if predicted not taken, and actually not naken, then print successful branch prediction (not taken)
			else if (~recent_pred & ~branch_taken) begin
				$display("[EX] [SUCCESS] Successful prediction - Predicted not taken, actually not taken.");
				// update BTB *****
				tag_and_target_address = {current_PC, next_address}; // send all 64 bits
				valid_tag_and_target = 1'b1; #1; valid_tag_and_target = 1'b0;
			end 
			else begin
				$display("[ERROR] [EX] Logical error.");
			end
			
			// output the branch decision to the GHR 
			branch_decision = branch_taken;
			new_branch_decision = 1'b1; #1; new_branch_decision = 1'b0;
		end
		
		else begin if (is_jump) begin
			// resolve the address to jump to, then take the branch
			
			// if predicted taken, print successful branch prediction
			if (recent_pred) begin
				$display("[EX] [SUCCESS] Successful prediction - Jump taken.");
				// update BTB?? ***** 
				tag_and_target_address = {current_PC, next_address}; // send all 64 bits
				valid_tag_and_target = 1'b1; #1; valid_tag_and_target = 1'b0;
			end
			// if predicted not taken, then flush the pipeline and take the branch
//			else begin
//			end
			
				$display("[EX] Misprediction - Jump not taken.");
				
				next_PC = next_address;
				flush_pipeline = 1'b1;
			end
			
			
			
			
		end
	end
	
endmodule


