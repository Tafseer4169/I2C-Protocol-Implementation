`timescale 1ns/1ns

module i2c_tb;
    
    reg clk;
    reg arst;
    reg [6:0] addr;
    reg [7:0] data_in;
    reg rw;
    reg enable;
    reg [7:0] expected_data;

    // tri1 provides implicit pull-up to 1'b1
    tri1 scl;
    tri1 sda;

    // Outputs from Master
    wire busy;
    wire [7:0] data_out;

    i2c_master master (
        .clk(clk),
        .arst(arst),
        .addr(addr),
        .data_in(data_in),
        .rw(rw),
        .enable(enable),
        .scl(scl),
        .sda(sda),
        .data_out(data_out),
        .busy(busy)
    );

    i2c_slave slave (
        .scl(scl),
        .sda(sda)
    );

    //100MHz
    always begin
        #5 clk = ~clk;
    end

    // Test Sequence
    initial begin
        // Initialize Signals
        clk = 0;
        arst = 1;
        addr = 0;
        data_in = 0;
        rw = 0;
        enable = 0;

        // Reset Pulse
        #2500;
        arst = 0;

        // Master WRITE
        addr = 7'b1010111;
        data_in = 8'b10110011;
        rw = 0;              // 0 = Write
        enable = 1;
        
        #2500;
        enable = 0;          // Clear enable pulse
        
        wait(!busy);         // Wait for write to complete
        #2500;

        //Master READ
        addr = 7'b1010111;
        rw = 1;              // 1 = Read
        enable = 1;
        expected_data = 8'b11011101;
        
        #2500;
        enable = 0;          // Clear enable pulse

        wait(!busy);         // Wait for read to complete
        #10;

        reg [7:0] expected_data;

initial begin
    // --- Transaction 2: Master READ ---
    addr = 7'b1010111;
    rw = 1;              // 1 = Read
    enable = 1;
    expected_data = 8'b11011101; // Data stored in slave (8'hDD)
    
    #2500;
    enable = 0;

    wait(!busy);         // Wait for transaction to finish
    #10;                 // Small delay for output stability

    if (data_out === expected_data) begin
        $display("[SUCCESS] Read Data Matches! Actual: (0x%h), Expected: (0x%h)",data_out,expected_data);
                 
    end 
    else begin
        $error("[FAIL] Data Mismatch! Actual: (0x%h), Expected: (0x%h)",data_out, expected_data);          
    end
    
    $finish;
end
        
endmodule
