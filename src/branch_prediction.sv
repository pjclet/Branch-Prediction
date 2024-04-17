// Paul-John Clet
// Advanced VLSI Design - Final Project: Branch Prediction

`timescale 1ns / 1ps

// toplevel module
module branch_prediction (input logic clk);
	
	
//// IQ module
//	instr_queue iq (.clk(clk), .dispatch_1_ready(dispatch_1_ready), .dispatch_2_ready(dispatch_2_ready), .instr1(instr1), .instr2(instr2), .instr_queue_empty(instr_queue_empty));	
	
	// ---------- program counter (PC) ----------
	
	logic final_prediction, flush_pipeline; // input to PC from the output of bp
	logic [31:0] BTB_address, true_address;
	logic [31:0] PC;
	
	program_counter prog_ctr (.clk(clk), .prediction(final_prediction), .flush_pipeline(flush_pipeline), .BTB_address(BTB_address), .true_address(true_address), .next_PC(PC));
	
	// ---------- end program counter (PC) ----------
	
	// ---------- instruction queue ----------
	
	logic [31:0] instr_out, current_PC;
	
	instr_queue iq (.clk(clk), .PC(PC), .instr_out(instr_out), .current_PC(current_PC));
	
	// ---------- end instruction queue ----------
	
	// ---------- global history register (GHR) ----------
	
	logic branch_decision, new_branch_decision;
	logic [7:0] register_output;
	
	global_history_register ghr (.clk(clk), .branch_decision(branch_decision), .new_branch_decision(new_branch_decision), .register_output(register_output));
	
	// ---------- end global history register (GHR) ----------
	
	// ---------- gskew predictor ----------
	
	logic gskew_prediction, new_gskew_prediction;
	
	gskew_predictor gskew (.clk(clk), .pc(PC[2:0]), .ghr(register_output[2:0]), .prediction(gskew_prediction), .new_prediction(new_gskew_prediction));
	
	// ---------- end gskew predictor ----------
	
	// ---------- branch target buffer ----------
	
	logic [63:0] tag_and_target_address;
	logic valid_tag_and_target, hit;
//	logic [31:0] target_address;
	
	branch_target_buffer btb (.clk(clk), .pc(PC), .tag_and_target_address(tag_and_target_address), .valid_tag_and_target(valid_tag_and_target), .hit(hit), .target_address(BTB_address));
	
	// ---------- end branch target buffer ----------
	
	// ---------- prediction validation ----------
	
//	logic final_prediction;
	
	prediction_validation pred_val (.clk(clk), .gskew_prediction(gskew_prediction), .new_prediction(new_gskew_prediction), .hit(hit), .final_prediction(final_prediction));
	
	// ---------- end prediction validation ----------
	
	// ---------- decode pipeline ----------
	
	logic [4:0] rs1, rs2, rd;
	logic [31:0] address_out, output_PC;
	logic is_add, is_nop, is_jump, is_branch;
	
	decode_pipeline decode_pl (.clk(clk), .instr_in(instr_out), .current_PC(PC), .rs1(rs1), .rs2(rs2), .rd(rd), .address_out(address_out), .output_PC(output_PC), .is_add(is_add), .is_nop(is_nop),
										.is_jump(is_jump), .is_branch(is_branch));
	
	// ---------- end decode pipeline ----------
	
	execution_pipeline exec (.clk(clk), .rs1(rs1), .rs2(rs2), .rd(rd), .is_add(is_add), .is_nop(is_nop), .is_jump(is_jump), .is_branch(is_branch), .next_address(address_out), .current_PC(output_PC),
									 .prediction(final_prediction), .next_PC(true_address), .flush_pipeline(flush_pipeline), .new_branch_decision(new_branch_decision), .branch_decision(branch_decision),
									 .tag_and_target_address(tag_and_target_address), .valid_tag_and_target(valid_tag_and_target));
	
endmodule
