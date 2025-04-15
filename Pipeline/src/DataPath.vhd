library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all; 
use work.MIPS_package.all;

entity DataPath is
    generic (
        PC_START_ADDRESS    : integer := 0
    );
    port (  
        clock               : in  std_logic;
        reset               : in  std_logic;
        instructionAddress  : out std_logic_vector(31 downto 0);  -- Instruction memory address bus
        instruction         : in  std_logic_vector(31 downto 0);  -- Data bus from instruction memory
        instruction_dec     : out  std_logic_vector(31 downto 0); -- Data bus from stage ID_EX instruction memory
        dataAddress         : out std_logic_vector(31 downto 0);  -- Data memory address bus
        data_i              : in  std_logic_vector(31 downto 0);  -- Data bus from data memory 
        data_o              : out std_logic_vector(31 downto 0);  -- Data bus to data memory
        bubble_out          : out std_logic;                      -- Data from HazardUnit
        uins                : in  Microinstruction;                -- Control path microinstruction
        MemWrite            : out std_logic              -- Control path microinstruction
    );
end DataPath;


architecture structural of DataPath is

    signal incrementedPC, incrementedPC_id, incrementedPC_ex, result, data_i_wb, result_mem, result_wb, readData1, readData2, readData1_ex, readData2_ex, readData2_mem, ALUoperand1, ALUoperand2, ALUoperand2_2, signExtended, signExtended_id_ex, zeroExtended, zeroExtended_ex, writeData: std_logic_vector(31 downto 0);
    signal branchOffset, branchTarget, branchTarget_ex_mem, pc_d, pc_q: std_logic_vector(31 downto 0);
    signal jumpTarget: std_logic_vector(31 downto 0);
    signal writeRegister, writeRegister_mem, writeRegister_wb    : std_logic_vector(4 downto 0);
    signal instruction_id, instruction_mem, Data1_id, Data2_id: std_logic_vector(31 downto 0);
    signal id_rs, id_rt, id_rd, ex_rs, ex_rt, ex_rd: std_logic_vector(4 downto 0);
    signal data_dependency: std_logic;
    signal ForwardA              : std_logic_vector(1 downto 0);
    signal ForwardB              : std_logic_vector(1 downto 0);
    signal uins_ex, uins_mem, uins_wb : Microinstruction;
    signal bubble ,bubble_sig            : std_logic;
    signal zero, zero_mem : std_logic;
    signal stall: std_logic;
    signal jump_reset, branch_reset, reset_id: std_logic;
    signal decodedInstruction: Instruction_type;
    signal opcode, funct: std_logic_vector(5 downto 0);
 
    -- Retrieves the rs field from the instruction
    alias rs: std_logic_vector(4 downto 0) is instruction(25 downto 21);
        
    -- Retrieves the rt field from the instruction
    alias rt: std_logic_vector(4 downto 0) is instruction(20 downto 16);
        
    -- Retrieves the rd field from the instruction
    alias rd: std_logic_vector(4 downto 0) is instruction(15 downto 11);

begin

    opcode <= instruction(31 downto 26);
    funct <= instruction(5 downto 0);

    instruction_dec <= instruction_id;
    bubble_out <= bubble_sig;

    stall <= '0' when bubble_sig = '1' else '1';

    MemWrite <= uins_mem.MemWrite;

    reset_id <= branch_reset or jump_reset;

    -- incrementedPC points to the next instruction address
    ADDER_PC: incrementedPC <= STD_LOGIC_VECTOR(UNSIGNED(pc_q) + TO_UNSIGNED(4, 32));

-----------------------------------------------------------------------------------------
-------------------------------IF/ID-----------------------------------------------------
-----------------------------------------------------------------------------------------

    -- PC register
    PROGRAM_COUNTER:    entity work.RegisterNbits
        generic map (
            LENGTH      => 32,
            INIT_VALUE  => PC_START_ADDRESS
        )
        port map (
            clock       => clock,
            reset       => reset,
            ce          => stall, 
            d           => pc_d, 
            q           => pc_q
        );
   
    IF_ID_INSTRUCTION:    entity work.RegisterNbits
        generic map (
            LENGTH      => 32,
            INIT_VALUE  => PC_START_ADDRESS
        )
        port map (
            clock       => clock,
            reset       => reset_id,
            ce          => stall, 
            d           => instruction, 
            q           => instruction_id
        );

    IF_ID_ADDER:    entity work.RegisterNbits
        generic map (
            LENGTH      => 32,
            INIT_VALUE  => PC_START_ADDRESS
        )
        port map (
            clock       => clock,
            reset       => reset_id,
            ce          => stall, 
            d           => incrementedPC, 
            q           => incrementedPC_id
        );

    IF_ID_RS:    entity work.RegisterNbits
        generic map (
            LENGTH      => 5,
            INIT_VALUE  => PC_START_ADDRESS
        )
        port map (
            clock       => clock,
            reset       => reset_id,
            ce          => stall, 
            d           => rs, 
            q           => id_rs
        );

    IF_ID_RT:    entity work.RegisterNbits
        generic map (
            LENGTH      => 5,
            INIT_VALUE  => PC_START_ADDRESS
        )
        port map (
            clock       => clock,
            reset       => reset_id,
            ce          => stall, 
            d           => rt, 
            q           => id_rt
        );

    IF_ID_RD:    entity work.RegisterNbits
        generic map (
            LENGTH      => 5,
            INIT_VALUE  => PC_START_ADDRESS
        )
        port map (
            clock       => clock,
            reset       => reset_id,
            ce          => stall, 
            d           => rd, 
            q           => id_rd
        );

        --Register Control Signals Execution Stage
        process(clock, branch_reset)
        begin
            if branch_reset = '1' then
                uins_ex.instruction <= INVALID_INSTRUCTION;
                uins_ex.RegWrite    <= '0';
                uins_ex.ALUSrc      <= "00";
                uins_ex.MemWrite    <= '0';
                uins_ex.MemToReg    <= '0';
                uins_ex.RegDst      <= '0';
                uins_ex.Branch      <= '0';
                uins_ex.Jump        <= '0';
    
            elsif  rising_edge(clock) then
                uins_ex <= uins;
            end if;
        end process;

-----------------------------------------------------------------------------------------
-------------------------------ID/EX-----------------------------------------------------
-----------------------------------------------------------------------------------------

    ID_EX_RS:    entity work.RegisterNbits
        generic map (
            LENGTH      => 5,
            INIT_VALUE  => PC_START_ADDRESS
        )
        port map (
            clock       => clock,
            reset       => branch_reset,
            ce          => stall, 
            d           => id_rs, 
            q           => ex_rs
        );

    ID_EX_RT:    entity work.RegisterNbits
        generic map (
            LENGTH      => 5,
            INIT_VALUE  => PC_START_ADDRESS
        )
        port map (
            clock       => clock,
            reset       => branch_reset,
            ce          => stall, 
            d           => id_rt, 
            q           => ex_rt
        );

    ID_EX_RD:    entity work.RegisterNbits
        generic map (
            LENGTH      => 5,
            INIT_VALUE  => PC_START_ADDRESS
        )
        port map (
            clock       => clock,
            reset       => branch_reset,
            ce          => stall, 
            d           => id_rd, 
            q           => ex_rd
        );

    ID_EX_INSTRUCTION_RD1:    entity work.RegisterNbits
        generic map (
            LENGTH      => 32,
            INIT_VALUE  => PC_START_ADDRESS
        )
        port map (
            clock       => clock,
            reset       => branch_reset,
            ce          => stall, 
            d           => Data1_id, 
            q           => readData1_ex
        );
   
    ID_EX_INSTRUCTION_RD2:    entity work.RegisterNbits
        generic map (
            LENGTH      => 32,
            INIT_VALUE  => PC_START_ADDRESS
        )
        port map (
            clock       => clock,
            reset       => branch_reset,
            ce          => stall, 
            d           => Data2_id, 
            q           => readData2_ex
        );

    ID_EX_ADDER:    entity work.RegisterNbits
        generic map (
            LENGTH      => 32,
            INIT_VALUE  => PC_START_ADDRESS
        )
        port map (
            clock       => clock,
            reset       => branch_reset,
            ce          => stall, 
            d           => incrementedPC_id, 
            q           => incrementedPC_ex
        );

    ID_EX_SIGN_EXTENDED:    entity work.RegisterNbits
        generic map (
            LENGTH      => 32,
            INIT_VALUE  => PC_START_ADDRESS
        )
        port map (
            clock       => clock,
            reset       => branch_reset,
            ce          => stall, 
            d           => signExtended, 
            q           => signExtended_id_ex
        );

    ID_EX_ZERO_EXTENDED:    entity work.RegisterNbits
        generic map (
            LENGTH      => 32,
            INIT_VALUE  => PC_START_ADDRESS
        )
        port map (
            clock       => clock,
            reset       => branch_reset,
            ce          => stall, 
            d           => zeroExtended, 
            q           => zeroExtended_ex
        );


        --Register Control Signals Memory Stage
        process(clock, branch_reset)
        begin
            if branch_reset = '1' then
                uins_mem.instruction <= INVALID_INSTRUCTION;
                uins_mem.RegWrite    <= '0';
                uins_mem.ALUSrc      <= "00";
                uins_mem.MemWrite    <= '0';
                uins_mem.MemToReg    <= '0';
                uins_mem.RegDst      <= '0';
                uins_mem.Branch      <= '0';
                uins_mem.Jump        <= '0';
    
            elsif  rising_edge(clock) then
                uins_mem <= uins_ex;
            end if;
        end process;

-----------------------------------------------------------------------------------------
-------------------------------EX/MEM----------------------------------------------------
-----------------------------------------------------------------------------------------

    EX_MEM_BRANCH:    entity work.RegisterNbits
        generic map (
            LENGTH      => 32,
            INIT_VALUE  => PC_START_ADDRESS
        )
        port map (
            clock       => clock,
            reset       => branch_reset,
            ce          => '1', 
            d           => branchTarget, 
            q           => branchTarget_ex_mem
        );


    EX_MEM_ALU_ZERO:    entity work.Register1bit

        port map (
            clock       => clock,
            reset       => branch_reset,
            ce          => '1', 
            d           => zero, 
            q           => zero_mem
        );

    EX_MEM_ALU_RESULT:    entity work.RegisterNbits
        generic map (
            LENGTH      => 32,
            INIT_VALUE  => PC_START_ADDRESS
        )
        port map (
            clock       => clock,
            reset       => branch_reset,
            ce          => '1', 
            d           => result, 
            q           => result_mem
        );

    EX_MEM_WRITE_DATA:    entity work.RegisterNbits
        generic map (
            LENGTH      => 32,
            INIT_VALUE  => PC_START_ADDRESS
        )
        port map (
            clock       => clock,
            reset       => branch_reset,
            ce          => '1', 
            d           => readData2_ex, 
            q           => readData2_mem
        );

    EX_MEM_WREGISTER:    entity work.RegisterNbits
        generic map (
            LENGTH      => 5,
            INIT_VALUE  => PC_START_ADDRESS
        )
        port map (
            clock       => clock,
            reset       => branch_reset,
            ce          => '1', 
            d           => writeRegister, 
            q           => writeRegister_mem
        );      


        --Register Control Signals WriteBack Stage
        process(clock, reset)
        begin
            if reset = '1' then
                uins_wb.instruction <= INVALID_INSTRUCTION;
                uins_wb.RegWrite    <= '0';
                uins_wb.ALUSrc      <= "00";
                uins_wb.MemWrite    <= '0';
                uins_wb.MemToReg    <= '0';
                uins_wb.RegDst      <= '0';
                uins_wb.Branch      <= '0';
                uins_wb.Jump        <= '0';
    
            elsif  rising_edge(clock) then
                uins_wb <= uins_mem;
            end if;
        end process;

-----------------------------------------------------------------------------------------
-------------------------------MEM/WB-----------------------------------------------------
-----------------------------------------------------------------------------------------

    MEM_WB_READ_DATA_MUX:    entity work.RegisterNbits
        generic map (
            LENGTH      => 32,
            INIT_VALUE  => PC_START_ADDRESS
        )
        port map (
            clock       => clock,
            reset       => reset,
            ce          => '1', 
            d           => data_i, 
            q           => data_i_wb
        );

    MEM_WB_ADDRESS_MUX:    entity work.RegisterNbits
        generic map (
            LENGTH      => 32,
            INIT_VALUE  => PC_START_ADDRESS
        )
        port map (
            clock       => clock,
            reset       => reset,
            ce          => '1', 
            d           => result_mem, 
            q           => result_wb
        );

    MEM_WB_WREGISTER:    entity work.RegisterNbits
        generic map (
            LENGTH      => 5,
            INIT_VALUE  => PC_START_ADDRESS
        )
        port map (
            clock       => clock,
            reset       => reset,
            ce          => '1', 
            d           => writeRegister_mem, 
            q           => writeRegister_wb
        );     


    -- Instruction memory is addressed by the PC register
    instructionAddress <= pc_q;        
    
    -- Selects the instruction field which contains the register to be written
    -- MUX at the register file input
    MUX_RF: writeRegister <= ex_rt when uins_ex.RegDst = '0' else ex_rd;
    
    -- Sign extends the low 16 bits of instruction 
    SIGN_EX: signExtended <= x"FFFF" & instruction_id(15 downto 0) when instruction_id(15) = '1' else 
                    x"0000" & instruction_id(15 downto 0);
                    
    -- Zero extends the low 16 bits of instruction 
    ZERO_EX: zeroExtended <= x"0000" & instruction_id(15 downto 0);
       
    -- Converts the branch offset from words to bytes (multiply by 4) 
    -- Hardware at the second ADDER input
    SHIFT_L: branchOffset <= signExtended_id_ex(29 downto 0) & "00";
    
    -- Branch target address
    -- Branch ADDER
    ADDER_BRANCH: branchTarget <= STD_LOGIC_VECTOR(UNSIGNED(incrementedPC_ex) + UNSIGNED(branchOffset));
    
    -- Jump target address
    jumpTarget <= incrementedPC_id(31 downto 28) & instruction_id(25 downto 0) & "00";
    
    MUX_PC: pc_d <= branchTarget_ex_mem when (uins_mem.Branch and zero_mem) = '1' else 
            jumpTarget when uins.Jump = '1' else
            incrementedPC;
      
    -- Selects the second ALU operand
    -- MUX at the ALU input
     MUX_ALU: ALUoperand2_2 <= ALUoperand2 when uins_ex.ALUSrc = "00" else
                          zeroExtended_ex when uins_ex.ALUSrc = "01" else
                            signExtended_id_ex;
    
    -- Selects the data to be written in the register file
    -- MUX at the data memory output
    MUX_DATA_MEM: writeData <= data_i_wb when uins_wb.memToReg = '1' else result_wb;
    

    -- Data to data memory comes from the second read register at register file
    data_o <= readData2_mem;  --Aqui tinha o readData2
    
    -- ALU output addresses the data memory
    dataAddress <= result_mem;
    
    ForwardingUnit: entity work.ForwardingUnit
    port map (
        rs_id_ex         => ex_rs,
        rt_id_ex         => ex_rt,
        exmem_RegisterRd => writeRegister_mem,
        memwb_RegisterRd => writeRegister_wb,
        regWrite_exmem   => uins_mem.RegWrite,
        regWrite_memwb   => uins_wb.RegWrite,
        ForwardA         => ForwardA,
        ForwardB         => ForwardB
    );    
    

    -- MUX 2:1 for Data ID 1
    process(writeRegister_wb, id_rs, uins_wb.RegWrite, writeData, readData1)
    begin
        if (writeRegister_wb = id_rs and uins_wb.RegWrite = '1') then
		Data1_id <= writeData;
	else 
		Data1_id <= readData1;
	end if;
    end process;

   -- MUX 2:1 for Data ID 2
    process(writeRegister_wb, id_rt, uins_wb.RegWrite, writeData, readData2)
    begin
        if (writeRegister_wb = id_rt and uins_wb.RegWrite = '1') then
		Data2_id <= writeData;
	else 
		Data2_id <= readData2;
	end if;
    end process;

    -- MUX 3:1 for ALUOperand1 (ForwardUnit)
    process(ForwardA, readData1_ex, writeData, result_mem)
    begin
        case ForwardA is
            when "00" =>
                ALUoperand1 <= readData1_ex;
            when "01" =>
                ALUoperand1 <= writeData;
            when others =>
                ALUoperand1 <= result_mem; 
        end case;
    end process;

    -- MUX 3:1 for ALUoperand2 (ForwardUnit)
    process(ForwardB, readData2_ex, writeData, result_mem)
    begin
        case ForwardB is
            when "00" =>
                ALUoperand2 <= readData2_ex;
            when "01" =>
                ALUoperand2 <= writeData;
            when others =>
                ALUoperand2 <= result_mem; 
        end case;
    end process;

    HazardDetection: entity work.HazardDetectionUnit
        port map (
            ID_EX_MemRead  => uins_ex.MemToReg,
            ID_EX_rt       => ex_rt,
            IF_ID_rs       => id_rs,
            IF_ID_rt       => id_rt,
            bubble         => bubble_sig
        );

        bubble <= bubble_sig;

    
    -- Register file
    REGISTER_FILE: entity work.RegisterFile(structural)
        port map (
            clock            => clock,
            reset            => reset,            
            write            => uins_wb.RegWrite,            
            readRegister1    => id_rs,    
            readRegister2    => id_rt,
            writeRegister    => writeRegister_wb,
            writeData        => writeData,          
            readData1        => readData1,        
            readData2        => readData2
        );
    
    
    -- Arithmetic/Logic Unit
    ALU: entity work.ALU(behavioral)
        port map (
            operand1    => ALUoperand1,
            operand2    => ALUoperand2_2,
            result      => result,
            zero        => zero,
            operation   => uins_ex.instruction
        );
        
    -- Data dependency detection 
    process (id_rs, id_rt, writeRegister, uins_ex.RegWrite)
    begin
        if (uins_ex.RegWrite = '1') then
            if (id_rs = writeRegister) or (id_rt = writeRegister) then
                data_dependency <= '1';
            else
                data_dependency <= '0';
            end if;
        else
            data_dependency <= '0';
        end if;
    end process;

    --Process for reset when a Jump occurs
    process(clock, reset)
    begin
        if reset = '1' then
            jump_reset <= '1';
        else
            if uins.Jump = '1' and clock = '1' then
                jump_reset <= '1';
            else
                jump_reset <= '0';
            end if;
        end if;
    end process;

    --Process for reset when a Branch occurs
    process(clock, reset)
    begin
        if reset = '1' then
            branch_reset <= '1';
        else
            if uins_mem.Branch = '1' and clock = '1' and zero_mem = '1' then
                branch_reset <= '1';
            else
                branch_reset <= '0';
            end if;
        end if;
    end process;

        decodedInstruction <=   ADDU    when opcode = "000000" and funct = "100001" else
                            SUBU    when opcode = "000000" and funct = "100011" else
                            AAND    when opcode = "000000" and funct = "100100" else
                            OOR     when opcode = "000000" and funct = "100101" else
                            SLT     when opcode = "000000" and funct = "101010" else
                            SW      when opcode = "101011" else
                            LW      when opcode = "100011" else
                            ADDIU   when opcode = "001001" else
                            ORI     when opcode = "001101" else
                            BEQ     when opcode = "000100" else
                            J       when opcode = "000010" else
                            LUI     when opcode = "001111" and rs = "00000" else
                            INVALID_INSTRUCTION ;    -- BUBBLE

end structural;
