library verilog;
use verilog.vl_types.all;
library work;
entity instr_register_test is
    port(
        clk             : in     vl_logic;
        load_en         : out    vl_logic;
        reset_n         : out    vl_logic;
        operand_a       : out    vl_logic_vector(31 downto 0);
        operand_b       : out    vl_logic_vector(31 downto 0);
        opcode          : out    work.instr_register_pkg.opcode_t;
        write_pointer   : out    vl_logic_vector(4 downto 0);
        read_pointer    : out    vl_logic_vector(4 downto 0);
        instruction_word: in     work.instr_register_pkg.instruction_t
    );
end instr_register_test;
