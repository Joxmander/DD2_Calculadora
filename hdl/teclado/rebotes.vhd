library ieee;
use ieee.std_logic_1164.all;

entity rebotes is
port(
   clk: in std_logic;
   nRST: in std_logic;
   columnas_in: in std_logic_vector(3 downto 0);
   columnas_out: buffer std_logic_vector(3 downto 0)
);
end entity;

architecture rtl of rebotes is

 signal r1,r2,r3 : std_logic_vector(3 downto 0);
 
    signal c0_t : std_logic_vector(4 downto 1);
    signal c1_t : std_logic_vector(4 downto 1);
    signal c2_t : std_logic_vector(4 downto 1);
    signal c3_t : std_logic_vector(4 downto 1);

    signal c0_now, c1_now, c2_now, c3_now : std_logic;
begin

process(clk,nRST)
begin
  if nRST = '1' then 
	 r1 <= (others => '1');
         r2 <= (others => '1');
         r3 <= (others => '1');
elsif clk'event and clk = '1' then 
	r1 <= columnas_in;
	r2 <= r1;
	r3 <= r2;
end if;
end process;

c0_now <= to_x01(r3(0));
c1_now <= to_x01(r3(1));
c2_now <= to_x01(r3(2));
c3_now <= to_x01(r3(3));

--Filtros --

process(clk,nRST)
begin
  if nRST = '1' then 
       c0_t <= (others =>'1');
  elsif clk'event and clk = '1' then
	if(c0_t(4) = c0_now) and (c0_t(3 downto 1) /= (c0_now & c0_now & c0_now))
   	then
	  c0_t(3 downto 1) <= c0_now & c0_now & c0_now;
	else 
	  c0_t <= c0_t(3 downto 1) & c0_now;
	end if;
    end if;
end process;



process(clk,nRST)
begin
  if nRST = '1' then 
       c1_t <= (others =>'1');
  elsif clk'event and clk = '1' then
	if(c1_t(4) = c1_now) and (c1_t(3 downto 1) /= (c1_now & c1_now & c1_now))
   	then
	  c1_t(3 downto 1) <= c1_now & c1_now & c1_now;
	else 
	  c1_t <= c1_t(3 downto 1) & c1_now;
	end if;
    end if;
end process;



 process(clk, nRST)
    begin
        if nRST = '1' then
            c2_t <= (others => '1');
        elsif clk'event and clk = '1' then
            if (c2_t(4) = c2_now) and (c2_t(3 downto 1) /= (c2_now & c2_now & c2_now)) then
                c2_t(3 downto 1) <= c2_now & c2_now & c2_now;
            else
                c2_t <= c2_t(3 downto 1) & c2_now;
            end if;
        end if;
    end process;

 process(clk, nRST)
    begin
        if nRST = '1' then
            c3_t <= (others => '1');
        elsif clk'event and clk = '1' then
            if (c3_t(4) = c3_now) and (c3_t(3 downto 1) /= (c3_now & c3_now & c3_now)) then
                c3_t(3 downto 1) <= c3_now & c3_now & c3_now;
            else
                c3_t <= c3_t(3 downto 1) & c3_now;
            end if;
        end if;
    end process;

columnas_out(0) <= c0_t(4);
columnas_out(1) <= c1_t(4);
columnas_out(2) <= c2_t(4);
columnas_out(3) <= c3_t(4);

end rtl;