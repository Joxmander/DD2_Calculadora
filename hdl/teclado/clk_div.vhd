library ieee;
use ieee.std_logic_1164.all;

entity clk_div is
	port(
	  clk : in std_logic;
	  nRST: in std_logic;
	  tic : buffer std_logic
);
end entity;

architecture rtl of clk_div is 
	signal cnt : integer;
	signal tic_reg: std_logic;
begin
     process(clk,nRST)
	begin
	  if nRST = '1' then
		cnt <= 0;
		tic_reg <= '0';
	  elsif clk'event and clk = '1' then 
		tic_reg <= '0';
		  if cnt = 499999 then --necesitamos que mande un tic cada 5 ms para los rebotes
		    tic_reg <= '1';
		    cnt <= 0;
		  else 
		    cnt <= cnt + 1;
		  end if;	
	end if;
     end process;
tic <= tic_reg;
end rtl;
 