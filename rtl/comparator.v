module comparator #(parameter tag_width=24)(
    input [tag_width-1:0] requested_tag,
    input [tag_width-1:0] stored_tag,
    output tag_match
);
assign tag_match = (requested_tag == stored_tag) ? 1'b1 : 1'b0;
endmodule

