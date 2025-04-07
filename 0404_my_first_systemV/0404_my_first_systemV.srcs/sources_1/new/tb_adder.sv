`timescale 1ns / 1ps

interface adder_intef;
    logic [7:0] a;
    logic [7:0] b;
    logic [7:0] sum;
    logic carry;
endinterface  //adder_intef

class transaction;
    rand bit [7:0] a;
    rand bit [7:0] b;
endclass  //transaction

class generator;
    transaction tr;
    mailbox #(transaction) gen2drv_mbox;

    function new(mailbox#(transaction) gen2drv_mbox);
        this.gen2drv_mbox = gen2drv_mbox;
    endfunction  //new()

    task run(int run_count);
        repeat (run_count) begin
            tr = new();  //tr생성
            tr.randomize();  //랜덤화
            gen2drv_mbox.put(tr);  //메일박스넣기
            #10;
        end
    endtask  //
endclass  //generator

class driver;
    transaction tr;
    //virtual: 같은 객체(클래스,인터페이스)를 가리키는 포인터 역할을 한다. 
    //하위객체에서 상위 객체의 멤버객체와 같은 객체(예를들어 인터페이스)를 멤버변수로 둬야할 때 사용한다.
    virtual adder_intef adder_if;
    mailbox #(transaction) gen2drv_mbox;

    function new(mailbox#(transaction) gen2drv_mbox,
                 virtual adder_intef adder_if);
        this.gen2drv_mbox = gen2drv_mbox;
        this.adder_if = adder_if;
    endfunction  //new()

    task reset();
        adder_if.a = 0;
        adder_if.b = 0;
    endtask  //

    task run();
        forever begin
            gen2drv_mbox.get(tr);
            adder_if.a = tr.a;
            adder_if.b = tr.b;
            #10;

        end
    endtask  //
endclass  //driver

class environment;
    generator gen;
    driver drv;

    mailbox #(transaction) gen2drv_mbox;

    function new(virtual adder_intef adder_if);
        gen2drv_mbox = new();
        gen = new(gen2drv_mbox);
        drv = new(gen2drv_mbox, adder_if);
    endfunction  //new()

    task run();
        //fork - multi_threading
        //fork~join :       스레드 전부 종료시 join 다음라인실행
        //fork~join_any :   스레드 중 하나라도 종료시 join 다음라인실행
        //fork~join_node :  스레드 상태와 무관하게 join 다음라인실행
        fork
            gen.run(10000);
            drv.run();
        join_any
        #10 $finish;
    endtask  //
endclass  //environment;


module tb_adder ();
    environment env;
    adder_intef adder_if ();

    adder u_adder (
        .a    (adder_if.a),
        .b    (adder_if.b),
        .sum  (adder_if.sum),
        .carry(adder_if.carry)
    );

    initial begin
        env = new(adder_if);
        env.run();
    end
endmodule
