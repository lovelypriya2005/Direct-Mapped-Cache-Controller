module dirty_bit_array #(
    parameter LINES = 16
)(
    input clk,
    input write_en,
    input [$clog2(LINES)-1:0] index,
    input dirty_in,
    output dirty_out
);
reg dirty_mem [0:LINES-1];
integer i;

initial begin
    for(i = 0; i < LINES; i = i + 1)
        dirty_mem[i] = 1'b0;
end
always @(posedge clk)
begin
    if(write_en)
        dirty_mem[index] <= dirty_in;
end
assign dirty_out = dirty_mem[index];
endmodule
