// EECS 470 - Winter 2009
//
// Parametrized Priority Selector
// parameter is number of elements selecting between
//
// note: some configurations of verilog do not allow recursive instantiation
// in generate statements.  This file has been updated to generate the
// necessary tree structure via loops.
//

module ps #(parameter NUM_BITS = 8)(req, en, gnt, req_up);
	// synopsys template
  input  [NUM_BITS-1:0] req;
  input                 en;

  output [NUM_BITS-1:0] gnt;
  output                req_up;
        
  wire   [NUM_BITS-2:0] req_ups;
  wire   [NUM_BITS-2:0] enables;
        
  assign req_up = req_ups[NUM_BITS-2];
  assign enables[NUM_BITS-2] = en;
        
  genvar i,j;
  generate
    if ( NUM_BITS == 2 )
    begin
      ps2 single (.req(req),.en(en),.gnt(gnt),.req_up(req_up));
    end
    else
    begin
      for(i=0;i<NUM_BITS/2;i=i+1)
      begin : foo
        ps2 base ( .req(req[2*i+1:2*i]),
                   .en(enables[i]),
                   .gnt(gnt[2*i+1:2*i]),
                   .req_up(req_ups[i])
        );
      end

      for(j=NUM_BITS/2;j<=NUM_BITS-2;j=j+1)
      begin : bar
        ps2 top ( .req(req_ups[2*j-NUM_BITS+1:2*j-NUM_BITS]),
                  .en(enables[j]),
                  .gnt(enables[2*j-NUM_BITS+1:2*j-NUM_BITS]),
                  .req_up(req_ups[j])
        );
      end
    end
  endgenerate
endmodule

module ps2(req, en, gnt, req_up);

  input     [1:0] req;
  input           en;
  
  output    [1:0] gnt;
  output          req_up;
  
  assign gnt[1] = en & req[1] & !req[0];
  assign gnt[0] = en & req[0];
  
  assign req_up = req[1] | req[0];

endmodule

