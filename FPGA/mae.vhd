library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity mae is
    port (
        ARst_N  : in    std_logic;
        Clk     : in    std_logic;
        data_valid, continu, start_stop  : in    std_logic;
        mesure_encours : out   std_logic
    );
end entity mae;

architecture rtl of mae is
    type STATES_ST is (ST_repos, ST_aquisition);
    signal CurrentST, NextST    : STATES_ST;
begin
--------------------BLOC F -- ce bloc représente l'évolution de notre mae-------------------
    pBlocF: process(CurrentST, continu, data_valid, start_stop)
    begin
        case CurrentST is
            when ST_repos =>
                if (start_stop = '1' or continu = '1') then 
					 NextST <= ST_aquisition ;
                else
                    NextST <= ST_repos;
                end if; 
            when ST_aquisition =>
                if data_valid = '1' and continu = '0' then
                    NextST <= ST_repos;
				else
					NextST <= ST_aquisition;
				end if;
        end case;
    end process pBlocF;
---------------BLOC M --- Mettre à jour l'état présent----------------------
    pBlocM: process(Clk, ARst_N)
    begin
        if ARst_N = '0' then
            CurrentST <= ST_repos;
        elsif rising_edge(Clk) then
            CurrentST <= NextST;
        end if;
    end process pBlocM;  
      
 ------- bloc G  -- MISE A JOUR des sorties ------
    mesure_encours <= '1' when CurrentST = ST_aquisition else '0';
end architecture rtl;