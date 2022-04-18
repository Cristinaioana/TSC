/***********************************************************************
 * A SystemVerilog testbench for an instruction register.
 * The course labs will convert this to an object-oriented testbench
 * with constrained random test generation, functional coverage, and
 * a scoreboard for self-verification.
 **********************************************************************/


 //in afara de initial begin, adaugam tot in clasa - functii, task-uri, interfata si variabile interne (seed)


  module instr_register_test
  import instr_register_pkg::*;  // user-defined types are defined in instr_register_pkg.sv
  (
	tb_ifc.TB intf_lab 
  );

  class Transaction;
    virtual tb_ifc.TB intf_lab ;
    parameter nr_of_operations = 100;
    //int seed = 100;

covergroup my_coverage();
    OP_ACOVER: coverpoint intf_lab.cb.instruction_word.op_a{
      bins neg[] = {[-15:-1]};
      bins zero = {0};
      bins pos[] = {[1:15]};
    }
    
    OP_BCOVER: coverpoint intf_lab.cb.instruction_word.op_b{
      bins zero = {0};
      bins pos[] = {[1:15]};
    }

    OPCCOVER: coverpoint intf_lab.cb.instruction_word.opc{
      bins zero = {0};
      bins pos[] = {[1:7]};
    }
	 
	  RESULTCOVER: coverpoint intf_lab.cb.instruction_word.result{
	    bins result_values_neg[] = {[-31:-1]};
      bins result_values_zero = {0};
      bins result_values_pos[] = {[1:31]};
	}
  endgroup
     
  function new(virtual tb_ifc.TB interfata);
    intf_lab = interfata;  
    my_coverage = new();
  endfunction

//pag 344
  
  //timeunit 1ns/1ns;
 
  //initial begin
    task run();
    $display("\n\n***********************************************************");
    $display(    "***  THIS IS NOT A SELF-CHECKING TESTBENCH (YET).  YOU  ***");
    $display(    "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
    $display(    "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  ***");
    $display(    "***********************************************************");

    $display("\nReseting the instruction register...");
    intf_lab.cb.write_pointer  <= 5'h00;         // initialize write pointer
    intf_lab.cb.read_pointer   <= 5'h1F;         // initialize read pointer
    intf_lab.cb.load_en        <= 1'b0;          // initialize load control line
    intf_lab.cb.reset_n       <= 1'b0;           // assert reset_n (active low)
    repeat (2) @(posedge intf_lab.cb) ;          // hold in reset for 2 clock cycles
    intf_lab.cb.reset_n        <= 1'b1;          // deassert reset_n (active low)

    $display("\nWriting values to register stack...");
    @(posedge intf_lab.cb) intf_lab.cb.load_en <= 1'b1;  // enable writing to register
    repeat (nr_of_operations) begin
      @(posedge intf_lab.cb) randomize_transaction;
      @(negedge intf_lab.cb) print_transaction;
      my_coverage.sample();      
    end
    @(posedge intf_lab.cb) intf_lab.cb.load_en <= 1'b0;  // turn-off writing to register

    // read back and display same three register locations
    $display("\nReading back the same register locations written...");
    for (int i=0; i<=nr_of_operations; i++) begin
      // later labs will replace this loop with iterating through a
      // scoreboard to determine which addresses were written and
      // the expected values to be read back
      @(posedge intf_lab.cb) intf_lab.cb.read_pointer <= i;
      @(negedge intf_lab.cb) print_results;
      my_coverage.sample();
    end

    @(posedge intf_lab.cb) ;
    $display("\n***********************************************************");
    $display(  "***  THIS IS NOT A SELF-CHECKING TESTBENCH (YET).  YOU  ***");
    $display(  "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
    $display(  "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  ***");
    $display(  "***********************************************************\n");
    $finish;
  //end
  endtask

  function void randomize_transaction;
    // A later lab will replace this function with SystemVerilog
    // constrained random values
    //
    // The stactic temp variable is required in order to write to fixed
    // addresses of 0, 1 and 2.  This will be replaceed with randomizeed
    // write_pointer values in a later lab
    //
    static int temp = 0;
    //intf_lab.cb.operand_a     <= $random(seed)%16;                 // between -15 and 15
    //intf_lab.cb.operand_b     <= $unsigned($random)%16;            // between 0 and 15
    //intf_lab.cb.opcode        <= opcode_t'($unsigned($random)%8);  // between 0 and 7, cast to opcode_t type

    intf_lab.cb.operand_a     <= $urandom()%16;                     // between -15 and 15
    intf_lab.cb.operand_b     <= $unsigned($urandom)%16;            // between 0 and 15
    intf_lab.cb.opcode        <= opcode_t'($unsigned($urandom)%8);  // between 0 and 7, cast to opcode_t type
    intf_lab.cb.write_pointer <= temp++;
  endfunction: randomize_transaction

  function void print_transaction;
    $display("Writing to register location %0d: ", intf_lab.cb.write_pointer);
    $display("  opcode = %0d (%s)", intf_lab.cb.opcode, intf_lab.cb.opcode.name);
    $display("  operand_a = %0d",   intf_lab.cb.operand_a);
    $display("  operand_b = %0d\n", intf_lab.cb.operand_b);
    $display("  TIME: %t ns", $time);
  endfunction: print_transaction

  function void print_results;
    $display("Read from register location %0d: ", intf_lab.cb.read_pointer);
    $display("  opcode = %0d (%s)", intf_lab.cb.instruction_word.opc, intf_lab.cb.instruction_word.opc.name);
    $display("  operand_a = %0d",   intf_lab.cb.instruction_word.op_a);
    $display("  operand_b = %0d\n", intf_lab.cb.instruction_word.op_b);
    $display("  result    = %0d\n", intf_lab.cb.instruction_word.result);
  endfunction: print_results

endclass : Transaction

//initial begin 
//  Transaction t;
//  t = new();
//  t.intf_lab = intf_lab;
//  t.run();
//end

//declarare interfata in constructor
initial begin 
  Transaction t;
  t = new(intf_lab);
  t.run();
end

endmodule: instr_register_test