
`timescale 1ns/1ps

`include "top.v"

module tb_i2c;

    reg         clk;
    reg         rst;
    reg         newd;
    reg         op;          // 0 = Write, 1 = Read
    reg  [6:0]  addr;
    reg  [7:0]  din;

    wire [7:0]  dout;
    wire        busy;
    wire        ack_err;
    wire        done;

    //---------------------------------------------------------
    // DUT
    //---------------------------------------------------------
    i2c_top dut (
        .clk(clk),
        .rst(rst),
        .newd(newd),
        .op(op),
        .addr(addr),
        .din(din),
        .dout(dout),
        .busy(busy),
        .ack_err(ack_err),
        .done(done)
    );

    //---------------------------------------------------------
    // Clock Generation (40 MHz -> 25 ns period)
    //---------------------------------------------------------
    initial begin
        clk = 0;
        forever #12.5 clk = ~clk;
    end

    //---------------------------------------------------------
    // Write Task
    //---------------------------------------------------------
    task i2c_write;
        input [6:0] address;
        input [7:0] data;

        begin
            @(posedge clk);
            addr = address;
            din  = data;
            op   = 0;
            newd = 1;

            @(posedge clk);
            newd = 0;

            wait(done);

            @(posedge clk);

            if(ack_err)
                $display("[%0t] WRITE FAILED", $time);
            else
                $display("[%0t] WRITE SUCCESS : Addr = %h Data = %h",
                        $time,address,data);
        end
    endtask

    //---------------------------------------------------------
    // Read Task
    //---------------------------------------------------------
    task i2c_read;
        input [6:0] address;

        begin
            @(posedge clk);
            addr = address;
            op   = 1;
            newd = 1;

            @(posedge clk);
            newd = 0;

            wait(done);

            @(posedge clk);

            if(ack_err)
                $display("[%0t] READ FAILED", $time);
            else
                $display("[%0t] READ SUCCESS : Addr = %h Data = %h",
                        $time,address,dout);
        end
    endtask

    //---------------------------------------------------------
    // Test Sequence
    //---------------------------------------------------------
    initial begin

        $dumpfile("dump.vcd");
        $dumpvars(0,tb_i2c);

        // Initialize
        rst  = 1;
        newd = 0;
        op   = 0;
        addr = 0;
        din  = 0;

        // Reset
        #200;
        rst = 0;

        #200;

        //-----------------------------------------------------
        // WRITE
        //-----------------------------------------------------
        i2c_write(7'h12,8'hA5);

        #5000;

        //-----------------------------------------------------
        // READ
        //-----------------------------------------------------
        i2c_read(7'h12);

        #10000;

        $display("--------------------------------------");
        $display("Simulation Finished");
        $display("--------------------------------------");

        $finish;
    end

    //---------------------------------------------------------
    // Monitor
    //---------------------------------------------------------
    initial begin
        $monitor("T=%0t rst=%b newd=%b busy=%b done=%b ack_err=%b op=%b addr=%h din=%h dout=%h",
                 $time,rst,newd,busy,done,ack_err,op,addr,din,dout);
    end

endmodule