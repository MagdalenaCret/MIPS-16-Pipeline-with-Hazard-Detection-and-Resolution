----------------------------------------------------------------------------------
-- Universitatea Tehnica Cluj-Napoca
-- Facultatea de Automatica si Calculatoare
-- Calculatoare si Tehnologia Informatiei
-- Student: CRET MARIA-MAGDALENA
-- Grupa 30233 Seria A

-- STRUCTURA SISTEMELOR DE CALCUL
-- PROIECT LABORATOR
-- Rezolvarea Hazardurilor in Mips Pipeline 16
-- Register File
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity RegisterFile is
	
	port (
		read_address2: in STD_LOGIC_VECTOR(2 downto 0);
		read_address1: in STD_LOGIC_VECTOR(2 downto 0);
		wrt_adr: in STD_LOGIC_VECTOR(2 downto 0);
		write_data: in STD_LOGIC_VECTOR(15 downto 0);
		reg_write: in STD_LOGIC;
		clkM: in STD_LOGIC;
		read_data1: out STD_LOGIC_VECTOR(15 downto 0);
		read_data2: out STD_LOGIC_VECTOR(15 downto 0));

end entity RegisterFile;

architecture Behavioral of RegisterFile is

	type reg_file is array(0 to 7) of std_logic_vector(15 downto 0); 
	signal curr_content: reg_file := (
		x"0000",
		x"0000",
		x"0001",
		x"0000",
		x"0003",
		x"0002",
		x"0002",
		x"ABCD",
		others => x"1111");
begin
	
    synchronized: process(clkM)
	begin 
	-- scriere pe front crescator
	   if rising_edge(clkM) then 
	       if reg_write = '1' then    
	           curr_content(to_integer(unsigned(wrt_adr))) <= write_data;
	       end if;
	   end if;
	 -- citire pe front descrescator
	   if falling_edge(clkM) then 
	       read_data1 <= curr_content(to_integer(unsigned(read_address1)));
	       read_data2 <= curr_content(to_integer(unsigned(read_address2)));
	       
	       if read_address1 = wrt_adr and reg_write = '1' then
	           read_data1 <= write_data;
	       end if;
	       
	       if read_address2 = wrt_adr and reg_write = '1' then
	           read_data2 <= write_data;
	       end if;      
	   end if;    
	end process;
	
end architecture Behavioral;