module controller_fsm(
    input clk,
    input rst,
    input cpu_read,
    input cpu_write,
    input tag_match,
    input valid_out,
    input dirty_out,
    input mem_ready,
    output reg dirty_write,
    output reg cache_hit,
    output reg cpu_ready,
    output reg mem_write,
    output reg mem_read,
    output reg data_write,
    output reg tag_write,
    output reg valid_write
);
localparam IDLE         = 3'd0,
           CHECK_CACHE  = 3'd1,
           WRITE_HIT    = 3'd2,
           WRITE_BACK   = 3'd3,
           READ_MEMORY  = 3'd4,
           UPDATE_CACHE = 3'd5,
           COMPLETE     = 3'd6;

reg [2:0] current_state;
reg [2:0] next_state;
always @(posedge clk or posedge rst)
begin
    if(rst)
        current_state <= IDLE;
    else
        current_state <= next_state;
end

always @(*) begin

    next_state = current_state;

    case(current_state)

        IDLE:
        begin
            if(cpu_read || cpu_write)
                next_state = CHECK_CACHE;
            else
                next_state = IDLE;
        end

        CHECK_CACHE:
        begin
            if(cpu_read)
                next_state = COMPLETE;
            else if(cpu_write)
                next_state = WRITE_HIT;
            else
                next_state = IDLE;
                if(dirty_out)
                    next_state = WRITE_BACK;
                else
                    next_state = READ_MEMORY;
        end

        WRITE_HIT:
        begin
            next_state = COMPLETE;
        end

        WRITE_BACK:
        begin
            if(mem_ready)
                next_state = READ_MEMORY;
            else
                next_state = WRITE_BACK;
        end

        READ_MEMORY:
        begin
            if(mem_ready)
                next_state = UPDATE_CACHE;
            else
                next_state = READ_MEMORY;
        end

        UPDATE_CACHE:
        begin
            next_state = COMPLETE;
        end

        COMPLETE:
        begin
            next_state = IDLE;
        end

        default:
            next_state = IDLE;

    endcase

end

reg request_is_write;
always @(posedge clk or posedge rst)
begin
    if (rst)
        request_is_write <= 1'b0;

    else if (current_state == IDLE && (cpu_read || cpu_write))
        request_is_write <= cpu_write;
end

always @(*) begin

    cpu_ready   = 0;
    cache_hit   = 0;

    mem_read    = 0;
    mem_write   = 0;

    data_write  = 0;
    tag_write   = 0;
    valid_write = 0;
    dirty_write = 0;

    case(current_state)

        //-----------------------------------
        IDLE:
        begin
        end

        //-----------------------------------
        CHECK_CACHE:
        begin
            if(valid_out && tag_match)
                cache_hit = 1;
        end

        //-----------------------------------
        WRITE_HIT:
        begin
            cache_hit   = 1;
            data_write  = 1;
            dirty_write = 1;
            cpu_ready   = 1;
        end

        //-----------------------------------
        WRITE_BACK:
        begin
            mem_write = 1;
        end

        //-----------------------------------
        READ_MEMORY:
        begin
            mem_read = 1;
        end

        //-----------------------------------
        UPDATE_CACHE:
        begin
            data_write  = 1;
            tag_write   = 1;
            valid_write = 1;

            if(request_is_write)
                dirty_write = 1;
        end

        //-----------------------------------
        COMPLETE:
        begin
            cpu_ready = 1;

            if(!request_is_write)
                cache_hit = 1;
        end

    endcase

end
endmodule