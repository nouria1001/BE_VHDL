 library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;


entity dfm is
    Port ( clk_50M : in STD_LOGIC;
           in_freq_anemo : in std_logic;
           in_freq_a : out std_logic
              );
end dfm;

architecture arc of dfm is 
	 signal detect : std_logic_vector(1 DOWNTO 0);
	signal freq_anemo : STD_LOGIC_VECTOR(7 downto 0);
	signal front_montant : std_logic;
begin
 process (clk_50M)
        BEGIN
            if rising_edge (clk_50M) then
              front_montant <= '0'; 
             detect(1) <= detect(0);
				detect(0) <= in_freq_anemo;
             IF detect = "01" THEN
                         front_montant <= '1';
          end if;
            END IF;
end process;
in_freq_a <= front_montant;
end arc;