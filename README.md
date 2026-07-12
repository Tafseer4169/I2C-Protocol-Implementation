# I2C Master-Slave Communication in Verilog

A Verilog implementation of the **Inter-Integrated Circuit (I²C)** protocol featuring a single **I²C Master** communicating with a single **I²C Slave** over a two-wire serial interface (`SCL` and `SDA`). The design supports both **read** and **write** operations using a finite state machine (FSM) and follows the standard I²C transaction sequence.

---

## 📌 Features

- Implements I²C Master and I²C Slave in Verilog HDL
- Supports **7-bit slave addressing**
- Supports **Read** and **Write** transactions
- Bidirectional **SDA** line using tri-state logic
- Open-drain communication model
- Generates **START** and **STOP** conditions
- ACK/NACK handling
- Parameterized clock generation
- Simple memory inside slave for data storage
- Simulation-ready design

---

## 📂 Project Structure

```
├── i2c_master.v      // I2C Master Controller
├── i2c_slave.v       // I2C Slave Controller
├── i2c_top.v         // Top module connecting master and slave
├── tb_i2c.v          // Testbench
└── README.md
```

---

## 🏗 Design Overview

### I²C Master

The master controls the complete communication on the I²C bus.

Functions performed:

- Generates SCL clock
- Generates START condition
- Sends slave address
- Performs Read/Write operation
- Receives ACK from slave
- Generates STOP condition

### Master FSM

```
Idle
   │
   ▼
Start
   │
   ▼
Write Address
   │
   ▼
Receive ACK
   │
 ┌─┴────────────┐
 │              │
 ▼              ▼
Write Data    Read Data
 │              │
 ▼              ▼
Receive ACK   Master NACK
      │
      ▼
     Stop
```

---

### I²C Slave

The slave monitors the I²C bus and responds to the master's requests.

Functions performed:

- Detects START condition
- Receives slave address
- Sends ACK
- Receives data from master
- Sends data during read operation
- Detects STOP condition
- Stores received data in internal memory

---

## 🧠 Internal Memory

The slave contains a simple internal memory:

- Memory depth : **128 bytes**
- Data width : **8 bits**

During reset:

```verilog
mem[i] = i;
```

Therefore,

| Address | Initial Data |
|----------|--------------|
|0x00|0x00|
|0x01|0x01|
|...|...|
|0x20|0x20|
|0x7F|0x7F|

---

## ⚙ Parameters

| Parameter | Value |
|-----------|------:|
|System Clock|40 MHz|
|I²C Clock|100 kHz|
|Address Width|7-bit|
|Data Width|8-bit|

---

## Interface

### Master

| Signal | Direction | Description |
|----------|-----------|-------------|
|clk|Input|System clock|
|rst|Input|Active-high reset|
|newd|Input|Start transaction|
|addr|Input|7-bit slave address|
|op|Input|0 = Write, 1 = Read|
|din|Input|Data to write|
|dout|Output|Data received|
|busy|Output|Master busy flag|
|done|Output|Transaction completed|
|ack_err|Output|ACK error flag|
|scl|Output|Serial Clock|
|sda|Inout|Serial Data|

---

## Slave Interface

| Signal | Direction | Description |
|----------|-----------|-------------|
|clk|Input|System clock|
|rst|Input|Reset|
|scl|Input|Serial Clock|
|sda|Inout|Serial Data|
|ack_err|Output|ACK status|
|done|Output|Transaction completed|

---

# I²C Write Transaction

```
Master
   │
START
   │
Address + Write Bit
   │
ACK
   │
Write Data
   │
ACK
   │
STOP
```

---

# I²C Read Transaction

```
Master
   │
START
   │
Address + Read Bit
   │
ACK
   │
Slave sends Data
   │
Master sends NACK
   │
STOP
```

---

## Simulation

### Test Cases

- Reset operation
- Single write transaction
- Single read transaction
- Multiple write transactions
- Multiple read transactions
- Consecutive write/read operations
- Memory overwrite verification
- Read from default initialized memory
- Reset functionality

---

## Example

### Write

```
Address : 0x12
Data    : 0xA5
```

Expected:

```
ACK Received
Write Successful
```

---

### Read

```
Address : 0x12
```

Expected:

```
Data = 0xA5
```

---

## Simulation Result

Typical output:

```
WRITE PASS
READ PASS

Expected : A5
Received : A5
```

---

## Future Improvements

- Multiple slave support
- Configurable slave address
- Clock stretching
- Repeated START condition
- Arbitration support
- Multi-master implementation
- 10-bit addressing
- Burst read/write support
- Randomized verification environment using SystemVerilog/UVM
- Functional coverage and assertions

---

## Tools Used

- Verilog HDL
- Vivado Simulator
- EDA Playground

---

## Applications

- EEPROM Communication
- Temperature Sensors
- RTC Modules
- OLED Displays
- ADC/DAC Interfaces
- Embedded Systems
- FPGA-based Peripheral Communication

---

## Limitations

- Single master implementation
- Single slave implementation
- Fixed 7-bit addressing
- No repeated START support
- No arbitration logic
- Slave currently acknowledges every received address
- No timeout mechanism

---

## Author

**Tafseer Ahamad**

B.Tech, Electronics and Communication Engineering  
Motilal Nehru National Institute of Technology (MNNIT) Allahabad

---

## License

This project is intended for educational and learning purposes.
