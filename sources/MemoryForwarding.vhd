----------------------------------------------------------------------------------
-- Universitatea Tehnica Cluj-Napoca
-- Facultatea de Automatica si Calculatoare
-- Calculatoare si Tehnologia Informatiei
-- Student: CRET MARIA-MAGDALENA
-- Grupa 30233 Seria A

-- STRUCTURA SISTEMELOR DE CALCUL
-- PROIECT LABORATOR
-- Rezolvarea Hazardurilor in Mips Pipeline 16
-- Memory Forwarding UNIT in Mips Pipeline
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use IEEE.numeric_std.all;

entity MemoryForwarding is
    Port (
        MEM_WB_RegWrite: in std_logic;
        WB_BUF_RegWrite: in std_logic;
        EX_MEM_MemWrite: in std_logic;
        EX_MEM_Rt: in std_logic_vector(2 downto 0);
        WB_BUF_RegDst: in std_logic_vector(2 downto 0);
        MEM_WB_RegDst: in std_logic_vector(2 downto 0);
        forwardC: out std_logic_vector(1 downto 0)
    );
end MemoryForwarding;

architecture Behavioral of MemoryForwarding is

begin
    process (WB_BUF_RegWrite, EX_MEM_Rt, EX_MEM_MemWrite, WB_BUF_RegDst, MEM_WB_RegWrite, MEM_WB_RegDst) is
    begin
      ForwardC <= "00";
      if MEM_WB_RegWrite = '1' then 
            if EX_MEM_Rt = MEM_WB_RegDst and EX_MEM_MemWrite = '1' then forwardC <= "01";
            end if;
        end if;
        if WB_BUF_RegWrite = '1' then 
            if EX_MEM_Rt = WB_BUF_RegDst and EX_MEM_MemWrite = '1' then forwardC <= "10";
            end if;
        end if;
    end process;
end Behavioral;
