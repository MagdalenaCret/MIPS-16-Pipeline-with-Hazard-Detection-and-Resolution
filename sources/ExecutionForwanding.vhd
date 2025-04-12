----------------------------------------------------------------------------------
-- Universitatea Tehnica Cluj-Napoca
-- Facultatea de Automatica si Calculatoare
-- Calculatoare si Tehnologia Informatiei
-- Student: CRET MARIA-MAGDALENA
-- Grupa 30233 Seria A

-- STRUCTURA SISTEMELOR DE CALCUL
-- PROIECT LABORATOR
-- Rezolvarea Hazardurilor in Mips Pipeline 16
-- Execution Forwarding 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use IEEE.numeric_std.all;

entity ExecutionForwarding is
    Port (
        EX_MEM_RegWrite: in std_logic;
        MEM_WB_RegWrite: in std_logic;
        EX_MEM_RegDst: in std_logic_vector(2 downto 0);
        MEM_WB_RegDst: in std_logic_vector(2 downto 0);
        ID_EX_Rs: in std_logic_vector(2 downto 0);
        ID_EX_Rt: in std_logic_vector(2 downto 0);
        forward_A: out std_logic_vector (1 downto 0);
        forward_B: out std_logic_vector (1 downto 0)
    );
end ExecutionForwarding;

--forward_A: controleaz? forwarding-ul pentru primul operand (Rs)

--"00": f?r? forwarding (valoare normal? din registru)
--"01": forwarding din etapa MEM
--"10": forwarding din etapa WB


--forward_B: controleaz? forwarding-ul pentru al doilea operand (Rt)
--Aceea?i codificare ca forward_A
architecture Behavioral of ExecutionForwarding is

begin

    process (ID_EX_Rs, ID_EX_Rt, EX_MEM_RegWrite, EX_MEM_RegDst, MEM_WB_RegWrite, MEM_WB_RegDst) is
    begin
        -- initializare cu 0 pentru semnale
        forward_A <= "00";
        forward_B <= "00";
                
        if MEM_WB_RegWrite = '1' then 
            if MEM_WB_RegDst = ID_EX_Rs then forward_A <= "10";
            elsif MEM_WB_RegDst = ID_EX_Rt then forward_B <= "10";
            end if;
        end if;
       
        if EX_MEM_RegWrite = '1' then 
            if EX_MEM_RegDst = ID_EX_Rs then forward_A <= "01";
            elsif EX_MEM_RegDst = ID_EX_Rt then forward_B <= "01";	
            end if;
        end if;        
    end process;
    
end Behavioral;
