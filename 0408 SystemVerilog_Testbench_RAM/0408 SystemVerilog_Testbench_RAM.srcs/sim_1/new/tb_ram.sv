`timescale 1ns / 1ps
// tb_ram.sv

// bit는 0과 1만 가진다 -> 2 state
// input/output 선언이 없다. 케이블 묶음만 가지고 있음.
// 어디에 넣느냐에 따라 input/output이 정해질것.
interface ram_intf (
    input bit clk
);
    logic [4:0] addr;
    logic [7:0] wData;
    logic       we;
    logic [7:0] rData;

    //시뮬레이션 클락 후 딜레이를 조금씩 주기 위한 기능
    clocking cb @(posedge clk); // test bench 기준으로 방향을 정한다.
        default input #1 output #1;
        output addr, wData, we;
        input rData;
    endclocking
endinterface  //ram_intf

// transaction 클래스: 하나의 동작 단위를 나타내는 트랜잭션
class transaction;
    rand logic [4:0] addr;
    rand logic [7:0] wData;
    rand logic       we;
    logic      [7:0] rData;
    // 트랜잭션 내용을 출력하는 task
    task display(string name);
        $display("[%S] addr=%h, wData=%h, we=%d, rData=%h", name, addr, wData,
                 we, rData);
    endtask
endclass  //transaction

// generator 클래스: 테스트할 트랜잭션을 생성하는 모듈
class generator;
    mailbox #(transaction) GenToDrv_mbox;  // 드라이버에게 트랜잭션을 전달할 mailbox
    // 생성자: 외부에서 mailbox를 받아 초기화
    function new(mailbox#(transaction) GenToDrv_mbox);
        this.GenToDrv_mbox = GenToDrv_mbox;
    endfunction  //new()

    task run(int repeat_counter);
        transaction ram_tr;
        repeat (repeat_counter) begin
            ram_tr = new();
            if (!ram_tr.randomize()) $error("Randomization failed!!!");
            ram_tr.display("GEN");
            GenToDrv_mbox.put(ram_tr);
            #20;
        end
    endtask  //
endclass  //generator

class driver;
    mailbox #(transaction) GenToDrv_mbox;
    virtual ram_intf ram_if;

    function new(mailbox#(transaction) GenToDrv_mbox, virtual ram_intf ram_if);
        this.GenToDrv_mbox = GenToDrv_mbox;
        this.ram_if = ram_if;
    endfunction  //new()

    task run();
        transaction ram_tr;
        forever begin
            @(ram_if.cb);
            GenToDrv_mbox.get(ram_tr);
            //모니터와 방향이 반대
            ram_if.cb.addr  <= ram_tr.addr;
            ram_if.cb.wData <= ram_tr.wData;
            ram_if.cb.we    <= ram_tr.we;
            ram_tr.display("DRV");
            //@(posedge ram_if.cb.clk);  // 저장을 기다린다
            @(ram_if.cb);
            //#1; 
            ram_if.cb.we <= 1'b0;
        end
    endtask  //

endclass  //driver

class monitor;
    mailbox #(transaction) MonToSCB_mbox;
    virtual ram_intf ram_if;

    function new(mailbox#(transaction) MonToSCB_mbox, virtual ram_intf ram_if);
        this.MonToSCB_mbox = MonToSCB_mbox;
        this.ram_if = ram_if;
    endfunction  //new()

    task run();
        transaction ram_tr;
        forever begin
            @(posedge ram_if.clk);
            ram_tr       = new();
            //드라이버와와 방향이 반대
            ram_tr.addr  = ram_if.addr;
            ram_tr.wData = ram_if.wData;
            ram_tr.we    = ram_if.we;
            ram_tr.rData = ram_if.rData;
            ram_tr.display("MON");
            MonToSCB_mbox.put(ram_tr);
        end
    endtask  //
endclass  //monitor

class scoreboard;
    mailbox #(transaction) MonToSCB_mbox;

    logic [7:0] ref_model[0:2<<5-1];

    function new(mailbox#(transaction) MonToSCB_mbox);
        this.MonToSCB_mbox = MonToSCB_mbox;
        foreach (ref_model[i]) ref_model[i] = 0;
    endfunction  //new()

    task run();
        transaction ram_tr;
        forever begin
            MonToSCB_mbox.get(ram_tr);
            ram_tr.display("SCB");
            if (ram_tr.we) begin
                ref_model[ram_tr.addr] = ram_tr.wData;
            end else begin
                if (ref_model[ram_tr.addr] === ram_tr.rData) begin
                    $display("PASS!! Matched Data! ref_model: %h == rData: %h",
                             ref_model[ram_tr.addr], ram_tr.rData);
                end else begin
                    $display(
                        "FAIL!! Dismatched Data! ref_model: %h == rData: %h",
                        ref_model[ram_tr.addr], ram_tr.rData);
                end
            end
        end
    endtask  //
endclass  //scoreboard

class envirnment;
    mailbox #(transaction) GenToDrv_mbox;
    mailbox #(transaction) MonToSCB_mbox;
    generator              ram_gen;
    driver                 ram_drv;
    monitor                ram_mon;
    scoreboard             ram_scb;

    function new(virtual ram_intf ram_if);
        GenToDrv_mbox = new();
        MonToSCB_mbox = new();
        ram_gen = new(GenToDrv_mbox);
        ram_drv = new(GenToDrv_mbox, ram_if);
        ram_mon = new(MonToSCB_mbox, ram_if);
        ram_scb = new(MonToSCB_mbox);
    endfunction  //new()

    task run(int count);
        fork
            ram_gen.run(count);
            ram_drv.run();
            ram_mon.run();
            ram_scb.run();
        join_any
        #50;
        $finish;
    endtask  //
endclass  //envirnment

// 테스트벤치 모듈: tb_ram
module tb_ram ();
    bit clk;

    envirnment env;
    ram_intf ram_if (clk);

    ram dut (.intf(ram_if));

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        env = new(ram_if);
        env.run(10);
        #50;
        $finish;
    end

endmodule
