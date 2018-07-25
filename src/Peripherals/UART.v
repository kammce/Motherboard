`define NONE       0
`define EVEN       1
`define ODD        2
`define START_SIZE 1
`define START_BIT  1'b0
`define STOP_BIT   1'b1
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 
// Design Name:
// Module Name: UART
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

module UART #(
        parameter BAUD_RATE = 9600,             // 9600 Baud Rate
        parameter CLOCK_HZ  = 100 * (10 ** 6),  // Assume 100MHz Clock,
        parameter DATA_SIZE = 8,                // 5-8 Data Size
        parameter PARITY    = `NONE,            // No Parity, Even Parity, Odd Parity
        parameter STOP_SIZE = 1,                // Stop Size 1-2 Bits
        parameter TX_DEPTH  = 8,                // Tx Fifo Depth
        parameter RX_DEPTH  = 8                 // Rx Fifo Depth
    ) (
        input  wire                 clk,        // Input Clock
        input  wire                 rst,        // Reset
        input  wire                 cs,         // Chip Select
        input  wire                 we,         // Write Enable
        input  wire                 oe,         // Output Enable
        inout  wire [DATA_SIZE-1:0] data,       // 5-8 bit Data (Parallel)
        input  wire                 rx,         // Receive Bit (Serial)
        output wire                 tx,         // Transmit Bit (Serial)        
        output wire                 tx_full,    // Tx Fifo Full Flag
        output wire                 tx_empty,   // Tx Fifo Empty Flag
        output wire                 rx_full,    // Rx Fifo Full Flag
        output wire                 rx_empty    // Rx Fifo Empty Flag
    );
    // ==================================
    //// Wires
    // ==================================
    wire [DATA_SIZE-1:0] tx_data;
    wire [DATA_SIZE-1:0] rx_data;

    wire [DATA_SIZE-1:0] tx_out;
    wire [DATA_SIZE-1:0] rx_in;
    wire                 tx_ready;  // Ready Flag

    wire                 rx_done;   // Done Flag
    wire                 rx_error;  // Error Flag
    // ==================================
    //// Wire Assignments
    // ==================================
    assign data = (cs && oe && !we) ? rx_data : {(DATA_SIZE){1'bz}};
    assign tx_data = data;
    // ==================================
    //// Modules
    // ==================================
    FIFO # (
            .LENGTH     (TX_DEPTH),
            .WIDTH      (DATA_SIZE)
        ) TX_FIFO (
            .clk        (~clk),
            .rst        (rst),
            .wr_cs      (cs),
            .wr_en      (we),
            .rd_cs      (tx_ready),
            .rd_en      (tx_ready),
            .in         (tx_data),
            .full       (tx_full),
            .empty      (tx_empty),
            .out        (tx_out)
        );

    UART_TX #(
            .BAUD_RATE  (BAUD_RATE),
            .CLOCK_HZ   (CLOCK_HZ),
            .DATA_SIZE  (DATA_SIZE),
            .PARITY     (PARITY),
            .STOP_SIZE  (STOP_SIZE)
        ) TX (
            .clk        (clk),
            .rst        (rst),
            .start      (~tx_empty),
            .data       (tx_out),
            .tx         (tx),
            .ready      (tx_ready)
        );

    UART_RX #(
            .BAUD_RATE  (BAUD_RATE),
            .CLOCK_HZ   (CLOCK_HZ),
            .DATA_SIZE  (DATA_SIZE),
            .PARITY     (PARITY),
            .STOP_SIZE  (STOP_SIZE)
        ) RX (
            .clk        (clk),
            .rst        (rst),
            .rx         (rx),
            .data       (rx_in),
            .done       (rx_done),
            .error      (rx_error)
        );

    FIFO # (
            .LENGTH     (RX_DEPTH),
            .WIDTH      (DATA_SIZE)
        ) RX_FIFO (
            .clk        (~clk),
            .rst        (rst),
            .wr_cs      (rx_done),
            .wr_en      (rx_done),
            .rd_cs      (cs),
            .rd_en      (!we),
            .in         (rx_in),
            .full       (rx_full),
            .empty      (rx_empty),
            .out        (rx_data)
        );

endmodule

module UART_TX #(
        parameter BAUD_RATE = 9600,             // 9600 Baud Rate
        parameter CLOCK_HZ  = 100 * (10 ** 6),  // Assume 100MHz Clock,
        parameter DATA_SIZE = 8,                // Data Size 5-8 Bits
        parameter PARITY    = `NONE,            // Parity: None/Even/Odd
        parameter STOP_SIZE = 1                 // Stop Size: 1-2
    ) (
        input  wire                 clk,       // Input Clock
        input  wire                 rst,       // Reset
        input  wire                 start,     // Start Control Signal
        input  wire [DATA_SIZE-1:0] data,      // 5-8 bit Data (Parallel)
        output wire                 tx,        // Transmit Bit (Serial)
        output wire                 ready      // Ready Flag
    );
    // ==================================
    //// Internal Parameter Field
    // ==================================
    parameter IDLE     = 2'd0,
              TX_CNT   = 2'd1,
              TRANSMIT = 2'd2;

    parameter MAX_COUNT   = CLOCK_HZ / BAUD_RATE; // Clock Divider
    parameter COUNT_WIDTH = $clog2(MAX_COUNT);    // Width

    parameter PARITY_SIZE = (PARITY == `NONE) ? 1'b0 : 1'b1;
    parameter TX_SIZE     = `START_SIZE + DATA_SIZE + PARITY_SIZE + STOP_SIZE;
    parameter TX_WIDTH    = $clog2(TX_SIZE);
    // ==================================
    //// Registers
    // ==================================
    reg [1:0] NS = IDLE;
    reg [1:0] CS = IDLE;
    reg [COUNT_WIDTH-1:0] count;        // Internal Clock Frequency
    reg [TX_WIDTH-1:0]    tx_count;     // Number of Bits Sent
    reg [TX_SIZE-1:0]     tx_bus;       // 1 Start Bit, 5-8 Stop Bits, None/Even/Odd Parity Bit, 1-2 Stop Bits
    // ==================================
    //// Wires
    // ==================================
    wire PARITY_BIT;
    // ==================================
    //// Wire Assignments
    // ==================================
    assign PARITY_BIT = (PARITY == `EVEN) ? (^data) : ~(^data);
    assign tx    = (CS != IDLE) ? tx_bus[0] : 1'b1;
    assign ready = (CS == IDLE) ? 1'b1 : 1'b0;
    // ==================================
    //// Behavioral Block
    // ==================================
    always @(posedge clk, posedge rst) begin
        if(rst) CS <= IDLE;
        else    CS <= NS;
    end

    always @ (CS, start, count, tx_count) begin
        case (CS)
            IDLE:     NS = (start == 1'b1) ? TX_CNT : IDLE;
            TX_CNT:   NS = (count == MAX_COUNT-1) ? TRANSMIT : TX_CNT;
            TRANSMIT: NS = (tx_count == TX_SIZE-1) ? IDLE : TX_CNT;
        endcase
    end

    always @ (posedge clk) begin
        case (CS)
            IDLE: begin
                tx_bus    <= (PARITY == `NONE) ? {{STOP_SIZE{`STOP_BIT}}, data, `START_BIT} 
                                               : {{STOP_SIZE{`STOP_BIT}}, PARITY_BIT, data, `START_BIT};
                count     <= {COUNT_WIDTH{1'b0}};
                tx_count  <= {TX_WIDTH{1'b0}};
            end
            TX_CNT: begin
                count <= count + 1;
            end
            TRANSMIT: begin
                tx_bus   <= tx_bus >> 1;
                tx_count <= tx_count + 1;
                count    <= {COUNT_WIDTH{1'b0}};
            end
        endcase
    end

endmodule

module UART_RX #(
        parameter BAUD_RATE = 9600,             // 9600 Baud Rate
        parameter CLOCK_HZ  = 100 * (10 ** 6),  // Assume 100MHz Clock,
        parameter DATA_SIZE = 8,                // Data Size 5-8 Bits
        parameter PARITY    = `NONE,            // Parity: NONE/EVEN/ODD
        parameter STOP_SIZE = 1                 // Stop Bit: 1-2
    ) (
        input  wire                 clk,        // Input Clock
        input  wire                 rst,
        input  wire                 rx,         // Receive Bit (Serial)
        output wire [DATA_SIZE-1:0] data,       // 5-8 bit Data (Parallel)
        output reg                  done,       // Done Flag
        output reg                  error       // Error Flag
    );
    // ==================================
    //// Internal Parameter Field
    // ==================================
    parameter IDLE     = 3'd0,
              START    = 3'd1,
              RX_CNT   = 3'd2,
              RECEIVE  = 3'd3,
              DONE     = 3'd4;

    parameter MAX_COUNT   = CLOCK_HZ / BAUD_RATE; // Clock Divider
    parameter COUNT_WIDTH = $clog2(MAX_COUNT);    // Width

    parameter PARITY_SIZE = (PARITY == `NONE) ? 1'b0 : 1'b1;
    parameter RX_SIZE     = `START_SIZE + DATA_SIZE + PARITY_SIZE + STOP_SIZE;
    parameter RX_WIDTH    = $clog2(RX_SIZE);
    // ==================================
    //// Registers
    // ==================================
    reg [2:0] NS = IDLE;
    reg [2:0] CS = IDLE;

    reg [COUNT_WIDTH-1:0] count;        // Internal Clock Frequency
    reg [RX_WIDTH-1:0]    rx_count;     // Number of Bits Sent
    reg [RX_SIZE-1:0]     rx_bus;       // 1 Start Bit, 5-8 Stop Bits, None/Even/Odd Parity Bit, 1-2 Stop Bits
    // ==================================
    //// Wires
    // ==================================
    wire PARITY_BIT;   // Parity of Data
    wire rx_parity;    // Received Parity Bit
    // ==================================
    //// Wire Assignments
    // ==================================
    assign PARITY_BIT = (PARITY == `EVEN) ? (^data) : ~(^data);   // Parity of Data
    assign rx_parity  = rx_bus[RX_SIZE-STOP_SIZE-1];             // Received Parity Bit
    assign data  = rx_bus[DATA_SIZE:1];
    // ==================================
    //// Behavioral Block
    // ==================================
    always @(posedge clk, posedge rst) begin
        if(rst) CS <= IDLE;
        else    CS <= NS;
    end

    always @ (CS, rx, count, rx_count) begin
        case (CS)
            IDLE:    NS = (rx == 1'b0) ? START : IDLE;
            START:   NS = (count == (MAX_COUNT/2)-1) ? (rx == 1'b0) ? RECEIVE : IDLE : START;
            RX_CNT:  NS = (count == MAX_COUNT-1) ? RECEIVE : RX_CNT;
            RECEIVE: NS = (rx_count == RX_SIZE-1) ? DONE : RX_CNT;
            DONE:    NS = IDLE;
        endcase
    end

    always @ (posedge clk) begin
        case (CS)
            IDLE: begin
                rx_bus    <= {RX_SIZE{1'b0}};
                count     <= {COUNT_WIDTH{1'b0}};
                rx_count  <= {RX_WIDTH{1'b0}};
                done      <= 1'b0;
                error     <= 1'b0;
            end
            START: begin
                count <= count + 1;
            end
            RX_CNT: begin
                count <= count + 1;
            end
            RECEIVE: begin
                rx_bus    <= {rx, rx_bus[RX_SIZE-1:1]};
                rx_count  <= rx_count + 1;
                count     <= {COUNT_WIDTH{1'b0}};
            end
            DONE: begin
                if (PARITY == `NONE) done <= 1'b1;
                else begin
                    error <= (PARITY_BIT != rx_parity) ? 1'b1 : 1'b0;
                    done  <= (PARITY_BIT == rx_parity) ? 1'b1 : 1'b0;
                end                
            end
        endcase
    end

endmodule
