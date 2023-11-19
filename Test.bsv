import Json::*;
import Vector::*;
import BuildVector::*;
import ModuleContext::*;

typedef Bit#(53) Foo;

typedef struct { 
    Bit#(32) mm;
    Foo a;
} Foobar deriving (Bits);

typedef union tagged { 
    Vector#(2,Foobar) A;
    Foo B;
} Unicorn deriving (Bits);

typedef Bit#(6) RegionId;

typedef struct {
    Bit#(10) base;
    Bit#(4) size;
} RegionConfig deriving (Bits,Eq,FShow);

typedef struct {
    RegionId rid;
    RegionConfig rconfig;
} MMIOStuff deriving (Bits, Eq,FShow);

typedef struct {
    t val;
    Bit#(64) timestamp;
} Timestamped#(type t) deriving (Bits, Eq, FShow);

interface Tracer;
    method Action trace(Fmt a);
endinterface

module tracer#(String outfile)(Tracer);
    Reg#(Bool) init <- mkReg(True);
    Reg#(File) file <- mkReg(InvalidFile);
    Reg#(Bit#(64)) timestamp <- mkReg(0);
    rule do_init (init);
        init <= False;
        File fl <- $fopen (outfile);
        file <= fl;
    endrule

    rule tic;
        timestamp <= timestamp + 1;
    endrule

    method Action trace(Fmt in)  if (file != InvalidFile);
        Fmt s = toJSON(Timestamped{val:in, timestamp: timestamp}) + $format("\n");
        $fwrite(file, s);
    endmethod
endmodule

module mkTest(Empty);
    Reg#(Bit#(32)) done <- mkReg(0);
    Reg#(Unicorn) a <- mkReg(A (vec(Foobar{ mm: 11, a : 11},
                                    Foobar{ mm: 23, a : 41})));
    Tracer log <- tracer("/tmp/data.json");

    rule test ;
        log.trace(toJSON(a));
        done <= done + 1;
        if (done == 16) begin
            $finish;
        end
    endrule

    rule test2 ;
        log.trace(toJSON(a));
        done <= done + 1;
        if (done == 16) begin 
            $finish;
        end
    endrule

endmodule