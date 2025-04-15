library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity RegisterFile is
    port ( 
        clock           : in std_logic;
        reset           : in std_logic; 
        write           : in std_logic;
        readRegister1   : in std_logic_vector(4 downto 0);
        readRegister2   : in std_logic_vector(4 downto 0);
        writeRegister   : in std_logic_vector(4 downto 0);
        writeData       : in std_logic_vector(31 downto 0);
        readData1       : out std_logic_vector(31 downto 0); 
        readData2       : out std_logic_vector(31 downto 0) 
    );
end RegisterFile;

architecture behavioral of RegisterFile is

   type RegArray is array(0 to 31) of std_logic_vector(31 downto 0);
   signal reg: RegArray;            -- Array with the stored registers value                            

begin            
    process(clock, reset)
    begin
        if reset = '1' then
            for i in 0 to 31 loop
                reg(i) <= (others => '0');
            end loop;
        elsif rising_edge(clock) then
            if write = '1' and unsigned(writeRegister) > 0 then    -- Register $0 is the constant 0, not a register.
                reg(to_integer(unsigned(writeRegister))) <= writeData;
            end if;
        end if;
    end process;  
    
    -- Register source (rs)
    readData1 <= reg(to_integer(unsigned(readRegister1)));   

    -- Register target (rt)
    readData2 <= reg(to_integer(unsigned(readRegister2)));
   
end behavioral;

