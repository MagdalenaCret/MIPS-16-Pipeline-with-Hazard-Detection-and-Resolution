----------------------------------------------------------------------------------
-- Universitatea Tehnica Cluj-Napoca
-- Facultatea de Automatica si Calculatoare
-- Calculatoare si Tehnologia Informatiei
-- Student: CRET MARIA-MAGDALENA
-- Grupa 30233 Seria A

-- STRUCTURA SISTEMELOR DE CALCUL
-- PROIECT LABORATOR
-- Rezolvarea Hazardurilor in Mips Pipeline 16
-- Instruction Fetch
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
entity InstructionFetch is
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
        
end InstructionFetch;

architecture Behavioral of InstructionFetch is

    component BranchHistoryTable is
        Port ( 
            clk: in std_logic; 
            address: in std_logic_vector(3 downto 0); 
            update_data: in std_logic_vector(15 downto 0); 
            wrt_adr: in std_logic_vector(3 downto 0); 
            inc_predictor: in std_logic;
            pc_enable: in std_logic;
            instr_branch: in std_logic;
            flush: in std_logic;
            MSB_Pred: out std_logic;
            predT: out std_logic_vector(15 downto 0)
        );
    end component;

    signal nxt_pc: std_logic_vector(15 downto 0);
    signal curr_pc_cont: std_logic_vector(15 downto 0);
    
    signal out_of_2mux: std_logic_vector(15 downto 0);
    signal out_of_1mux: std_logic_vector(15 downto 0);
    signal predT: std_logic_vector(15 downto 0);
    signal instruction_mem: std_logic_vector(15 downto 0);
    signal MSB_Pred: std_logic;
    signal add_pc_cr: std_logic_vector(15 downto 0);
    signal ID_Pred_ID_Br_Taken: std_logic_vector(1 downto 0);
    signal jump_if: std_logic;
    signal jump_addr_if: std_logic_vector(15 downto 0);
    
    
  
   -- Cerinta care respecta toate tipurile de hazarduri
--  Daca un element este mai mic decat X, se inlocuieste cu rezultatul impartirii intregi la 2.
--  Daca un element este intre X ?i Y (inclusiv), se inlocuie?te cu dublul sau.
--  Daca un element este mai mare decat Y, se inlocuieste cu valoarea 1.
--      Constrangeri:
--  Sirul incepe de la adresa A (A <= 4) si are N elemente.
--  Valorile A, N, X si Y se citesc din memorie de la adresele 0, 1, 2 si respectiv 3.
--  Se stie ca X <= Y intotdeauna.

-- Rezolvare in instructiuni assembly pentru MIPS
--        # initializare registrii utilizati
--        xor $1, $0, 0           # initializeaza $1 (A, adresa de inceput a sirului)
--        xor $2, $0, 0           # initializeaza $2 (N, numarul de elemente)
--        xor $3, $0, 0           # initializeaza $3 (X, limita inferioara)
--        xor $4, $0, 0           # initializeaza $4 (Y, limita superioara)
--        xor $10, $0, 0         # initializeaza $10 (contor pentru bucla)

--        # Citire A, N, X, Y din memorie
--        lw $1, 0($1)             # A = mem[0]
--        lw $2, 1($2)             # N = mem[1]
--        lw $3, 2($3)             # X = mem[2]
--        lw $4, 3($4)             # Y = mem[3]

--   loop:
--        # se verifica daca s-au parcurs toate elementele
--        addi $10, $10, 1         # $10 = i++ 
--        beq $10, $2, done        # Daca $10 == n se iese din bucla, n - nr de elememente

--        # Citire element din sir (adresa curenta este $1)
--        lw $5, 0($1)             # $5 este elem curent sir

--        # Verifica daca $5 < X
--        slt $6, $5, $3           # $6 = 1 daca $5 < X, altfel 0
--        beq $6, $zero, verif  
--        # Daca $5 > = X, se va trece la verificarea intervalului
--        # Daca $5 < X, imparte la 2
--        srl $5, $5, 1            # impartire la 2 realizata cu shiftarea la dreapta cu 1 bit
--        sw $5, 0($1)             # Salveaza rezultatul inapoi in memorie
--        j loop                   # Revine la urmatorul element

--   verif:
--        # Verifica daca X <= $5 <= Y
--        slt $6, $3, $5           # $6 = 1 daca X <= $5, altfel 0
--        slt $7, $5, $4           # $7 = 1 daca $5 <= Y, altfel 0
--        and $8, $6, $7           # $8 = 1 daca X <= $5 <= Y, altfel 0
--        beq $8, $zero, greater_than_Y # Daca nu este in interval, trece la verificarea > Y

--        # Daca X <= $5 <= Y, se va dubla elementul curent
--        sll $5, $5, 1            # inmultire realizat prin shiftare la stanga cu 1 bit
--        sw $5, 0($1)             # Salveaza rezultatul inapoi in memorie
--        j loop                   # Revine la urmatorul element

--    mai_mare_ca_Y:
--        # Daca $5 > Y, seteaza-l la 1
--        li $5, 1                 # $5 = 1
--        sw $5, 0($1)             # se salveaza rezultatul inapoi in memorie
--        j loop                   # se revine la elem urmator

-- final: -- se iese din program, am decis sa nu mai implementez o bucla de afisare,
-- dat fiind faptul ca nu s-a reusit pusul pe placa Basys3, atunci ar fi facut programul 
-- sa fie mult prea lung. Important este sa se observe detectia si rezolvarea hazardurilor in simulare
    type rom_content is array(0 to 255) of std_logic_vector(15 downto 0);   
--    signal memory_rom: rom_content := ( 
--    B"000_001_000_000_0_111",  -- xor $1, $0, $0
--    B"000_010_000_000_0_111",  -- xor $2, $0, $0
--    B"000_011_000_000_0_111",  -- xor $3, $0, $0
--    B"000_100_000_000_0_111",  -- xor $4, $0, $0
--    B"000_101_000_000_0_111",  -- xor $10, $0, $0
--    B"010_001_000_0000000",   -- lw $1, 0($1)
--    B"010_010_001_0000001",   -- lw $2, 1($2)
--    B"010_011_010_0000010",   -- lw $3, 2($3)
--    B"010_100_011_0000011",   -- lw $4, 3($4) -- loop: de aici in jos
--    B"001_010_010_0000001",   -- addi $10, $10, 1
--    B"100_010_101_1111010",   -- beq $10, $2, FINAL  
--    B"010_101_010_0000000",   -- lw $5, 0($1)
--    B"000_101_011_110_0_010",  -- sub $6, $5, $3
--    B"000_110_110_110_0_101",  -- and $6, $6, $6
--    B"100_110_110_1111100",   -- beq $6, $zero, verif
--    B"000_101_101_000_0_100", -- srl $5, $5, 1
--    B"011_101_010_0000000",   -- sw $5, 0($1)
--    B"111_0000000000010",     -- j loop (se numara de la inceput pana unde incepe loop-ul)
--    B"000_011_011_110_0_010",  -- sub $6, $3, $5 
--    B"000_110_110_110_00100",  -- srl $6, $6, $6
--    B"000_101_100_111_0_010",  -- sub $7, $5, $4
--    B"000_110_111_111_0_100",   -- srl $7, $7, $7
--    B"001_110_110_111_0_101",  -- and $8, $6, $7
--    B"100_111_110_1111000",   -- beq $8, $zero, mai mare ca Y
--    B"000_101_101_000_0_011", -- sll $5, $5, 1
--    B"011_101_010_0000000",   -- sw $5, 0($1)
--    B"111_0000000000010",     -- j loop
--    B"001_000_010_0000001",   --  addi $5, $0, 1
--    B"011_101_010_0000000",   -- sw $5, 0($1)
--    B"111_0000000000010",     -- j loop
--    B"111_0000000000000",
--    others => (others => '0') );
signal memory_rom: rom_content := ( 
    x"0487",  -- xor $1, $0, $0
    x"0507",  -- xor $2, $0, $0
    x"0587",  -- xor $3, $0, $0
    x"0607",  -- xor $4, $0, $0
    x"0A87",  -- xor $10, $0, $0
    x"4800",  -- lw $1, 0($1)
    x"4901",  -- lw $2, 1($2)
    x"4A02",  -- lw $3, 2($3)
    x"4B03",  -- lw $4, 3($4)
    x"2410",  -- addi $10, $10, 1
    x"541A",  -- beq $10, $2, FINAL
    x"4A00",  -- lw $5, 0($1)
    x"0B0A",  -- sub $6, $5, $3
    x"0D68",  -- and $6, $6, $6
    x"55C0",  -- beq $6, $zero, verif
    x"0A44",  -- srl $5, $5, 1
    x"4A00",  -- sw $5, 0($1)
    x"E002",  -- j loop
    x"0B02",  -- sub $6, $3, $5
    x"0D24",  -- srl $6, $6, 1
    x"0BC2",  -- sub $7, $5, $4
    x"0F24",  -- srl $7, $7, 1
    x"17A5",  -- and $8, $6, $7
    x"5780",  -- beq $8, $zero, mai mare ca Y
    x"0A83",  -- sll $5, $5, 1
    x"4A00",  -- sw $5, 0($1)
    x"E002",  -- j loop
    x"2410",  -- addi $5, $0, 1
    x"4A00",  -- sw $5, 0($1)
    x"E002",  -- j loop
    x"F000",  -- j FINAL
    others => (others => '0') );
    
begin   
    pc: process(clkM, rst) is
    begin
        if(rst = '1') then
            curr_pc_cont <= x"0000";
        elsif rising_edge(clkM) then
            if(enb = '1') then
                curr_pc_cont <= nxt_pc;
            end if;
        end if;
    end process;
    
    Connection_For_Branch_History_Table: BranchHistoryTable port map (
        clk => clkM,
        address => curr_pc_cont(3 downto 0),
        update_data => address_branch,
        wrt_adr => ID_prv_pc,
        inc_predictor => ID_Branch_Taken, 
        pc_enable => enb,
        instr_branch => ID_instr_branch,
        flush => ID_Flush,
        MSB_Pred => MSB_Pred,
        predT => predT
    );
    
    instruction_mem <= memory_rom(to_integer(unsigned(curr_pc_cont(7 downto 0))));
    
    instruction <= instruction_mem;
   
    -- next address computation
    add_pc_cr <= curr_pc_cont + "1";
    pc_increm1 <= add_pc_cr;
    
    EXT_WITH_ZERO: jump_addr_if <= "000" & instruction_mem(12 downto 0);
    
    BranchHIstoryTable_Mltiplexer: 
        out_of_1mux <= predT 
            when MSB_Pred = '1' 
                else add_pc_cr;
        
    ID_Pred_ID_Br_Taken <= ID_pred & ID_Branch_Taken;
    
    Multiplexer1: process (address_branch, ID_Pred_ID_Br_Taken, out_of_1mux, ID_pc_increm1) is
    begin
        case ID_Pred_ID_Br_Taken is 
            when "00" => 
                      out_of_2mux <= out_of_1mux;
            when "01" => 
                      out_of_2mux <= address_branch;
            when "10" => 
                      out_of_2mux <= ID_pc_increm1;
            when "11" => 
                      out_of_2mux <= out_of_1mux;
            when others => 
                      out_of_2mux <= add_pc_cr;
        end case;
    end process;
    
    JUMP: 
        jump_if <= '1' when (instruction_mem(15 downto 13) = "111") else '0'; 
        
        -- Obs: Dac? se detecteaz? un jump, instruc?iunile din pipeline care au fost aduse speculativ, dar nu sunt necesare, pot fi eliminate

    Multiplexer2: 
        nxt_pc <= jump_addr_if 
            when (jump_if = '1') 
                else out_of_2mux;  
    
    prediction <= MSB_Pred;
    curr_program_counter <= curr_pc_cont(3 downto 0);
end Behavioral;
