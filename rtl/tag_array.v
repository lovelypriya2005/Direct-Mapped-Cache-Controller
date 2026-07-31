module tag_array#(parameter lines=16,parameter tag_width=24)(
    input clk,
    input write_en,
    input [$clog2(lines)-1:0] index,
    input [tag_width-1:0]write_tag,
    output [tag_width-1:0] read_tag
);

    reg [tag_width-1:0] tag_mem [0:lines-1];

    always @(posedge clk) begin
        if (write_en) begin
            tag_mem[index] <= write_tag;
        end
    end
    assign read_tag = tag_mem[index];
integer i;

initial begin
    for(i=0;i<lines;i=i+1)
        tag_mem[i]=0;
end
endmodule
