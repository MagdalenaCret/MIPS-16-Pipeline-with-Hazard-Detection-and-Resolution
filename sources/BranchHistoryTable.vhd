----------------------------------------------------------------------------------
-- Universitatea Tehnica Cluj-Napoca
-- Facultatea de Automatica si Calculatoare
-- Calculatoare si Tehnologia Informatiei
-- Student: CRET MARIA-MAGDALENA
-- Grupa 30233 Seria A

-- STRUCTURA SISTEMELOR DE CALCUL
-- PROIECT LABORATOR
-- Rezolvarea Hazardurilor in Mips Pipeline 16
-- Branch History Table
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity BranchHistoryTable is
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
end BranchHistoryTable;

architecture Behavioral of BranchHistoryTable is
    type branch_historyT is array (0 to 15) of std_logic_vector(17 downto 0);
    signal br_table: branch_historyT := (
        B"00_0000000000000000",
        B"00_0000000000000000",
        B"00_0000000000000000",
        others => B"00_0000000000000000"
    );
    
begin
--MSB_Pred: Cel mai semnificativ bit al predictorului (bitul de predic?ie)
--predT: Adresa tinta a ramificatiei
--Daca procesorul a sarit la o alta adresa si branch luat
--Daca procesorul a continuat secven?ial si branch neluat

    msb_pred <= br_table(to_integer(unsigned(address)))(17);
    predT <= br_table(to_integer(unsigned(address)))(15 downto 0); -- adresa pentru predictie
    
    process (clk, wrt_adr, inc_predictor, instr_branch, update_data) is 
        variable curr_predictor: std_logic_vector(1 downto 0);
    begin
        curr_predictor:= br_table(to_integer(unsigned(wrt_adr)))(17 downto 16);
        
--        Pentru ramificatie luata (inc_predictor = '1'): incrementeaza contorul daca nu e maxim
--        Pentru ramificatie neluata (inc_predictor = '0'): decrementeaza contorul daca nu e minim
        if rising_edge(clk) and pc_enable = '1' then
        --partea de branch anterioara
            if instr_branch = '1' then 
               -- branch luat
                if inc_predictor = '1' then 
                     if curr_predictor < "11" then curr_predictor := curr_predictor + 1;
                     end if;
                -- branch neluat
                else 
                    if curr_predictor > "00" then curr_predictor := curr_predictor - 1; 
                    end if;
                end if;
            end if;
            
            if flush = '1' and inc_predictor = '1' then br_table(to_integer(unsigned(wrt_adr)))(15 downto 0) <= update_data;
            end if; 
        
            br_table(to_integer(unsigned(wrt_adr)))(17 downto 16) <= curr_predictor;
        end if;
    end process;

end Behavioral;
