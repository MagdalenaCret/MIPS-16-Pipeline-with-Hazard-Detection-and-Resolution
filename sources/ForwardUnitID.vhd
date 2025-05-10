----------------------------------------------------------------------------------
-- Universitatea Tehnica Cluj-Napoca
-- Facultatea de Automatica si Calculatoare
-- Calculatoare si Tehnologia Informatiei
-- Student: CRET MARIA-MAGDALENA
-- Grupa 30233 Seria A

-- STRUCTURA SISTEMELOR DE CALCUL
-- PROIECT LABORATOR
-- Rezolvarea Hazardurilor in Mips Pipeline 16
-- Forwarding Unit For Instruction Decoder Stage
----------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use IEEE.numeric_std.all;

entity ForwardUnitID is
    Port(
        EX_MEM_RegWrite: in std_logic;
        EX_MEM_RegDst: in std_logic_vector(2 downto 0);
        ID_Branch: in std_logic;
        ID_Rs: in std_logic_vector(2 downto 0);
        ID_Rt: in std_logic_vector(2 downto 0);
        forward_A: out std_logic;
        forward_B: out std_logic
    );
end ForwardUnitID;

--ID_Branch: indic? dac? instruc?iunea curent? este de tip branch
--EX_MEM_RegWrite: indic? dac? instruc?iunea din etapa EX/MEM scrie în registre
--EX_MEM_RegDst: registrul destina?ie al instruc?iunii din EX/MEM
--ID_Rs, ID_Rt: registrele surs? ale instruc?iunii de branch


--Semnale de ie?ire:


--forward_A: controleaz? forwarding-ul pentru primul operand (Rs)
--forward_B: controleaz? forwarding-ul pentru al doilea operand (Rt)
architecture Behavioral of ForwardUnitID is

begin
    -- Detection and forwarding Unit
    process(ID_Branch, EX_MEM_RegWrite, EX_MEM_RegDst, ID_Rs, ID_Rt) is
    begin
    --initializare semnale cu 0
        forward_A <= '0';
        forward_B <= '0';
        
        if (ID_Branch = '1') and (EX_MEM_RegWrite = '1') and EX_MEM_RegDst = ID_Rs then
            forward_A <= '1';
        end if;
        
        if (ID_Branch = '1') and (EX_MEM_RegWrite = '1') and EX_MEM_RegDst = ID_Rt then
            forward_B <= '1';
        end if;
        
    end process;

end Behavioral;
