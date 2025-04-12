----------------------------------------------------------------------------------
-- Universitatea Tehnica Cluj-Napoca
-- Facultatea de Automatica si Calculatoare
-- Calculatoare si Tehnologia Informatiei
-- Student: CRET MARIA-MAGDALENA
-- Grupa 30233 Seria A

-- STRUCTURA SISTEMELOR DE CALCUL
-- PROIECT LABORATOR
-- Rezolvarea Hazardurilor in Mips Pipeline 16
-- Execution Unit
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use IEEE.numeric_std.all;


entity ExecutionUnit is
    Port ( 
        pc_next: in std_logic_vector(15 downto 0);
        rd1: in std_logic_vector(15 downto 0); 
        rd2: in std_logic_vector(15 downto 0);
        ALUSrc: in std_logic;
        imm_extend: in std_logic_vector(15 downto 0);
        sa: in std_logic;
        func: in std_logic_vector(2 downto 0);
        ALUOp: in std_logic_vector(1 downto 0);
        ALURes: out std_logic_vector (15 downto 0);
        EX_MEM_ALUOut: in std_logic_vector(15 downto 0);
        MEM_WB_ALUOut: in std_logic_vector(15 downto 0);
        EX_MEM_RegWrite: in std_logic;
        MEM_WB_RegWrite: in std_logic;
        EX_MEM_RegDst: in std_logic_vector(2 downto 0);
        MEM_WB_RegDst: in std_logic_vector(2 downto 0);
        ID_EX_Rs: in std_logic_vector(2 downto 0);
        ID_EX_Rt: in std_logic_vector(2 downto 0)
    );
end ExecutionUnit;

architecture Behavioral of ExecutionUnit is

    component ExecutionForwarding is
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
    end component;
    signal ALUCtrl: std_logic_vector (2 downto 0);
    signal op_res: std_logic_vector (15 downto 0);
    signal inA_alu: std_logic_vector (15 downto 0);
    signal inB_alu: std_logic_vector (15 downto 0);
   
    signal forward_A: std_logic_vector (1 downto 0);
    signal forward_B: std_logic_vector (1 downto 0);
   
    signal out_forwardB: std_logic_vector (15 downto 0);

 
begin
    
    Execution_Forwarding_Hazard_Detection: ExecutionForwarding port map (
        EX_MEM_RegWrite => EX_MEM_RegWrite,
        MEM_WB_RegWrite => MEM_WB_RegWrite,
        EX_MEM_RegDst => EX_MEM_RegDst,
        MEM_WB_RegDst => MEM_WB_RegDst,
        ID_EX_Rs => ID_EX_Rs,
        ID_EX_Rt => ID_EX_Rt,
        forward_A => forward_A,
        forward_B => forward_B
    ); 
    -- Multiplexer forwarding A
    process (forward_A, rd1, EX_MEM_ALUOut, MEM_WB_ALUOut)
        begin
           case forward_A is
              when "00" => inA_alu <= rd1;
              when "01" => inA_alu <= EX_MEM_ALUOut;
              when "10" => inA_alu <= MEM_WB_ALUOut;
              when others => inA_alu <= rd1;
           end case;
    end process;
    --Multiplexer forwarding B                 
    process (rd1, rd2, forward_B, EX_MEM_ALUOut, MEM_WB_ALUOut)
        begin
           case forward_B is
              when "00" => out_forwardB <= rd2;
              when "01" => out_forwardB <= EX_MEM_ALUOut;
              when "10" => out_forwardB <= MEM_WB_ALUOut;
              when others => out_forwardB <= rd2;
           end case;
    end process;
        
    inB_alu <= imm_extend when ALUSrc = '1' else out_forwardB;   --multiplexer
   
    ALURes <= op_res;   
   
    ALU_control: process(func, ALUOp)
    begin
        if ALUOp = "10" then 
            case (func) is
                when "001" => ALUCtrl <= "001"; -- ADD 
                when "010" => ALUCtrl <= "010"; -- SUB
                when "101" => ALUCtrl <= "101"; -- AND 
                when "110" => ALUCtrl <= "110"; -- OR
                when "111" => ALUCtrl <= "111"; -- XOR
                when "011" => ALUCtrl <= "011"; -- SLL 
                when "100" => ALUCtrl <= "100"; -- SRL
                when others => ALUCtrl <= "000"; -- nicio operatie, starea initiala
            end case;         
        else
            case(ALUOp) is 
                when "10" => ALUCtrl <= "010"; -- SUBI
                when "00" => ALUCtrl <= "001"; -- ADI
                when others => ALUCtrl <= "000";
            end case;
        end if;
    end process;
    
    ALU_component: process(ALUCtrl,sa, imm_extend, inA_alu, inB_alu)
    begin
        case(ALUCtrl) is 
            -- ADD
            when "001" => op_res <= inA_alu + inB_alu; 
            -- SUB
            when "010" => op_res <= inA_alu - inB_alu; 
            -- AND
            when "101" => op_res <= inA_alu and inB_alu;
            -- OR
            when "110" => op_res <= inA_alu or inB_alu;
            -- XOR
            when "111" => op_res <= inA_alu xor inB_alu;
            -- SRL
            when "100" => 
                if(sa = '1') then
                    op_res <= '0' & inA_alu(15 downto 1);
                else
                    op_res <= inA_alu;
                end if;
          
            -- SLL
            when "011" => 
                if(sa = '1') then
                    op_res <= inA_alu(14 downto 0) & '0';
                else
                    op_res <= inA_alu;
                end if;
            when others => op_res <= x"0000";
        end case;
    end process;
 
end Behavioral;
