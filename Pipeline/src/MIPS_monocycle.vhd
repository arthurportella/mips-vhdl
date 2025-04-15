-------------------------------------------------------------------------
-- Design unit: MIPS monocycle
-- Description: Control and data paths port map
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.MIPS_package.all;

entity MIPS_monocycle is
    generic (
        PC_START_ADDRESS    : integer := 0 
    );
    port ( 
        clock, reset        : in std_logic;
        
        -- Instruction memory interface
        instructionAddress  : out std_logic_vector(31 downto 0);
        instruction         : in  std_logic_vector(31 downto 0);
        
        -- Data memory interface
        dataAddress         : out std_logic_vector(31 downto 0);
        data_i              : in  std_logic_vector(31 downto 0);      
        data_o              : out std_logic_vector(31 downto 0);
        MemWrite            : out std_logic 
    );
end MIPS_monocycle;

architecture structural of MIPS_monocycle is
    
    signal uins: Microinstruction;
    signal instruction_id : std_logic_vector(31 downto 0);
    signal instruction_mux_out : std_logic_vector(31 downto 0);
    constant instruction_alt : std_logic_vector(31 downto 0) := (others => '0');
    signal bubble: std_logic := '0';

begin

        -- MUX implementation directly in code
    instruction_mux_out <= instruction_id when bubble = '0' else instruction_alt;

     CONTROL_PATH: entity work.ControlPath(behavioral)
         port map (
             clock              => clock,
             reset              => reset,
             instruction        => instruction_mux_out,
             uins               => uins
         );
         
         
     DATA_PATH: entity work.DataPath(structural)
         generic map (
            PC_START_ADDRESS => PC_START_ADDRESS
         )
         port map (
            clock               => clock,
            reset               => reset,
            MemWrite            => MemWrite,
            
            uins                => uins,
             
            instructionAddress  => instructionAddress,
            instruction         => instruction,
            instruction_dec     => instruction_id,
            bubble_out          => bubble,
             
            dataAddress         => dataAddress,
            data_i              => data_i,
            data_o              => data_o
         );
     
    
     
end structural;
