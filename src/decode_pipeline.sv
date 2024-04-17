// Paul-John Clet
// Advanced VLSI Design - Final Project: Branch Prediction

`timescale 1ns / 1ps

// decode stage (ID)
module decode_pipeline (input logic clk, 
								input logic [31:0] instr_in, current_PC,
								
								// general outputs
								output logic [4:0] rs1, rs2, rd,
								output logic [31:0] address_out, output_PC,
								
								// alu control signals
								output logic is_add,
								
								// other control signals?
								output logic is_nop, is_jump, is_branch);
	// initialize signals to 0
	initial begin
		address_out = 32'b0;
	end
	
	always @(posedge clk) begin
		$display("[DECODE] Current PC Address: %d", current_PC);
		
		// reset all the signals
		is_add = 1'b0; is_branch = 1'b0; is_jump = 1'b0; is_nop <= 1'b0;
//		#5;
		#2;
		
		// update the output PC
		output_PC = current_PC;
		
		// add instruction - ADD
		if (instr_in[6:0] == 7'b0110011 && instr_in[31:25] == 7'b0000000 && instr_in[14:12] == 3'b000) begin
			$display("[DECODE] Received ADD instruction.");
			
			// output the source registers 
			rs1 = instr_in[19:15];
			rs2 = instr_in[24:20];
			rd = instr_in[11:7];
			$display("[DECODE] Registers output: rd = $r%0d, rs1 = $r%0d, rs2 = $r%0d", rd, rs1, rs2);
			// ***** - maybe have data sent immediately
			
			is_add = 1'b1;
		end
		// branch instruction - BNE
		else if (instr_in[6:0] == 7'b1100011 && instr_in[14:12] == 3'b001) begin
			$display("[DECODE] Received BNE instruction.");
			
			// output the source registers 
			rs1 = instr_in[19:15];
			rs2 = instr_in[24:20];
			rd = 5'b0;
			$display("[DECODE] Registers output: rd = $r%0d, rs1 = $r%0d, rs2 = $r%0d", rd, rs1, rs2);
			
			is_branch = 1'b1;
			address_out = {19'b0, instr_in[31:25], instr_in[11:7]}; // pad with 0's
			
		end
		// jump instruction - technically JAL instruction
		else if(instr_in[6:0] == 7'b0110111) begin
			$display("[DECODE] Received JUMP instruction.");
			
			is_jump = 1'b1;
			address_out = {11'b0, instr_in[31:12]}; // pad with 0's
			
		end
		else begin 
			$display("[DECODE] Received NOP/no instruction/invalid instruction, stalling.");
			is_nop <= 1'b1;
		end
	end

	
	
endmodule
