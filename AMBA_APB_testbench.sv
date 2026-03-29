`timescale 1ns / 1ps


module AMBA_APB_tb;

  // DUT signals
  logic P_clk;
  logic P_rst;
  logic [31:0] P_addr;
  logic P_selx;
  logic P_enable;
  logic P_write;
  logic [31:0] P_wdata;

  logic P_ready;
  logic P_slverr;
  logic [31:0] P_rdata;

  // Instantiate DUT
  AMBA_APB dut (
    .P_clk(P_clk),
    .P_rst(P_rst),
    .P_addr(P_addr),
    .P_selx(P_selx),
    .P_enable(P_enable),
    .P_write(P_write),
    .P_wdata(P_wdata),
    .P_ready(P_ready),
    .P_slverr(P_slverr),
    .P_rdata(P_rdata)
  );

  // Clock generation
  always #5 P_clk = ~P_clk;

  // Task: Write Operation
  task apb_write(input [31:0] addr, input [31:0] data);
    begin
      @(posedge P_clk);
      P_selx   = 1;
      P_enable = 0;
      P_write  = 1;
      P_addr   = addr;
      P_wdata  = data;

      @(posedge P_clk);
      P_enable = 1;

      @(posedge P_clk);
      P_selx   = 0;
      P_enable = 0;
    end
  endtask

  // Task: Read Operation
  task apb_read(input [31:0] addr);
    begin
      @(posedge P_clk);
      P_selx   = 1;
      P_enable = 0;
      P_write  = 0;
      P_addr   = addr;

      @(posedge P_clk);
      P_enable = 1;

      @(posedge P_clk);
      $display("READ DATA from addr %0d = %0h", addr, P_rdata);

      P_selx   = 0;
      P_enable = 0;
    end
  endtask

  // Test sequence
  initial begin
    // Initialize
    P_clk = 0;
    P_rst = 1;
    P_selx = 0;
    P_enable = 0;
    P_write = 0;
    P_addr = 0;
    P_wdata = 0;

    // Reset
    #10 P_rst = 0;

    // Write transactions
    apb_write(5, 32'hA5A5A5A5);
    apb_write(10, 32'h12345678);

    // Read transactions
    apb_read(5);
    apb_read(10);

    // End simulation
    #20 $finish;
  end

endmodule
