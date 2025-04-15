library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package MIPS_package is
    -- Define Instruction_type for the control unit
    type Instruction_type is (ADDU, SUBU, AAND, OOR, SW, LW, ADDIU, ORI, SLT, BEQ, J, LUI, INVALID_INSTRUCTION);

    -- Define Microinstruction type
    type Microinstruction is record
        RegWrite    : std_logic;                -- Register file write control
        ALUSrc      : std_logic_vector(1 downto 0); -- Selects the ALU second operand
        RegDst      : std_logic;                -- Selects the destination register
        MemToReg    : std_logic;                -- Selects the data to the register file
        MemWrite    : std_logic;                -- Enable the data memory write
        Branch      : std_logic;                -- Indicates the BEQ instruction
        Jump        : std_logic;                -- Indicates the J instruction
        instruction : Instruction_type;         -- Decoded instruction
    end record;

    -- Define the RegisterFile_type
    type RegisterFile_type is array (0 to 31) of std_logic_vector(31 downto 0);

    -- Define pipeline register types
    type PipelineRegister_IF_ID is record
        pc          : std_logic_vector(31 downto 0);
        instruction : std_logic_vector(31 downto 0);
    end record;

    type PipelineRegister_ID_EX is record
        rs1_data    : std_logic_vector(31 downto 0);
        rs2_data    : std_logic_vector(31 downto 0);
        imm         : std_logic_vector(31 downto 0);
        rd          : std_logic_vector(4 downto 0);
        control     : Microinstruction;
        ALU_result  : std_logic_vector(31 downto 0);
        zero_flag   : std_logic;                    
    end record;

    type PipelineRegister_EX_MEM is record
        ALU_result  : std_logic_vector(31 downto 0);
        zero_flag   : std_logic;
        rd          : std_logic_vector(4 downto 0);
        control     : Microinstruction;
    end record;

    type PipelineRegister_MEM_WB is record
        data        : std_logic_vector(31 downto 0);
        rd          : std_logic_vector(4 downto 0);
        control     : Microinstruction;
    end record;

end package MIPS_package;

