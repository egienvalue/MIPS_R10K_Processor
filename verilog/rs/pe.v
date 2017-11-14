// EECS 470 - Winter 2009
//
// parametrized priority encoder (really just an encoder)
// parameter is output width
//

module pe #(parameter OUT_WIDTH=4)(gnt,enc);
	// synopsys template
        parameter IN_WIDTH=1<<OUT_WIDTH;

	input   [IN_WIDTH-1:0] gnt;

	output [OUT_WIDTH-1:0] enc;
        wor    [OUT_WIDTH-1:0] enc;
        
        genvar i,j;
        generate
          for(i=0;i<OUT_WIDTH;i=i+1)
          begin : foo
            for(j=1;j<IN_WIDTH;j=j+1)
            begin : bar
              if (j[i])
                assign enc[i] = gnt[j];
            end
          end
        endgenerate
endmodule
