
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity avalon_anemometre is
    port (
        clk : in std_logic;
        in_freq_anemo : in std_logic;
 		  chipselect, write_n, reset_n : in std_logic;
		  writedata : in std_logic_vector (31 downto 0);
		  readdata : out std_logic_vector (31 downto 0);
		  address: std_logic_vector (1 downto 0)
	);
end avalon_anemometre;




architecture arc of avalon_anemometre is 
-- DFM
component dfm is
    Port ( clk_50M : in STD_LOGIC;
           in_freq_anemo : in std_logic;
           in_freq_a : out std_logic
              );
end component;

-- Compteur
component cmp is
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
end component;
--------------------generateurpulse-----------------------------------    
component generateurpulse is
 generic (
        compare_value   : integer := 49_999_999              
    );
port (clk: in std_logic;
   	  reset: in std_logic;
      pulse: out std_logic;
      clkgen : out std_logic
	);
end component;
              
----------------------registre-----------------------------
component registre is
generic (
        N   : integer := 8              
    );
    Port ( clk : in STD_LOGIC;
           E : in std_logic_vector(N - 1 downto 0);
           en : in std_logic;
           Q: out std_logic_vector(N - 1 downto 0)
              );
end component;
------mae-----------------------------
component  mae is
    port (
        ARst_N  : in    std_logic;
        Clk     : in    std_logic;
        data_valid: in    std_logic;
        continu  : in    std_logic;
        start_stop  : in    std_logic;
        mesure_encours : out   std_logic
		);
end component;
---------------------------------------
	component BasculeD is
		port ( 
			reset : in std_logic;
			clk : in std_logic;
			en : in std_logic;
			D : in std_logic;
			Q : out std_logic
		);
	end component;
---------------------------------------
component  anemometre is
    port (
       ARst_N : in std_logic;
        Clk_50M : in std_logic;
        in_freq_anemo : in std_logic;
        data_anemo : out std_logic_vector(7 downto 0);
        data_valid : out std_logic;
		  continu : in std_logic;
        pulse0 : out std_logic;
        Debug1 : out std_logic_vector(7 DOwnto 0)
    );
end component;

--- declaration de signaux internes pour les connexions entre les blocs
signal in_freq_FM : std_logic;
signal CptFM_Q : std_logic_vector(7 downto 0);
signal pulse_Q : std_logic;
signal mesureout : std_logic ;
SIGNAL   config : std_logic_vector (31 downto 0);
SIGNAL   start_stop, continu, raz_n : std_logic;
Signal   data_anem : STD_LOGIC_VECTOR(7 DOWNTO 0);
Signal   data_valid : STD_LOGIC;

--------------begin---------------------
begin
------------------------------
uanem:anemometre
   port map ( 
	ARst_N => raz_n,
	Clk_50M => clk,
	continu=>continu,
        in_freq_anemo=>in_freq_anemo,
        data_anemo =>data_anem,
        data_valid =>data_valid
		
    );
----------ecriture registres
process_write: process (clk, reset_n)
begin
	if reset_n = '0' then
	elsif clk'event and clk = '1' then
		if chipselect ='1' and write_n = '0' then
			start_stop <= writedata(2);
			continu <= writedata(1);
			raz_n <= writedata(0);
		end if;
	end if;
end process;


-- lecture registres
readdata <= "0000000000000000000000"& data_valid & '0' & data_anem;
		
end arc;
    
