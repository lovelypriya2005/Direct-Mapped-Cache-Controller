module cache_top(
    input clk,
    input rst,
    input cpu_read,
    input cpu_write, 
    input [31:0] cpu_address,
    input [127:0] cpu_write_data,
    output  cpu_ready,
    output  cache_hit,
    output  [127:0] cpu_data,
    output  mem_read
);
wire [23:0] tag;
wire [3:0] index;
wire [3:0] offset;
//array outputs
wire [127:0]cache_data;
wire [23:0]cache_tag;
wire valid_out;
//comparator outputs
wire tag_match;
//controller outputs
wire data_write;
wire tag_write;
wire valid_write;

// Dirty Bit signals
wire dirty_out;
wire dirty_write;
wire dirty_in;

wire [127:0] write_data;

wire mem_ready;
wire [127:0] mem_data;
wire [9:0] mem_address;

wire mem_write;

assign tag = cpu_address[31:8];
assign index = cpu_address[7:4];
assign offset = cpu_address[3:0];

assign mem_address = cpu_address[13:4];
assign write_data = cpu_write ? cpu_write_data : mem_data;
assign dirty_in   = cpu_write;

assign cpu_data = cache_data;

data_array #(
    .lines(16),
    .block_size(128)
) data_mem (
    .clk(clk),
    .write_en(data_write),
    .write_data(write_data),
    .index(index),
    .read_data(cache_data)
);
tag_array #(
    .lines(16),
    .tag_width(24)
) tag_mem (
    .clk(clk),
    .write_en(tag_write),
    .index(index),
    .write_tag(tag),
    .read_tag(cache_tag)
);
valid_bit_array #(
    .lines(16)
) valid_mem (
    .clk(clk),
    .write_en(valid_write),
    .index(index),
    .valid_in(1'b1),
    .valid_out(valid_out)
);
comparator #(
    .tag_width(24)
) comp (
    .requested_tag(tag),
    .stored_tag(cache_tag),
    .tag_match(tag_match)
);

main_memory memory(
    .clk(clk),
    .rst(rst),
    .read_en(mem_read),
    .write_en(mem_write),
    .address(mem_address),
    .write_data(cache_data),
    .read_data(mem_data),
    .ready(mem_ready)
);
controller_fsm controllerver2(
    .clk(clk),
    .rst(rst),
    .cpu_read(cpu_read),
    .cpu_write(cpu_write),
    .tag_match(tag_match),
    .valid_out(valid_out),
    .dirty_out(dirty_out),
    .mem_ready(mem_ready),
    .cpu_ready(cpu_ready),
    .cache_hit(cache_hit),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .data_write(data_write),
    .tag_write(tag_write),
    .valid_write(valid_write),
    .dirty_write(dirty_write)
);
dirty_bit_array #(
    .LINES(16)
) dirty_array (
    .clk(clk),
    .write_en(dirty_write),
    .index(index),
    .dirty_in(dirty_in),
    .dirty_out(dirty_out)
);

endmodule
