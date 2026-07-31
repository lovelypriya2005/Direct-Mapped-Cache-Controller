module valid_bit_array #(
    parameter lines = 16
)(
    input clk,
    input write_en,
    input [$clog2(lines)-1:0] index,
    input valid_in,
    output valid_out
);

reg valid_mem [0:lines-1];

integer i;

initial begin
    for(i = 0; i < lines; i = i + 1)
        valid_mem[i] = 1'b0;
end

always @(posedge clk)
begin
    if(write_en)
        valid_mem[index] <= valid_in;
end

assign valid_out = valid_mem[index];

endmodule