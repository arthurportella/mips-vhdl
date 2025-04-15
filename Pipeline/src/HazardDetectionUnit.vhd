-------------------------------------------------------------------------
-- Design unit: Hazard Detection Unit
-- Description: Detects hazards and inserts stalls into the pipeline
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.MIPS_package.all;

entity HazardDetectionUnit is
    port (
        ID_EX_MemRead    : in std_logic;
        ID_EX_rt         : in std_logic_vector(4 downto 0);
        IF_ID_rs         : in std_logic_vector(4 downto 0);
        IF_ID_rt         : in std_logic_vector(4 downto 0);
        bubble           : out std_logic
    );
end HazardDetectionUnit;

architecture behavioral of HazardDetectionUnit is
begin
    process(ID_EX_MemRead, ID_EX_rt, IF_ID_rs, IF_ID_rt)
    begin
        if (ID_EX_MemRead = '1' and (ID_EX_rt = IF_ID_rs or ID_EX_rt = IF_ID_rt)) then
            bubble <= '1';
        else
            bubble <= '0';
        end if;
    end process;
end behavioral;
