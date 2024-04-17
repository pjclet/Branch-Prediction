// Paul-John Clet
// Advanced VLSI Design - Final Project: Branch Prediction

`timescale 1ns / 1ps

// branch predictor
module gskew_predictor (input logic clk, input logic [2:0] pc, ghr,
								output logic prediction, new_prediction); // program counter and global history register
	
	logic [1:0] PHT [7:0]; // pattern history table
	logic [1:0] bimodal, Gselect, Gshare;
	logic [2:0] Gselect_index, Gshare_index;
	
	initial begin
		// pre load the PHT
		$readmemb("pht.txt", PHT);
		$display("[BP] Initialized and pre-loaded PHT.");
		
		bimodal = 2'b0; Gselect = 2'b0; Gshare = 2'b0; 
		Gselect_index = 3'b0; Gshare_index = 3'b0;
		prediction = 1'b0;
	end
	
	// output to prediction bus
	always @(posedge clk) begin
		#1;
		
		// test 1 - Gshare
		Gshare_index = pc ^ ghr;
		Gshare = PHT[Gshare_index];
		
		// test 2 - Gselect
		Gselect_index = {pc[1:0], ghr[0]};
		Gselect = PHT[Gselect_index];
		
		// test 3 - bimodal
		bimodal = PHT[pc];
		
		// majority vote
		prediction = ((bimodal[1] & Gselect[1]) | (Gselect[1] & Gshare[1]) | (bimodal[1] & Gshare[1]));
		$display("[GSKEW] New prediction: %b", prediction);
		
		new_prediction = 1'b1; #1; new_prediction = 1'b0; // toggle prediction bus ***** maybe we don't need this?
	end
	
	// when the branch is decided (in execution), we update the PHT
//	always @(posedge branch) begin
//		
//		
//		
//	end
	
	
endmodule
