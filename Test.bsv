import Json::*;
import Vector::*;
import BuildVector::*;

typedef Bit#(53) Foo;

typedef struct { 
    Bit#(32) mm;
    Foo a;
} Foobar deriving (Bits);

typedef union tagged { 
    Vector#(2,Foobar) A;
    Foo B;
} Unicorn deriving (Bits);


module mkTest(Empty);
    Reg#(Bool) init <- mkReg(True);
    Reg#(Bit#(32)) done <- mkReg(0);
    Reg#(File) file <- mkReg(InvalidFile);
    function Action outputJSON(Fmt in);
        Fmt s = in + $format("\n");
        $fwrite(file, s);
    endfunction

    Reg#(Unicorn) a <- mkReg(A (vec(Foobar{ mm: 3, a : 42}, 
                                    Foobar{ mm: 23, a : 41})));


    rule do_init (init);
        init <= False;
        File fl <- $fopen ("/tmp/data.json");
        file <= fl;
    endrule

    rule test (!init);
        outputJSON(toJSON(a));
        done <= done + 1;
        if (done == 16) begin 
            $finish;
        end
    endrule

endmodule