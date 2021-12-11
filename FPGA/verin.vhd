library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

------- pulse ---------------------------------------
entity verin is
port (
ARst : in std_logic;  
Clk_50M : in std_logic;
  miso : in std_logic;
    cs_n : out std_logic;
sck : out std_logic
);
end entity;

architecture rtl of verin is

signal sign_sck : std_logic ;	
signal sckfm : std_logic ;	
signal sckfD : std_logic ;
signal sign_pulse: std_logic;
signal idata_out : std_logic_vector (15 downto 0);  
signal sign_data_out : std_logic_vector (15 downto 0) ;
signal sign_cptbit   : std_logic_vector(14 downto 0);
signal data_valid: std_logic_vector(11 downto 0);
signal en_data_valid : std_logic ;	
signal start_stop : std_logic;
type STATES_ST is (ST_Attente, ST_read_data);
    signal CurrentST : STATES_ST;
-------------------------------------------

---***********generateurpulse***********----  
component generateurpulse is
 generic ( compare_value   : integer := 50 );
port (  clk: in std_logic;
   	  reset: in std_logic;
        pulse: out std_logic
	);
end component;  
---***********Bascule***********----  
	component BasculeD is
		port ( 
			reset : in std_logic;
			clk : in std_logic;
			en : in std_logic;
			D : in std_logic;
			Q : out std_logic
		);
	end component; 
---***********registre***********----
component regdec is
port ( reset, clk, en:in std_logic;   
		D :in std_logic;  
     	data_out : out std_logic_vector (15 downto 0)
		);
end component;	
---***********compteur fronts***********----
component cmpdfd is
port (  clk: in std_logic;
    	SRst: in std_logic;
    	en  : in std_logic;
    	Ud  : in    std_logic:= '1'; 
      cptbit   : out   std_logic_vector(14 downto 0)
	);
end component;	
----------------------registre-----------------------------
component registre is
generic (
        N   : integer := 16            
    );
    Port ( clk : in STD_LOGIC;
           E : in std_logic_vector(N - 1 downto 0);
           en : in std_logic;
           Q: out std_logic_vector(N - 1 downto 0)
              );
end component;
signal rst_pulse : std_logic;
------------------------------------------------------
begin
rst_pulse  <= '1' when CurrentST = ST_Attente else '0';
upulseQ : generateurpulse
        generic map (compare_value => 50  ) --(geneérer 50m\50 =1M )
        port map ( clk => clk_50M,
						 reset => ARst or rst_pulse,
						 pulse => sign_pulse);
				
uBascule1 : BasculeD
	port map ( reset => ARst or rst_pulse, 
				  clk => clk_50M, 
				  en => sign_pulse, 
				  D => not sign_sck,
				  Q => sign_sck);
ureg :  regdec 
port map(
			reset=> ARst,
			clk => clk_50M,
			en =>sckfm,
		   D => miso,    
			data_out => sign_data_out
        );
	process (clk_50M, ARst)
	begin
		if arst = '1' then
			sign_cptbit <= (others => '0');
		elsif rising_edge(clk_50M) then
		
			if CurrentST = ST_Attente then
				sign_cptbit <= (others => '0');
			elsif sckfd = '1' then
				sign_cptbit <= sign_cptbit + 1;
			end if;
		end if;
	end process;

uregI :  registre 
 generic map (
            N => 12
        )
        port map ( 
            clk =>clk_50M,
            E => sign_data_out(11 downto 0),
            en => en_data_valid,
            Q=> data_valid
        );  		 
----------- signal sck --------------------------------
sckfm <= '1' when sign_sck = '0' and sign_pulse = '1' else '0'; -- detecter FM et FD
sckfd <= '1' when sign_sck = '1' and sign_pulse = '1' else '0'; 
-------------------------------------------------------
sck <= sign_sck;

----------- signal recup --------------------------------
en_data_valid <= '1' when sckfD = '1' and sign_cptbit = 14 else '0';
-------------------------------------------------------
	
-- chipeselect etat bas puis etat haut
-- start_stop : si start_stop = 1 , cs = 0 , et on autorise generateurpulse
-- on autorise le detecteurFD a cpmter sur chaque fd 
-- on veut etre sur qu on arrive jusquau dernier fd = 15 
    pMAE: process(clk_50M, ARst,CurrentST, start_stop)
    begin
    if ARst='1' then
		CurrentST<=ST_Attente; cs_n<= '1';
	elsif clk_50M'event and clk_50M='1' then
        case CurrentST is
            when ST_Attente =>
                if (start_stop = '1') then 
						cs_n <= '0';
						CurrentST <= ST_read_data;
                end if; 
            when ST_read_data =>
                if (sign_cptbit >= 14 and sckfD = '1') then
                    CurrentST <= ST_Attente;
							cs_n <= '1';
					 end if;
        end case;
		  end if;
    end process pMAE;

----------- start stop --------------------------------
--strt_stp <= '1' when sign_cptbit=0 else '0';
--------------------------------------------------------
u_start_stop : generateurpulse
        generic map (compare_value => 5_000_000  ) --(geneérer 50m\50 =1M )
        port map ( clk => clk_50M,
						 reset => ARst,
						 pulse => start_stop);
end rtl;




