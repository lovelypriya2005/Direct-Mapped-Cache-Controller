`timescale 1ns / 1ps
module cache_top_tb;
reg clk;
reg rst;
reg cpu_read;
reg cpu_write;
reg [31:0] cpu_address;
reg [127:0] cpu_write_data;
wire cpu_ready;
wire cache_hit;
wire [127:0] cpu_data;
cache_top dut(
    .clk(clk),
    .rst(rst),
    .cpu_read(cpu_read),
    .cpu_write(cpu_write),
    .cpu_address(cpu_address),
    .cpu_write_data(cpu_write_data),
    .cpu_ready(cpu_ready),
    .cache_hit(cache_hit),
    .cpu_data(cpu_data)
);
always #5 clk = ~clk;
initial
begin
    clk = 0;
    rst = 1;
    cpu_read = 0;
    cpu_write = 0;
    cpu_address = 0;
    cpu_write_data = 0;
    #20;
    rst = 0;
    // Test 1 : Read Mis
    $display("--------------------------------");
    $display("TEST 1 : READ MISS at address %h", cpu_address);
    $display("--------------------------------");
    cpu_address = 32'h00000010;
    cpu_read = 1;
    #10;
    cpu_read = 0;
    wait(cpu_ready);
    #20;
    // Test 2 : Read Hit

    $display("--------------------------------");
    $display("TEST 2 : READ HIT");
    $display("--------------------------------");
    cpu_address = 32'h00000010;
    cpu_read = 1;
    #10;
    cpu_read = 0;
    wait(cpu_ready);
    #20;// Test 3 : Write H
    $display("--------------------------------");
    $display("TEST 3 : WRITE HIT");
    $display("--------------------------------");
    cpu_address = 32'h00000010;
    cpu_write_data = 128'hAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA;
    cpu_write = 1;
    #10;
    cpu_write = 0;
    wait(cpu_ready);
    #20;
    $display("--------------------------------");
    $display("TEST 4 : WRITE MISS");
    $display("--------------------------------");
    cpu_address = 32'h00000040;
    cpu_write_data = 128'hBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB;
    cpu_write = 1;
    #10;
    cpu_write = 0;
    wait(cpu_ready);
    #20;
    // Test 5 : Dirty Block Replacemen
    $display("--------------------------------");
    $display("TEST 5 : DIRTY REPLACEMENT");
    $display("--------------------------------");
    cpu_address = 32'h00000110;
    cpu_read = 1;
    #10;
    cpu_read = 0;
    wait(cpu_ready);
    #50;
    $display("--------------------------------");
    $display("ALL TESTS COMPLETED");
    $display("--------------------------------");
    $finish;
end
endmodule