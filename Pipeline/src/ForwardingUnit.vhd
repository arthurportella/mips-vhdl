library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ForwardingUnit is
    Port (
        -- Input
        rs_id_ex               : in std_logic_vector(4 downto 0);  -- rs do estágio ID/EX
        rt_id_ex               : in std_logic_vector(4 downto 0);  -- rt do estágio ID/EX
        exmem_RegisterRd       : in std_logic_vector(4 downto 0);  -- Registrador de destino do estágio EX/MEM
        memwb_RegisterRd       : in std_logic_vector(4 downto 0);  -- Registrador de destino do estágio MEM/WB
        regWrite_exmem         : in std_logic;                     -- Sinal de escrita no registrador no estágio EX/MEM
        regWrite_memwb         : in std_logic;                     -- Sinal de escrita no registrador no estágio MEM/WB
        -- Output
        ForwardA               : out std_logic_vector(1 downto 0); -- Sinal de encaminhamento para o registrador fonte A
        ForwardB               : out std_logic_vector(1 downto 0)  -- Sinal de encaminhamento para o registrador fonte B
    );
end ForwardingUnit;

architecture Behavioral of ForwardingUnit is
begin
    process(rs_id_ex, rt_id_ex, exmem_RegisterRd, memwb_RegisterRd, regWrite_exmem, regWrite_memwb)
    begin
        -- Valores padrão
        
        -- Lógica de encaminhamento para ForwardA
        if (regWrite_exmem = '1' and exmem_RegisterRd /= "00000" and exmem_RegisterRd = rs_id_ex) then
            ForwardA <= "10"; -- Encaminhamento do estágio EX/MEM
        elsif (regWrite_memwb = '1' and memwb_RegisterRd /= "00000" and memwb_RegisterRd = rs_id_ex) then
            ForwardA <= "01"; -- Encaminhamento do estágio MEM/WB
	else
	    ForwardA <= "00";
        end if;
        
        -- Lógica de encaminhamento para ForwardB
        if (regWrite_exmem = '1' and exmem_RegisterRd /= "00000" and exmem_RegisterRd = rt_id_ex) then
            ForwardB <= "10"; -- Encaminhamento do estágio EX/MEM
        elsif (regWrite_memwb = '1' and memwb_RegisterRd /= "00000" and memwb_RegisterRd = rt_id_ex) then
            ForwardB <= "01"; -- Encaminhamento do estágio MEM/WB
	else 
	    ForwardB <= "00";
        end if;
    end process;
end Behavioral;
