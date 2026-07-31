module main_memory #(
    parameter memory_latency = 3,
    parameter num_blocks = 1024,
    parameter block_size = 128
)(
    input clk,
    input rst,
    input read_en,
    input write_en,
    input [9:0] address,
    input [block_size-1:0] write_data,
    output reg [block_size-1:0] read_data,
    output reg ready
);
reg [block_size-1:0] memory [0:num_blocks-1];
reg [$clog2(memory_latency+1)-1:0] delay_counter;
reg busy;
reg operation;     // 0 = Read, 1 = Write
reg [9:0] saved_address;
reg [block_size-1:0] saved_write_data;
initial begin
    $readmemh("memorycache.mem", memory);
end
always @(posedge clk or posedge rst)
begin
    if(rst)
    begin
        ready <= 0;
        busy <= 0;
        delay_counter <= 0;
        read_data <= 0;
        saved_address <= 0;
        saved_write_data <= 0;
        operation <= 0;
    end
    else
    begin
        ready <= 0;
        if(!busy && (read_en || write_en))
        begin
            busy <= 1;
            delay_counter <= 0;
            saved_address <= address;
            saved_write_data <= write_data;
            operation <= write_en;
        end
        else if(busy)
        begin
            if(delay_counter == memory_latency-1)
            begin
                if(operation)
                begin
                    memory[saved_address] <= saved_write_data;
                end
                else
                begin
                    read_data <= memory[saved_address];
                end
                ready <= 1;
                busy <= 0;
            end
            else
            begin
                delay_counter <= delay_counter + 1;
            end
        end
    end
end
endmodule