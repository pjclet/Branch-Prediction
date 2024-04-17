// Paul-John Clet
// Advanced VLSI Design - Final Project: Branch Prediction


`timescale 1ns / 1ps

// PC
module program_counter (input logic clk, prediction, flush_pipeline,
								input logic [31:0] BTB_address, true_address,
								
								output logic [31:0] next_PC);

//	logic [7:0] PC; // current program counter
	
//	assign next_PC = PC;
	
	initial begin
		next_PC = 8'b0;
	end
	
	always @(posedge clk) begin
		if (next_PC >= 18) begin
			$display("[EXIT] Finishing program.");
			$stop;
		end
	
	
		if (flush_pipeline) begin
			$display("[PC] Flushed pipeline");
			next_PC = true_address;
		end else begin
			if (~prediction) begin
				$display("[PC] Adding 1 to PC");
				next_PC = next_PC + 1'b1;
//				next_PC = PC + 1'b1;
			end else begin
				$display("[PC] Jumping to %d from BP.", BTB_address);
				// set the next PC to the BTB address
				next_PC = BTB_address;
			end
		end
		
		$display("[PC] Current PC: %d", next_PC);
	end
	
endmodule
