----------------------------------------------------------------------------------
-- Universitatea Tehnica Cluj-Napoca
-- Facultatea de Automatica si Calculatoare
-- Calculatoare si Tehnologia Informatiei
-- Student: CRET MARIA-MAGDALENA
-- Grupa 30233 Seria A

-- STRUCTURA SISTEMELOR DE CALCUL
-- PROIECT LABORATOR
-- Rezolvarea Hazardurilor in Mips Pipeline 16
-- Memory Unit in Mips Pipeline
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity MemoryUnit is
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
end MemoryUnit;

architecture Behavioral of MemoryUnit is
    component MemoryForwarding is
        Port (
            MEM_WB_RegWrite: in std_logic;
            WB_BUF_RegWrite: in std_logic;
            EX_MEM_MemWrite: in std_logic;
            EX_MEM_Rt: in std_logic_vector(2 downto 0);
            WB_BUF_RegDst: in std_logic_vector(2 downto 0);
            MEM_WB_RegDst: in std_logic_vector(2 downto 0);
            ForwardC: out std_logic_vector(1 downto 0)
        );
    end component;   

    type ram_content is array (0 to 255) of STD_LOGIC_VECTOR(15 downto 0); 
    signal curr_content: ram_content := (
    X"0004",  -- mem[0]: A = 4
    X"0005",  -- mem[1]: N = 5
    X"0004",  -- mem[2]: X = 2
    X"0014",  -- mem[3]: Y = 3
    X"0001",  -- mem[4]: Primul element din sir este 1
    X"0002",  -- mem[5]: Al doilea element din sir este 2
    X"0000",  -- mem[6]: Al treilea element din sir este 0
    X"0001",  -- mem[7]: Al patrulea element din sir este 1
    others => x"0000"  -- Restul locatiilor de memorie se initializeaza cu 0
    );
    
    signal ForwardC: std_logic_vector(1 downto 0); -- forwarding unit output
    signal MemWriteData: std_logic_vector(15 downto 0);
begin

    Memory_Forwarding_Hazard_Detection: MemoryForwarding port map (
        MEM_WB_RegWrite => MEM_WB_RegWrite,
        WB_BUF_RegWrite => WB_BUF_RegWrite,
        EX_MEM_MemWrite => MemWrite,
        EX_MEM_Rt => EX_MEM_Rt,
        WB_BUF_RegDst => WB_BUF_RegDst,
        MEM_WB_RegDst => MEM_WB_RegDst,
        ForwardC => ForwardC
    );

    MUX_MemData: process(ForwardC, RD2, MEM_WB_RegData, WB_BUF_RegData) is
    begin
        case ForwardC is 
            when "00" => MemWriteData <= RD2;
            when "01" => MemWriteData <= MEM_WB_RegData;
            when "10" => MemWriteData <= WB_BUF_RegData;
            when others => MemWriteData <= X"0000";
        end case;
    end process;
    
        

    ALURes_out <= ALURes; -- rezultatul final scos din  memorie
    
    Process_For_Reading: 
    process(clkM, MemRead) is 
    begin    
        if MemRead = '1' then
            MemData <= curr_content(to_integer(unsigned(ALURes)));
        end if;
    end process;
    
    
    Process_For_Wrinting: 
    process(clkM, MemWrite) is
    begin
        if rising_edge(clkM) then
            if(MemWrite = '1') then
                curr_content(to_integer(unsigned(ALURes))) <= MemWriteData;
            end if;
        end if;
    end process;


end Behavioral;
