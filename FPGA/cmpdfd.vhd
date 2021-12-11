--Editor : KACEMI/BOUSLAH


 library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity cmpdfd is
port (  clk: in std_logic;
    	SRst: in std_logic;
    	en  : in std_logic;
    	Ud  : in    std_logic:= '1'; 
		
      cptbit   : out   std_logic_vector(14 downto 0)
	);
end cmpdfd;
architecture rtl of cmpdfd is
    signal sign_cptbit   : std_logic_vector(14 downto 0);
begin
pCnt: process(Clk, SRst)
    begin
        if rising_edge(Clk) then
            if SRst = '1' then
                sign_cptbit <= (others => '0');
            elsif clk'event and clk='1' then
                if sign_cptbit = 14 then
                        sign_cptbit<= (others => '0');
								
							else
						sign_cptbit <= sign_cptbit +1;
								
  		end if;
		end if ;
		end if;				
	end process;	
		cptbit<=sign_cptbit;	
end architecture rtl;