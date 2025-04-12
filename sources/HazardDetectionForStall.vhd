----------------------------------------------------------------------------------
-- Universitatea Tehnica Cluj-Napoca
-- Facultatea de Automatica si Calculatoare
-- Calculatoare si Tehnologia Informatiei
-- Student: CRET MARIA-MAGDALENA
-- Grupa 30233 Seria A

-- STRUCTURA SISTEMELOR DE CALCUL
-- PROIECT LABORATOR
-- Rezolvarea Hazardurilor in Mips Pipeline 16
-- Hazard Detection For Stall
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use IEEE.numeric_std.all;

entity HazardDetectionForStall is
    Port (
        ID_Rs: in std_logic_vector(2 downto 0); 
        ID_Rt: in std_logic_vector(2 downto 0); 
        ID_EX_Rt: in std_logic_vector(2 downto 0);
        ID_EX_MemRead: in std_logic; 
        instr_branch: in std_logic;
        ID_EX_RegWrite: in std_logic;
        EX_MEM_RegWrite: in std_logic;
        EX_WrAddrChosen: in std_logic_vector(2 downto 0); -- from EX unit
        EX_MEM_WrAddrChosen: in std_logic_vector(2 downto 0); -- from MEM unit
        IF_ID_WriteEn: out std_logic;
        control_sel: out std_logic;
        enable_pc: out std_logic
    );
end HazardDetectionForStall;

architecture Behavioral of HazardDetectionForStall is
--Când se detecteaz? un hazard:

--IF_ID_WriteEn <= '0': Opre?te scrierea în registrul IF/ID
--control_sel <= '0': Dezactiveaz? semnalele de control
--enable_pc <= '0': Opre?te incrementarea PC-ului
begin
    hazard_det: process(ID_Rs, ID_Rt, ID_EX_Rt, ID_EX_MemRead, ID_EX_RegWrite, instr_branch, EX_WrAddrChosen, EX_MEM_RegWrite, EX_MEM_WrAddrChosen) is
    begin
        IF_ID_WriteEn <= '1';
        control_sel <= '1';
        enable_pc <= '1';
        
        -- Salt (Brach)
        if (ID_EX_RegWrite = '1' and instr_branch = '1') and (ID_Rs = EX_WrAddrChosen or ID_Rt = EX_WrAddrChosen) then
            IF_ID_WriteEn <= '0';
            control_sel <= '0';
            enable_pc <= '0'; 
        end if;   
        
        --Detecteaz? când o instruc?iune încearc? s? foloseasc? date care înc? se încarc? din memorie
        --Verific? dac? registrul destina?ie al unui load (ID_EX_Rt) este surs? pentru instruc?iunea urm?toare
          -- Hazarduri de tipul load data
        if ID_EX_MemRead = '1' and (ID_Rs = ID_EX_Rt or ID_Rt = ID_EX_Rt) then
            IF_ID_WriteEn <= '0';
            control_sel <= '0';
            enable_pc <= '0';                    
        end if;
        if(EX_MEM_RegWrite = '1' and instr_branch = '1') and (ID_Rs = EX_MEM_WrAddrChosen or ID_Rt = EX_MEM_WrAddrChosen) then
            IF_ID_WriteEn <= '0';
            control_sel <= '0';
            enable_pc <= '0'; 
        end if;        
    end process;
    

end Behavioral;
