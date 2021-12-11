    library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity anemometre is
    port (
        ARst_N : in std_logic;
        Clk_50M : in std_logic;
        in_freq_anemo : in std_logic;
        continu : in std_logic;
		start_stop :in std_logic;
        data_anemo : out std_logic_vector(7 downto 0);
        data_valid : out std_logic;
        pulse0 : out std_logic;
        Debug1 : out std_logic_vector(7 DOwnto 0)
    );
end anemometre;

architecture arc of anemometre is 
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

--- declaration de signaux internes pour les connexions entre les blocs
signal ARst : std_logic;
signal in_freq_FM : std_logic;
signal CptFM_Q : std_logic_vector(7 downto 0);
signal pulse_Q : std_logic;
signal mesureout : std_logic ;
--------------begin---------------------
begin
------------------------------
    ARst <= not ARst_N;
    uDFM : dfm
        port map ( 
            clk_50M => Clk_50M,
            in_freq_anemo => in_freq_anemo AND mesureout,
            in_freq_a => in_freq_FM
        );  
 ------------------------------
    uCptFM : cmp 
        generic map (
            N   => 8
        )
        port map (  
            clk => Clk_50M,
            Arst => ARst,
            SRst => pulse_Q,
            en  => in_freq_FM,
            Ud  => '1',
            Q   => CptFM_Q
        );
----------------------------------------------
    ugenerateurpulse : generateurpulse
        generic map (
            compare_value => 50_000_000
        )
        port map (
            clk => Clk_50M,
            reset => not mesureout,
            pulse => pulse_Q,
            clkgen => open
	    );
----------------registre-----------------------------
    ureg :  registre 
        generic map (
            N => 8
        )
        port map ( 
            clk =>clk_50M,
            E => CptFM_Q,
            en => pulse_Q,
            Q => data_anemo
        );
  pulse0 <= pulse_Q;
  Debug1 <= CptFM_Q;

--------------------mae---------------------------------------

umode : mae
port map ( 
        ARst_N =>  ARst_N ,
        Clk => clk_50M,
        data_valid => pulse_Q, 
        continu  => continu,
        start_stop => start_stop,
        mesure_encours => mesureout
		 );
--------------------------------------------------------
uBascule1 : BasculeD
	port map ( 
		reset => ARst, 
		clk => clk_50M, 
		en => '1', 
		D => pulse_Q,
		Q => data_valid);
end arc;
    
