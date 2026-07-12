`timescale 1ns/1ps

`include "top.v"

module tb_i2c_top;

reg clk;
reg rst;
reg newd;
reg op;
reg [6:0] addr;
reg [7:0] din;

wire [7:0] dout;
wire busy;
wire ack_err;
wire done;

integer pass;
integer fail;

i2c_top DUT(
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

//////////////////////////////////////////////////
// Clock
//////////////////////////////////////////////////

initial
begin
    clk = 0;
    forever #12.5 clk = ~clk;
end

//////////////////////////////////////////////////
// Write Task
//////////////////////////////////////////////////

task write_transaction;

input [6:0] address;
input [7:0] data;

begin

    wait(busy==0);

    @(posedge clk);
    addr = address;
    din  = data;
    op   = 0;
    newd = 1;

    @(posedge clk);
    newd = 0;

    wait(done);

    if(ack_err==0)
    begin
        pass = pass + 1;
        $display("[%0t] WRITE PASS Addr=%h Data=%h",$time,address,data);
    end
    else
    begin
        fail = fail + 1;
        $display("[%0t] WRITE FAIL",$time);
    end

    @(posedge clk);

end
endtask

//////////////////////////////////////////////////
// Read Task
//////////////////////////////////////////////////

task read_transaction;

input [6:0] address;
input [7:0] expected;

begin

    wait(busy==0);

    @(posedge clk);

    addr = address;
    op   = 1;
    newd = 1;

    @(posedge clk);
    newd = 0;

    wait(done);

    if((dout==expected)&&(ack_err==0))
    begin
        pass = pass + 1;
        $display("[%0t] READ PASS Addr=%h Data=%h",$time,address,dout);
    end
    else
    begin
        fail = fail + 1;
        $display("[%0t] READ FAIL Addr=%h Expected=%h Got=%h",
                $time,address,expected,dout);
    end

    @(posedge clk);

end
endtask

//////////////////////////////////////////////////
// Test Sequence
//////////////////////////////////////////////////

initial
begin

    $dumpfile("dump.vcd");
    $dumpvars(0,tb_i2c_top);

    pass = 0;
    fail = 0;

    rst  = 1;
    newd = 0;
    op   = 0;
    addr = 0;
    din  = 0;

    #200;
    rst = 0;

    //////////////////////////////////////////////////
    // TEST-1
    //////////////////////////////////////////////////

    $display("\nTEST-1 : Single Write/Read");

    write_transaction(7'h12,8'hA5);
    read_transaction (7'h12,8'hA5);

    //////////////////////////////////////////////////
    // TEST-2
    //////////////////////////////////////////////////

    $display("\nTEST-2 : Multiple Writes");

    write_transaction(7'h01,8'h11);
    write_transaction(7'h02,8'h22);
    write_transaction(7'h03,8'h33);
    write_transaction(7'h04,8'h44);

    //////////////////////////////////////////////////
    // TEST-3
    //////////////////////////////////////////////////

    $display("\nTEST-3 : Multiple Reads");

    read_transaction(7'h01,8'h11);
    read_transaction(7'h02,8'h22);
    read_transaction(7'h03,8'h33);
    read_transaction(7'h04,8'h44);

    //////////////////////////////////////////////////
    // TEST-4
    //////////////////////////////////////////////////

    $display("\nTEST-4 : Read Default Memory");

    read_transaction(7'h20,8'h20);

    //////////////////////////////////////////////////
    // TEST-5
    //////////////////////////////////////////////////

    $display("\nTEST-5 : Consecutive Transactions");

    write_transaction(7'h30,8'hAA);
    read_transaction (7'h30,8'hAA);

    write_transaction(7'h31,8'hBB);
    read_transaction (7'h31,8'hBB);

    write_transaction(7'h32,8'hCC);
    read_transaction (7'h32,8'hCC);

    //////////////////////////////////////////////////
    // TEST-6
    //////////////////////////////////////////////////

    $display("\nTEST-6 : Overwrite Same Address");

    write_transaction(7'h40,8'h55);
    read_transaction (7'h40,8'h55);

    write_transaction(7'h40,8'h99);
    read_transaction (7'h40,8'h99);

    //////////////////////////////////////////////////
    // TEST-7
    //////////////////////////////////////////////////

    $display("\nTEST-7 : Back-to-Back Writes");

    write_transaction(7'h50,8'h01);
    write_transaction(7'h51,8'h02);
    write_transaction(7'h52,8'h03);
    write_transaction(7'h53,8'h04);

    //////////////////////////////////////////////////
    // TEST-8
    //////////////////////////////////////////////////

    $display("\nTEST-8 : Reset");

    rst = 1;
    #100;
    rst = 0;

    #1000;

    $display("\n==================================");
    $display("PASS = %0d",pass);
    $display("FAIL = %0d",fail);
    $display("==================================");

    $finish;

end

//////////////////////////////////////////////////

// initial
// begin
//     $monitor("T=%0t busy=%b done=%b ack_err=%b op=%b addr=%h din=%h dout=%h",
//              $time,busy,done,ack_err,op,addr,din,dout);
// end

endmodule
