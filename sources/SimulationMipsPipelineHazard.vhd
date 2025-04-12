
---------------------------------------------------------------------------------
-- Universitatea Tehnica Cluj-Napoca
-- Facultatea de Automatica si Calculatoare
-- Calculatoare si Tehnologia Informatiei
-- Student: CRET MARIA-MAGDALENA
-- Grupa 30233 Seria A

-- STRUCTURA SISTEMELOR DE CALCUL
-- PROIECT LABORATOR
-- Rezolvarea Hazardurilor in Mips Pipeline 16
-- Fisierul care port mapeaza toate componentele unui mips pipeline implementat
-- unitatile de detectie si rezolvare a hazardurilor (structurale, de date si de control) 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use IEEE.numeric_std.all;

entity SimulationMipsPipelineHazard is
    Port ( 
        clk: in std_logic;
        reset: in std_logic );
end SimulationMipsPipelineHazard;

architecture Behavioral of SimulationMipsPipelineHazard is
-------------------------------------------------------
-- Partea in care se declara componentele Mips Pipeline
-------------------------------------------------------
    component InstructionFetch is
        Port (
            clkM: in std_logic;
            address_branch: in std_logic_vector(15 downto 0);
            rst: in std_logic;
            enb: in std_logic; 
            instruction: out std_logic_vector(15 downto 0);
            pc_increm1: out std_logic_vector(15 downto 0);
            ID_prv_pc: in std_logic_vector(3 downto 0);
            ID_pc_increm1: in std_logic_vector(15 downto 0);
            ID_Flush: in std_logic;
            ID_Branch_Taken: in std_logic;
            ID_Pred: in std_logic;
            ID_instr_branch: in std_logic;
            prediction: out std_logic;
            curr_program_counter: out std_logic_vector(3 downto 0)    
        );
    end component;
    
    component InstructionDecoder is
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
            ID_EX_Rt: in std_logic_vector(2 downto 0);  -- Hazard Detection unit
            IF_ID_WriteEn: out std_logic;
            control_sel: out std_logic;
            enable_pc: out std_logic;
            pc_nxt: in std_logic_vector(15 downto 0);
            instr_branch: in std_logic;
            Branch_Taken: out std_logic;    -- Branch Detection
            branch_addr: out std_logic_vector(15 downto 0);
            EX_WrAddrChosen: in std_logic_vector(2 downto 0);
            ID_EX_RegWrite: in std_logic;
            EX_MEM_RegWrite: in std_logic;
            EX_MEM_RegDst: in std_logic_vector(2 downto 0);
            EX_MEM_ALUOut: in std_logic_vector(15 downto 0)
        );
    end component;
    
    component ControlComponent is
      Port ( 
        opcode: in std_logic_vector (2 downto 0);
        func: in std_logic_vector (2 downto 0);
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
    end component;
    
    component ExecutionUnit is
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
    end component;
    
    component MemoryUnit is
        Port ( 
            clkM: in std_logic;
            MemWrite: in std_logic;
            MemRead: in std_logic;
            ALURes: in std_logic_vector (15 downto 0);
            RD2: in std_logic_vector (15 downto 0);
            ALURes_out: out std_logic_vector (15 downto 0);
            MemData: out std_logic_vector (15 downto 0);
            MEM_WB_RegWrite: in std_logic;
            WB_BUF_RegWrite: in std_logic;
            EX_MEM_Rt: in std_logic_vector(2 downto 0);
            WB_BUF_RegDst: in std_logic_vector(2 downto 0);
            MEM_WB_RegDst: in std_logic_vector(2 downto 0);
            MEM_WB_RegData: in std_logic_vector(15 downto 0);
            WB_BUF_RegData: in std_logic_vector(15 downto 0)
        );
    end component;
    

-- DECLARARE SEMNALE INTERNE
    
    --outputs Ifetch
    signal IF_instr: std_logic_vector(15 downto 0) := (others => '0');
    signal IF_pc_increm1: std_logic_vector(15 downto 0):= (others => '0');
    signal IF_curr_program_counter: std_logic_vector(3 downto 0):= (others => '0');
    signal IF_prediction: std_logic := '0';
    
        --outputs instruction Decoder
    signal ID_rd1: std_logic_vector(15 downto 0):= (others => '0');
    signal ID_rd2: std_logic_vector(15 downto 0):= (others => '0');
    signal ID_imm_extend: std_logic_vector(15 downto 0):= (others => '0');
    signal ID_Branch_Taken: std_logic := '0';
    signal ID_branch_addr: std_logic_vector(15 downto 0):= (others => '0');
    signal ID_wr_addr1: std_logic_vector(2 downto 0):= (others => '0');
    signal ID_wr_addr2: std_logic_vector(2 downto 0):= (others => '0');
    signal IF_ID_WriteEn: std_logic := '0';
    signal control_sel: std_logic := '0';
    signal enable_pc: std_logic := '0';
    signal ID_sa: std_logic := '0';
    signal ID_func: std_logic_vector(2 downto 0):= (others => '0');
    
        -- outputs Execution Unit
    signal EX_ALU_out: std_logic_vector(15 downto 0):= (others => '0');
    signal EX_wr_addr: std_logic_vector(2 downto 0):= (others => '0');
    
    --outputs Memory Unit
    signal MEM_ALU_out: std_logic_vector(15 downto 0):= (others => '0');
    signal MEM_data_out: std_logic_vector(15 downto 0):= (others => '0');    
    
    -- semnale Ctrl Unit
    signal RegWrite_Ctrl: std_logic;
    signal AluOpe_Ctrl: std_logic_vector(1 downto 0):= (others => '0');   
    signal Branch_Ctrl: std_logic := '0';
    signal Jump_Ctrl: std_logic := '0';
    signal MemRead_Ctrl: std_logic := '0';
    signal RegWrite_CtrlValid: std_logic := '0';
    signal RegDst_Ctrl: std_logic := '0';
    signal ExtOp_Ctrl: std_logic := '0';
    signal Alu_Src_Ctrl: std_logic := '0';
    signal MemWrite_Ctrl: std_logic := '0';
    signal MemWrite_CtrlEnable: std_logic := '0';
    signal MemToReg_Ctrl: std_logic := '0';

    signal Flush: std_logic;
    
    signal MUXOut_RegDst_Ctrl: std_logic := '0';
    signal MUXOut_ExtOp_Ctrl: std_logic := '0';
    signal MUXOut_RegWrite_Ctrl: std_logic := '0';
    signal MUXOut_RegWrite_CtrlValid: std_logic := '0';
    signal MUXOut_Alu_Src_Ctrl: std_logic := '0';   -- after FLUSH operation
    signal MUXOut_Branch_Ctrl: std_logic := '0';
    signal MUXOut_Jump_Ctrl: std_logic := '0';
    signal MUXOut_MemRead_Ctrl: std_logic := '0';
    signal MUXOut_MemWrite_Ctrl: std_logic := '0';
    signal MUXOut_MemWrite_CtrlEnable: std_logic := '0';
    signal MUXOut_MemToReg_Ctrl: std_logic := '0';
    signal MUXOut_AluOpe_Ctrl: std_logic_vector(1 downto 0):= (others => '0');   

    -- Write Back Stage
    signal WB_w_data: std_logic_vector(15 downto 0):= (others => '0');
    

------------------------------------------------------------
----------------- ETAPELE PIPELINE -------------------------
-- Obs: Ordinea de codificare pe biti (se utilizeaza vectori de dimensiuni mari, pentru fiecare etapa a pipeline ul (etaj, mai bine zis), 
-- astfel incat fiecarui patratel din etajul  pipelineului sa i se atribuie output din etapa din care pleaca, pentru a fi stocat pentru etapa in care ajunge
-- Ordinea este MSB (Most Significant Bit) <- LSB (Less Significant Bit)
------------------------------------------------------------
    signal IF_ID: std_logic_vector(36 downto 0):= (others => '0');
    
    
    --  MSB_Pred  | Current_PC 
    --  ---------- | ------------    -- Predictie dinamica
    -- 36        35           31
    
    --   Instruction | PC + 1 
    --  ------------ | ------
    --  31           15       0
  
    
    signal ID_EX: std_logic_vector(88 downto 0):= (others => '0');
    
   
    --  WB CTRL |  MEM CTRL | EX CTRL | PC + 1 |   RD1   |   RD2   | imm_extend | Wr_Add1 | Wr_addr2 | sa | func
    --  -------- | --------- | ------- | ------ | ------- | ------- | ---------- | ------- | -------- | -- | -----
    -- 82       80           77       73       57        41         25        9         6          3    2      0
    
    -- Forward Unit  
    -- 
    --  RS Address | RT Address | WB CTRL  
    --  ----------- | ---------- | -------   WB ctrl: regwrite - 81, memtoreg - 82  MEM ctrl: branch - 78, memread - 80, memwrite - 79 
    -- 88          85            82
   -- EX ctrl: RegDst - 74,  ALUOp - 77 downto 76, AluSrc - 75

 
    
    signal EX_MEM: std_logic_vector(59 downto 0):= (others => '0');
    
    --  | WB CTRL | mem CTRL |  address_branch  |  zero  | ALU_out |   RD2   |   Wr_Add_chosen  
    --  --------- | -------- | ---------------- | ------ | ------- | ------- | -------------------
    --  56       54          51              35        34        18        2                   0
    

    -- | RT Address | WB CTRL ...
    --  ----------- | ------------
    -- 59          56
    
    signal MEM_WB: std_logic_vector(36 downto 0):= (others => '0');
    
    --  WB CTRL | Wr_Add_chosen | mem Data Out |  ALU Out 
    --  ------- |  ------------- |  ------------ |  ----------
    -- 36        34             31             15         0
    
    signal WB_BUF: std_logic_vector(19 downto 0) := (others => '0'); -- save the WB data for MEM FWD unit
   
    --  RegWrite | Wr_Add_chosen | WriteBack_mux_Out 
    --  -------- |  ------------- |  --------------
    -- 19         18             15                0
       
begin

    Connection_For_Instruction_Fetch: InstructionFetch port map (
        clkM => clk,
        address_branch => ID_branch_addr,
        rst => reset,
        enb => enable_pc, 
        instruction => IF_instr,
        pc_increm1  => IF_pc_increm1,
        ID_pc_increm1 => IF_ID(15 downto 0),
        ID_prv_pc => IF_ID(35 downto 32),
        ID_Flush => Flush,
        ID_Branch_Taken => ID_Branch_Taken,
        ID_Pred => IF_ID(36),
        ID_instr_branch => MUXOut_Branch_Ctrl, 
        prediction => IF_prediction,
        curr_program_counter => IF_curr_program_counter    
    );
    
    -- control unit flush 
        process (control_sel, RegDst_Ctrl, ExtOp_Ctrl, Alu_Src_Ctrl, Branch_Ctrl, Jump_Ctrl, AluOpe_Ctrl, MemRead_Ctrl, MemWrite_Ctrl, MemToReg_Ctrl, RegWrite_Ctrl) is
    begin
            MUXOut_AluOpe_Ctrl <= AluOpe_Ctrl;
            MUXOut_RegWrite_Ctrl <= RegWrite_Ctrl;
            MUXOut_RegWrite_CtrlValid <= RegWrite_CtrlValid;
            MUXOut_RegDst_Ctrl <= RegDst_Ctrl;
            MUXOut_ExtOp_Ctrl <= ExtOp_Ctrl;
            MUXOut_Branch_Ctrl <= Branch_Ctrl;
            MUXOut_Jump_Ctrl <= Jump_Ctrl;
            MUXOut_Alu_Src_Ctrl <= Alu_Src_Ctrl;
            MUXOut_MemRead_Ctrl <= MemRead_Ctrl;
            MUXOut_MemWrite_Ctrl <= MemWrite_Ctrl;
            MUXOut_MemWrite_CtrlEnable <= MemWrite_CtrlEnable;
            MUXOut_MemToReg_Ctrl <= MemToReg_Ctrl;
        if control_sel = '0' then
            MUXOut_AluOpe_Ctrl <= "11";
            MUXOut_RegWrite_Ctrl <= '0';
            MUXOut_RegWrite_CtrlValid <= '0';
            MUXOut_RegDst_Ctrl <= '0';
            MUXOut_ExtOp_Ctrl <= '0';
            MUXOut_Branch_Ctrl <= '0';
            MUXOut_Jump_Ctrl <= '0';
            MUXOut_Alu_Src_Ctrl <= '0';
            MUXOut_MemRead_Ctrl <= '0';
            MUXOut_MemWrite_Ctrl <= '0';
            MUXOut_MemWrite_CtrlEnable <= '0';
            MUXOut_MemToReg_Ctrl <= '0';
        end if;
    end process;
    
    Flush <= ID_Branch_Taken xor IF_ID(36);
    
    StageIFetch_to_StageInstructionDecoder: process(reset, clk) is 
    begin
        if reset = '1' then
            IF_ID(36 downto 0) <= (others => '0');
        elsif rising_edge(clk) and IF_ID_WriteEn = '1' then
            if Flush = '1' then
                IF_ID(36 downto 0) <= (others => '0');    
            else
                IF_ID(36) <= IF_prediction;
                IF_ID(35 downto 32) <= IF_curr_program_counter;
                IF_ID(31 downto 16) <= IF_instr;
                IF_ID(15 downto 0) <= IF_pc_increm1;
            end if;
        end if;
    end process;    
    
    Connection_For_Instruction_Decoder: InstructionDecoder port map (
        clkM => clk,
        instruction => IF_ID(31 downto 16),
        RegWrite => MEM_WB(35),
        RegDstAddress => MEM_WB(34 downto 32), 
        ExtOp => MUXOut_ExtOp_Ctrl,
        wd => WB_w_data,
        rd1 => ID_rd1,
        rd2 => ID_rd2,
        imm_extend => ID_imm_extend,
        func => ID_func,
        pc_nxt => IF_ID(15 downto 0),
        sa => ID_sa,
        Branch_Taken => ID_Branch_Taken,
        branch_addr => ID_branch_addr,
        EX_WrAddrChosen => EX_wr_addr,
        ID_EX_MemRead => ID_EX(80),
        ID_EX_Rt => ID_EX(85 downto 83),
        IF_ID_WriteEn => IF_ID_WriteEn,
        control_sel => control_sel,
        enable_pc => enable_pc,
        instr_branch => Branch_Ctrl,
        ID_EX_RegWrite => ID_EX(81),
        EX_MEM_RegWrite => EX_MEM(55),
        wrt_adr_1 => ID_wr_addr1,
        wrt_adr_2 => ID_wr_addr2,
        EX_MEM_RegDst => EX_MEM(2 downto 0),
        EX_MEM_ALUOut => EX_MEM(34 downto 19)
    );
    
    Connection_For_Control_Unit: ControlComponent port map(
        opcode => IF_ID(31 downto 29),
        func => IF_ID(18 downto 16),
        RegDst => RegDst_Ctrl,
        ExtOp => ExtOp_Ctrl,
        ALUSrc => Alu_Src_Ctrl,
        Branch => Branch_Ctrl,
        Jump => Jump_Ctrl,
        ALUOp => AluOpe_Ctrl,
        MemRead => MemRead_Ctrl,
        MemWrite => MemWrite_Ctrl,
        MemtoReg => MemToReg_Ctrl,
        RegWrite => RegWrite_Ctrl
    );
    

    
    StageInstructionDecoder_to_StageExecution: process(reset, clk) is
    begin
        if reset = '1' then
            ID_EX(88 downto 0) <= (others => '0');
        elsif rising_edge(clk) then
            ID_EX(88 downto 86)<= IF_ID(28 downto 26); -- din ifetch spre idecoder reprezinta Rt
            ID_EX(85 downto 83) <= IF_ID(25 downto 23); -- din ifetch spre idecoder reprezinta Rs
            ID_EX(82) <= MUXOut_MemToReg_Ctrl;
            ID_EX(81) <= MUXOut_RegWrite_Ctrl;
            ID_EX(80) <= MUXOut_MemRead_Ctrl;
            ID_EX(79) <= MUXOut_MemWrite_Ctrl;
            ID_EX(78) <= MUXOut_Branch_Ctrl;
            ID_EX(77 downto 76) <= MUXOut_AluOpe_Ctrl;
            ID_EX(75) <= MUXOut_Alu_Src_Ctrl;
            ID_EX(74) <= MUXOut_RegDst_Ctrl;
            ID_EX(73 downto 58) <= IF_ID(15 downto 0);
            ID_EX(57 downto 42) <= ID_rd1;
            ID_EX(41 downto 26) <= ID_rd2;
            ID_EX(25 downto 10) <= ID_imm_extend;
            ID_EX(9 downto 7) <= ID_wr_addr1;
            ID_EX(6 downto 4) <= ID_wr_addr2;
            ID_EX(3) <= ID_sa;
            ID_EX(2 downto 0) <= ID_func;
        end if;
    end process;
    
    Connection_For_Execution_Unit: ExecutionUnit port map (
        pc_next => ID_EX(73 downto 58),
        rd1 => ID_EX(57 downto 42),
        rd2 => ID_EX(41 downto 26),
        ALUSrc => ID_EX(75),
        ALUOp => ID_EX(77 downto 76),
        ALURes => EX_ALU_out,
        imm_extend => ID_EX(25 downto 10),
        sa => ID_EX(3),
        func => ID_EX(2 downto 0),
        EX_MEM_ALUOut => EX_MEM(34 downto 19),
        MEM_WB_ALUOut => WB_w_data, 
        EX_MEM_RegWrite => EX_MEM(55),
        MEM_WB_RegWrite => MEM_WB(35),
        MEM_WB_RegDst => MEM_WB(34 downto 32),
        EX_MEM_RegDst => EX_MEM(2 downto 0),
        ID_EX_Rs => ID_EX(88 downto 86),
        ID_EX_Rt => ID_EX(85 downto 83) );
    
    StageExecution_to_StageMemory:
     process(reset, clk) is
    begin
        if reset = '1' then
            EX_MEM(59 downto 0) <= (others => '0');
        elsif rising_edge(clk) then
            EX_MEM(59 downto 57) <= ID_EX(85 downto 83); 
            EX_MEM(56 downto 55) <= ID_EX(82 downto 81);
            EX_MEM(54 downto 52) <= ID_EX(80 downto 78);
            EX_MEM(51 downto 36) <= X"0000"; 
            EX_MEM(35) <= '0'; 
            EX_MEM(34 downto 19) <= EX_ALU_out;
            EX_MEM(18 downto 3) <= ID_EX(41 downto 26);
            EX_MEM(2 downto 0) <= EX_wr_addr;
        end if;    
    end process;
     EX_wr_addr <= ID_EX(9 downto 7) when ID_EX(74) = '0' else ID_EX(6 downto 4);
     
    Connection_For_Memory_Unit: MemoryUnit port map(
        clkM => clk,
        MemWrite => EX_MEM(53),
        MemRead => EX_MEM(54), 
        ALURes => EX_MEM(34 downto 19), 
        RD2 => EX_MEM(18 downto 3),
        ALURes_out => MEM_ALU_out,
        MemData => MEM_data_out,
        MEM_WB_RegWrite => MEM_WB(35),
        WB_BUF_RegWrite => WB_BUF(19),
        EX_MEM_Rt => EX_MEM(59 downto 57),
        WB_BUF_RegDst => WB_BUF(18 downto 16),
        MEM_WB_RegDst => MEM_WB(34 downto 32),
        MEM_WB_RegData => WB_w_data,
        WB_BUF_RegData => WB_BUF(15 downto 0));
    
    STageMem_to_StageWB: 
    process(reset, clk) is
    begin
        if reset = '1' then
            MEM_WB(36 downto 0) <= (others => '0');
        elsif rising_edge(clk) then
            MEM_WB(36 downto 35) <= EX_MEM(56 downto 55);
            MEM_WB(34 downto 32) <= EX_MEM(2 downto 0);
            MEM_WB(31 downto 16) <= MEM_data_out;
            MEM_WB(15 downto 0) <= MEM_ALU_out;
        end if;
    end process;
    
   -- WB buffer
        process(reset, clk) is
    begin
        if reset = '1' then
            WB_BUF(19 downto 0) <= (others => '0');
        elsif rising_edge(clk) then
            WB_BUF(19) <= MEM_WB(35);
            WB_BUF(18 downto 16) <= MEM_WB(34 downto 32);
            WB_BUF(15 downto 0) <= WB_w_data;
        end if;
    end process;
    -- etapa finala de write back formata dintr un multiplexor pentru decizia asupra modului in care va fi scris rezultatul (in registru inapoi sau in memorie)
    WB_w_data <= MEM_WB(31 downto 16) when MEM_WB(36) = '1' else MEM_WB(15 downto 0);
        

    
end Behavioral;