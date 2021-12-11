--Editor : KACEMI/BOUSLAH

 library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity cmp is
    generic (
        N   : integer := 8              
    );
port (  clk: in std_logic;
    	Arst: in std_logic;
    	SRst: in std_logic;
    	en  : in std_logic;
    	Ud  : in    std_logic; 
        Q   : out   std_logic_vector(N - 1 downto 0)
	);
end cmp;
architecture rtl of cmp is
    signal sQ   : std_logic_vector(N - 1 downto 0);
begin
        pCnt: process(Clk, Arst)
    begin
            if Arst = '1' then
            sQ <= (others => '0');
        elsif rising_edge(Clk) then
            if SRst = '1' then
                sQ <= (others => '0');
            else
                if En = '1' then
                    if Ud = '1' then
                        sQ<= sQ+1;
                    else
                        sQ <= sQ - 1;
                    end if;
                end if;
            end if;
        end if;
    end process pCnt;
    Q<=sQ;
end architecture rtl;
    
