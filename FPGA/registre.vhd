    library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;


entity registre is
    generic (
        N : integer := 16              
    );
    port ( 
        clk : in STD_LOGIC;
        en : in std_logic;
        E : in std_logic_vector(N - 1 downto 0);
        Q : out std_logic_vector(N - 1 downto 0)
    );
end registre;

architecture arc of registre is 
begin
    process (clk)
    begin
        if rising_edge(clk) then 
            if en ='1' THEN 
                Q <=E;
            end if;
        end if;
    end process;
end arc;
    
