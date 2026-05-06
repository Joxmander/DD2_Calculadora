library ieee;
use ieee.std_logic_1164.all;

entity ctrl_tec is
  generic(
    TICS_2s : natural := 400
  );
  port(
    clk  : in std_logic;
    nRst : in std_logic;
    tic  : in std_logic;

    col0 : in std_logic;
    col1 : in std_logic;
    col2 : in std_logic;
    col3 : in std_logic;

    fil0 : buffer std_logic;
    fil1 : buffer std_logic;
    fil2 : buffer std_logic;
    fil3 : buffer std_logic;

    tecla         : buffer std_logic_vector(3 downto 0);
    tecla_pulsada : buffer std_logic;
    pulso_largo   : buffer std_logic
  );
end entity;

architecture rtl of ctrl_tec is
  type estado_t is (STOP, ESCANEO, PULSADO);
  signal estado : estado_t;

  signal fila_sel      : std_logic_vector(1 downto 0);
  signal tecla_reg     : std_logic_vector(3 downto 0);
  signal tp_reg        : std_logic;
  signal reg_pl        : std_logic;
  signal cnt_tic       : integer;
  signal pulsacion     : std_logic;
  signal larga_activa  : std_logic;
begin

  process(clk, nRst)
  begin
    if nRst = '0' then
      estado       <= STOP;
      fila_sel     <= "00";
      tecla_reg    <= (others => '0');
      tp_reg       <= '0';
      reg_pl       <= '0';
      cnt_tic      <= 0;
      larga_activa <= '0';

    elsif clk'event and clk = '1' then
      tp_reg <= '0'; -- pulso corto de 1 ciclo

      case estado is

        when STOP =>
          estado       <= ESCANEO;
          fila_sel     <= "00";
          cnt_tic      <= 0;
          reg_pl       <= '0';
          larga_activa <= '0';

        when ESCANEO =>
          reg_pl       <= '0';
          larga_activa <= '0';
          cnt_tic      <= 0;

          if tic = '1' then
            if pulsacion = '1' then
              case fila_sel is
                when "00" =>
                  if    col0 = '0' then tecla_reg <= x"1";
                  elsif col1 = '0' then tecla_reg <= x"2";
                  elsif col2 = '0' then tecla_reg <= x"3";
                  elsif col3 = '0' then tecla_reg <= x"F";
                  end if;

                when "01" =>
                  if    col0 = '0' then tecla_reg <= x"4";
                  elsif col1 = '0' then tecla_reg <= x"5";
                  elsif col2 = '0' then tecla_reg <= x"6";
                  elsif col3 = '0' then tecla_reg <= x"E";
                  end if;

                when "10" =>
                  if    col0 = '0' then tecla_reg <= x"7";
                  elsif col1 = '0' then tecla_reg <= x"8";
                  elsif col2 = '0' then tecla_reg <= x"9";
                  elsif col3 = '0' then tecla_reg <= x"D";
                  end if;

                when "11" =>
                  if    col0 = '0' then tecla_reg <= x"A";
                  elsif col1 = '0' then tecla_reg <= x"0";
                  elsif col2 = '0' then tecla_reg <= x"B";
                  elsif col3 = '0' then tecla_reg <= x"C";
                  end if;

                when others =>
                  null;
              end case;

              estado <= PULSADO;

            else
              if fila_sel = "00" then
                fila_sel <= "01";
              elsif fila_sel = "01" then
                fila_sel <= "10";
              elsif fila_sel = "10" then
                fila_sel <= "11";
              else
                fila_sel <= "00";
              end if;
            end if;
          end if;

        when PULSADO =>
          if tic = '1' then
            if pulsacion = '1' then
              cnt_tic <= cnt_tic + 1;

              if cnt_tic >= TICS_2s then
                reg_pl       <= '1'; -- larga activa y mantenida
                larga_activa <= '1';
              end if;

            else
              -- se soltó
              if larga_activa = '0' then
                tp_reg <= '1'; -- corta al soltar
              end if;

              reg_pl       <= '0';
              larga_activa <= '0';
              cnt_tic      <= 0;
              estado       <= ESCANEO;
            end if;
          end if;

      end case;
    end if;
  end process;

  tecla         <= tecla_reg;
  tecla_pulsada <= tp_reg;
  pulso_largo   <= reg_pl;

  fil0 <= '0' when fila_sel = "00" else '1';
  fil1 <= '0' when fila_sel = "01" else '1';
  fil2 <= '0' when fila_sel = "10" else '1';
  fil3 <= '0' when fila_sel = "11" else '1';

  pulsacion <= '1' when (col0 = '0' or col1 = '0' or col2 = '0' or col3 = '0') else '0';

end rtl;