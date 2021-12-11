    library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use IEEE.math_real.all; -- importe la fonction log2

entity generateurpulse is
	generic (
		compare_value : integer := 49_999_999      
	);
	port (
		clk : in std_logic;
		reset : in std_logic;
		pulse : out std_logic;
		clkgen : out std_logic
	);
end generateurpulse;

architecture arc of generateurpulse is
-- Declaration des composants 
-- compteur
	component cmp is
		generic (
			N   : integer := 8              
		);
		port (  
				ARst : in std_logic;
				Clk : in std_logic;
				SRst : in std_logic;
				en : in std_logic;
				Ud : in    std_logic; 
				Q  : out   std_logic_vector(N - 1 downto 0)
		);
	end component;
-- bascule
	component BasculeD is
		port ( 
			reset : in std_logic;
			clk : in std_logic;
			en : in std_logic;
			D : in std_logic;
			Q : out std_logic
		);
	end component;
-- Déclaration de constantes
    constant N_bits_Cnt : integer := integer(ceil(log2(real(compare_value))));
-- Déclaration des signaux
	signal sQ : std_logic_vector(N_bits_Cnt - 1 downto 0);
	signal comparateur : std_logic;
	signal iClkDiv : std_logic;
	signal iClkDiv_N : std_logic;
begin
-- L'erreur ici était que le compteur "uCnt" ne comptait que sur 8 bits et rendait la comparaison "comparateur" toujours vraie.
-- Vu qu'on a rendu le générateur l'impulsions "dynamique" c-à-d qu'on peut régler grâce à "compare_value" 
-- la frèquence d'impulsions, il faut que le nombre de bits du compteur "uCnt" soit aussi dynamique en fonction de la constante
-- "compare_value" qu'on lui renseigne.
-- J'ai modifié les noms de quelques signaux pour qu'ils soient plus parlants.

-- Ce compteur, il faut qu'il compte au moins jusqu'à "compare_value", donc il faut calculer le nombre de
-- de bits (N), pour pouvoir compter jusqu'à "compare_value" avec la formule suivante :
--     N = ceil(ln(compare_value) / ln(2))
-- <=> N = ceil(log2(compare_value))
-- Le prototype de la fonction log2 est la suivante : 
-- function LOG2 (X : in REAL) return REAL;
-- La fonction a comme parametre X qui est un réel, et retourne un réel
-- N est un entier et compare_value est un entier
-- integer(x) converti x en entier, c'est léquivalent du cast en C ex: (int)x;
-- La fonction ceil permet d'arrondir au dessus
-- Le prototype de la fonction ceil est la suivante :
-- function CEIL (X : in REAL) return REAL;
-- Le nombre de bits est calculé dans la constante sous le nom "N_bits_Cnt"
	uCnt : cmp
		generic map (
			N => N_bits_Cnt
		)
		port map (  
			clk  => Clk,
			Arst => reset,
			SRst => comparateur,
			en   => '1',
			Ud   => '1',
			Q    => sQ
		);	
-- Indique que le compteur à compter au moins jusqu'à "compare_value - 1", on remet donc le compteur "uCnt" à 0
-- grâce au résulat de cette comparaison
-- On compte jusqu'à "compare_value - 1" car on compte à partir de 0 et de 0 jusquà "compare_value - 1", il y a bien 
-- "compare_value" intervales.
	comparateur <= '1' when sQ >= (compare_value - 1) else '0';
-- Instantiation de la bascule D "uBasculeClkGen" qui permet de générer une horloge de rapport cyclique de 50% dont la frèquence
-- est la suivante : 
-- freq_out = freq_in / (2*compare_value)
-- freq_in : fréquence du signal clk
-- freq_out : fréquence du signal iClkDiv
    uBasculeClkGen : BasculeD
        port map ( 
            reset => reset, 
            clk => clk, 
            en => comparateur, 
            D => iClkDiv_N,
            Q => iClkDiv
        );
        iClkDiv_N <= not iClkDiv;
        clkgen <= iClkDiv;
-- Instantiation de la bascule D "uBasculePulseGen" qui permet de générer des impulsions à la fréquence suivante : 
-- freq_out = freq_in / compare_value
-- freq_in : fréquence du signal clk
-- freq_out : fréquence du signal iClkDiv
    uBasculePulseGen : BasculeD
        port map ( 
            reset => reset, 
            clk => clk, 
            en => '1', 
            D => comparateur,
            Q => pulse
        );
end;
    
