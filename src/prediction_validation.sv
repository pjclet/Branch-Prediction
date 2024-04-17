// Paul-John Clet
// Advanced VLSI Design - Final Project: Branch Prediction

`timescale 1ns / 1ps

// prediction validation - and gate between HIT from BTB and Gskew predictor
module prediction_validation (input logic clk, gskew_prediction, new_prediction, hit, // probably do not need clock here
										output logic final_prediction);

	logic pred; // current program counter
	
	assign final_prediction = pred;
	
	initial begin
		pred = 1'b0;
	end
	
	always @(posedge new_prediction) begin
		// set the output to the and of the gskew predictor + hit whenever there is a new prediction - maybe overkill?
		pred = gskew_prediction & hit;
		if (pred) begin
			$display("***[BP] Predict branch taken!");
		end
	end
	
endmodule
