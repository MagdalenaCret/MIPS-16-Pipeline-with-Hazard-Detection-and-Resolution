----------------------------------------------------------------------------------
-- Universitatea Tehnica Cluj-Napoca
-- Facultatea de Automatica si Calculatoare
-- Calculatoare si Tehnologia Informatiei
-- Student: CRET MARIA-MAGDALENA
-- Grupa 30233 Seria A

-- STRUCTURA SISTEMELOR DE CALCUL
-- PROIECT LABORATOR
-- Rezolvarea Hazardurilor in Mips Pipeline 16
-- Control Unit for the process of representing machine-level instructions 
-- in a specific format (R-type, J-Type, I-Type)
---------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use IEEE.numeric_std.all;

entity ControlComponent is
  Port ( 
    opcode: in std_logic_vector (2 downto 0);
    func: in std_logic_vector(2 downto 0);
    RegDst: out std_logic;
    ExtOp: out std_logic;
    ALUSrc: out std_logic;
    Branch: out std_logic;
    Jump: out std_logic;
    ALUOp: out std_logic_vector(1 downto 0);
    MemRead: out std_logic;
    MemWrite: out std_logic;
    MemtoReg: out std_logic;
    RegWrite: out std_logic);
end ControlComponent;

architecture Behavioral of ControlComponent is
    signal control_decision: std_logic_vector (10 downto 0);
begin
    output_computation: process(opcode, func)
    begin
        case opcode is
            when "000" =>
                
                control_decision <= "10000100001"; -- R-type instruction 
                -- RegDst=1, ALUOp=11, RegWrite=1
                
                if func = "000" then
                    control_decision <= "00000000000";    
                end if;
            
            when "001" => 
                control_decision <= "01100000001"; -- Addi
            -- ExtOp=1, ALUSrc=1, ALUOp=10, RegWrite=1
            when "101" => 
                control_decision <= "01100100001"; -- Subi 
            -- ExtOp=1, ALUSrc=1, ALUOp=10, RegWrite=1
            when "010" => 
                control_decision <= "01100001011"; -- Lw
            -- ExtOp=1, ALUSrc=1, ALUOp=10, MemtoReg=1, RegWrite=1
            when "011" => 
                control_decision <= "01100000100"; -- Sw
            -- ExtOp=1, ALUSrc=1, ALUOp=10, MemWrite=1
            when "100" => 
                control_decision <= "11010110000"; -- Beq
                -- ExtOp=1, Branch=1, ALUOp=01
            when "110" => 
                control_decision <= "11010110000"; -- Bneq
                -- ExtOp=1, Branch=1, ALUOp=01
            when "111" => 
                control_decision <= "11101000000"; -- Jump va fi 1
            when others => 
                control_decision <= "00000000000"; --nU ar trebui sa intre aici
        end case;
    end process;

    -- Asignarea tipului de instuctiune unui semnal pentru Mips Pipeline pentru partajarea
    -- acestora de la un etaj la altul
    -- Atribuirile de mai jos leaga fiecare semnal de iesire (RegDst, ExtOp, AluOp si asa mai departe) 
    --la bitii corespunzatori dintr-un semnal intermediar, care este control_decision.
    --Fiecare semnal de ie?ire preia valoarea unui bit specific din acest control_decision, care este un std logic vector
    RegDst <= control_decision(10);
    ExtOp <= control_decision(9);
    ALUSrc <= control_decision(8);
    Branch <= control_decision(7);
    Jump <= control_decision(6);
    ALUOp <= control_decision(5 downto 4);
    MemRead <= control_decision(3);
    MemWrite <= control_decision(2);
    MemtoReg <= control_decision(1);
    RegWrite <= control_decision(0);
    
end Behavioral; 