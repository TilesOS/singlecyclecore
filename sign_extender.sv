module sign_extender #(
    parameter int IN_WIDTH  = 12,
    parameter int OUT_WIDTH = 32
) (
    input  logic [IN_WIDTH-1:0]  in,
    output logic [OUT_WIDTH-1:0] out
);

    assign out = {{(OUT_WIDTH-IN_WIDTH){in[IN_WIDTH-1]}}, in};

endmodule
