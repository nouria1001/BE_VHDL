library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;


-- transformer les entrée bit en un vecteur pour récuperer des données
entity regdec is
port ( reset, clk, en :in std_logic; 
		D :in std_logic;  
     	data_out : out std_logic_vector (15 downto 0)
		);
	end;
	
architecture arc of regdec is 
 signal idata_out : std_logic_vector (15 downto 0);
begin
process (clk)
	variable i: integer ;
	begin
	if clk'event and clk='1' then
	if en = '1' then
	idata_out(0) <= D;
		for i in 1 to 15 loop
		idata_out(i) <= idata_out(i-1);
		end loop;
	end if;
	End if ;
end process rec_dec;
data_out <= idata_out;
end arc;
	