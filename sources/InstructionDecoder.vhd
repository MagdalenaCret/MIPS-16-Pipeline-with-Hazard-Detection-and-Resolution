----------------------------------------------------------------------------------
-- Universitatea Tehnica Cluj-Napoca
-- Facultatea de Automatica si Calculatoare
-- Calculatoare si Tehnologia Informatiei
-- Student: CRET MARIA-MAGDALENA
-- Grupa 30233 Seria A

-- STRUCTURA SISTEMELOR DE CALCUL
-- PROIECT LABORATOR
-- Rezolvarea Hazardurilor in Mips Pipeline 16
-- Instruction Decoder
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use IEEE.numeric_std.all;

entity InstructionDecoder is
    Port ( 
        clkM: in std_logic;
        instruction: in std_logic_vector(15 downto 0);
        wd: in std_logic_vector(15 downto 0);
        RegWrite: in std_logic;
        RegDstAddress: in std_logic_vector(2 downto 0);
        ExtOp: in std_logic;
        rd1: out std_logic_vector(15 downto 0);
        rd2: out std_logic_vector(15 downto 0);
        imm_extend: out std_logic_vector(15 downto 0);
        func: out std_logic_vector(2 downto 0);
        sa: out std_logic;
        wrt_adr_1: out std_logic_vector(2 downto 0);
        wrt_adr_2: out std_logic_vector(2 downto 0);
        ID_EX_MemRead: in std_logic;
        ID_EX_Rt: in std_logic_vector(2 downto 0);
        IF_ID_WriteEn: out std_logic;
        control_sel: out std_logic;
        enable_pc: out std_logic;
        pc_nxt: in std_logic_vector(15 downto 0);
        instr_branch: in std_logic;
        Branch_Taken: out std_logic;
        branch_addr: out std_logic_vector(15 downto 0);
        EX_WrAddrChosen: in std_logic_vector(2 downto 0);
        ID_EX_RegWrite: in std_logic; 
        EX_MEM_RegWrite: in std_logic;
        EX_MEM_RegDst: in std_logic_vector(2 downto 0);
        EX_MEM_ALUOut: in std_logic_vector(15 downto 0)
        
    );
end InstructionDecoder;

architecture Behavioral of InstructionDecoder is
    component RegisterFile is
        port (
            read_address2: in STD_LOGIC_VECTOR(2 downto 0);
            read_address1: in STD_LOGIC_VECTOR(2 downto 0);
            wrt_adr: in STD_LOGIC_VECTOR(2 downto 0); 
            write_data: in STD_LOGIC_VECTOR(15 downto 0);
            reg_write: in STD_LOGIC;
            clkM: in STD_LOGIC;
            read_data1: out STD_LOGIC_VECTOR(15 downto 0);
            read_data2: out STD_LOGIC_VECTOR(15 downto 0));
    end component;
    
    component HazardDetectionForStall is
        Port (
            ID_Rs: in std_logic_vector(2 downto 0); 
            ID_Rt: in std_logic_vector(2 downto 0); 
            ID_EX_Rt: in std_logic_vector(2 downto 0);
            ID_EX_MemRead: in std_logic; 
            instr_branch: in std_logic;
            ID_EX_RegWrite: in std_logic;
            EX_MEM_RegWrite: in std_logic;
            EX_WrAddrChosen: in std_logic_vector(2 downto 0);
            EX_MEM_WrAddrChosen: in std_logic_vector(2 downto 0);
            IF_ID_WriteEn: out std_logic;
            control_sel: out std_logic;
            enable_pc: out std_logic
        );
    end component;    
    
    component ForwardUnitID is
        Port(
            EX_MEM_RegWrite: in std_logic;
            EX_MEM_RegDst: in std_logic_vector(2 downto 0);
            ID_Branch: in std_logic;
            ID_Rs: in std_logic_vector(2 downto 0);
            ID_Rt: in std_logic_vector(2 downto 0);
            forward_A: out std_logic;
            forward_B: out std_logic
        );
    end component;
    
    signal mux_outp: std_logic_vector(2 downto 0);  
    signal temp_rd1: std_logic_vector(15 downto 0);  
    signal temp_rd2: std_logic_vector(15 downto 0);  
    signal mux_equlA: std_logic_vector(15 downto 0);  
    signal mux_eqalB: std_logic_vector(15 downto 0);  
    signal temp_imm_extend: std_logic_vector(15 downto 0); 
    signal forward_A: std_logic; 
    signal forward_B: std_logic;
begin
    
    wrt_adr_1 <= instruction(9 downto 7);
    wrt_adr_2 <= instruction (6 downto 4);
    
    Register_File: RegisterFile port map(
        read_address2 => instruction(9 downto 7),
		read_address1 => instruction(12 downto 10),
		wrt_adr => RegDstAddress,
		write_data => wd,
		reg_write => RegWrite,
		clkM => clkM,
		read_data1 => temp_rd1,
		read_data2 => temp_rd2);
    
    rd1 <= temp_rd1;
    rd2 <= temp_rd2;
    
    --Eqaulity Multiplexor pentru intrarea A, respectiv intrarea B - decizii cu rezultate de forwarding
    mux_equlA <= EX_MEM_ALUOut when forward_A = '1' else temp_rd1;
    mux_eqalB <= EX_MEM_ALUOut when forward_B = '1' else temp_rd2;
    
    Generation_For_Branch: 
    process(mux_equlA, mux_eqalB, instruction, instr_branch) is 
    begin        
        if instr_branch = '1' then
            if (mux_equlA = mux_eqalB) and instruction(15 downto 13) = "100" then Branch_Taken <= '1';  -- BEQ instr
            elsif (not (mux_equlA = mux_eqalB)) and instruction(15 downto 13) = "110" then Branch_Taken <= '1'; -- BNEQ instr
            else  Branch_Taken <= '0';
            end if;
        else  Branch_Taken <= '0';
        end if;
    end process;
    
    address_branch_adder: branch_addr <= temp_imm_extend + pc_nxt;
    
    extender_unit: 
        temp_imm_extend <= X"00" & '0' & instruction(6 downto 0) when ExtOp = '0' 
        else X"FF" & '1' & instruction(6 downto 0) when instruction(6) = '1' 
        else X"00" & '0'& instruction(6 downto 0);
    
    imm_extend <= temp_imm_extend; 
    func <= instruction(2 downto 0);
    sa <= instruction(3);
    
    Hazard_Detection_For_Stall: HazardDetectionForStall port map (
        ID_Rs => instruction(12 downto 10), 
        ID_Rt => instruction(9 downto 7),
        ID_EX_Rt => ID_EX_Rt,
        ID_EX_MemRead => ID_EX_MemRead,
        instr_branch => instr_branch,
        ID_EX_RegWrite => ID_EX_RegWrite,
        EX_MEM_RegWrite => EX_MEM_RegWrite,
        EX_WrAddrChosen => EX_WrAddrChosen,
        EX_MEM_WrAddrChosen => EX_MEM_RegDst,
        IF_ID_WriteEn => IF_ID_WriteEn,
        control_sel => control_sel,
        enable_pc => enable_pc
    );
    
    Forwarding_Unit_For_ID: ForwardUnitID port map (
        EX_MEM_RegWrite => EX_MEM_RegWrite,
        EX_MEM_RegDst => EX_MEM_RegDst,
        ID_Branch => instr_branch,
        ID_Rs => instruction(12 downto 10),
        ID_Rt => instruction(9 downto 7),
        forward_A => forward_A,
        forward_B => forward_B
    );
    
end Behavioral;
