// tb.v
module tb;

  reg  [3:0] t_a, t_b;
  reg        t_op;
  wire [3:0] t_result;
  reg  [3:0] expected;
  integer    i, j, k;
  integer    errors, total;

  alu DUT (
    .a      (t_a),
    .b      (t_b),
    .op     (t_op),
    .result (t_result)
  );

  // Waveform dump configuration
  string vcd_file;
  initial begin
    if ($value$plusargs("vcd=%s", vcd_file)) begin
      $dumpfile(vcd_file);
      $dumpvars(0, DUT);
    end
  end

  // Compares the ALU result with the correct answer
  task check;
    begin
      if (t_op == 0)
        expected = t_a + t_b;
      else
        expected = t_a - t_b;
      total = total + 1;
      if (t_result !== expected) begin
        errors = errors + 1;
        if (errors <= 8)
          $display("FAIL at time %0t: op=%b a=%0d b=%0d  got %0d  expected %0d",
                   $time, t_op, t_a, t_b, t_result, expected);
      end
    end
  endtask

  initial begin
    errors = 0;
    total  = 0;
    t_a = 0; t_b = 0; t_op = 0;
    #5;

    // Test 1: same operands held fixed while op switches 0 -> 1
    for (i = 0; i < 16; i = i + 1) begin
      for (j = 0; j < 16; j = j + 1) begin
        t_a = i; t_b = j;
        t_op = 0;
        #5;
        check;
        t_op = 1;
        #5;
        check;
      end
    end

    // Test 2: op held fixed (add, then sub) while the operands change
    for (k = 0; k < 2; k = k + 1) begin
      t_op = k;
      for (i = 0; i < 16; i = i + 1) begin
        for (j = 0; j < 16; j = j + 1) begin
          t_a = i; t_b = j;
          #5;
          check;
        end
      end
    end

    $display("%0d out of %0d checks passed", total - errors, total);
    $finish;
  end

endmodule