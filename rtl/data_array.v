module data_array#(parameter lines=16,
                   parameter block_size=128
                   )(
    input  clk,
    input write_en,
    input [block_size-1:0] write_data,
    input [$clog2(lines)-1:0] index,
    output [block_size-1:0] read_data
);

    reg [block_size-1:0] memory [0:lines-1]; // lines x block_size-bit memory array

    // Write operation
    always @(posedge clk) begin
        if (write_en) begin
            memory[index] <= write_data;
        end
    end

    // Read operation
    assign read_data = memory[index];
integer i;

initial begin
    for(i=0;i<lines;i=i+1)
        memory[i]=0;
end
endmodule