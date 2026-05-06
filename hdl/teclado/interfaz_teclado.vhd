
library ieee;
use ieee.std_logic_1164.all;

entity interfaz_teclado is
port(
    clk          : in     std_logic;
    nRST         : in     std_logic;

    col0_in      : in     std_logic;
    col1_in      : in     std_logic;
    col2_in      : in     std_logic;
    col3_in      : in     std_logic;

    fil0_out     : buffer std_logic;
    fil1_out     : buffer std_logic;
    fil2_out     : buffer std_logic;
    fil3_out     : buffer std_logic;

    tecla_out         : buffer std_logic_vector(3 downto 0);
    tecla_pulsada_out : buffer std_logic;
    pulso_largo_out   : buffer std_logic
);
end entity;

architecture estructural of interfaz_teclado is
    signal tic_5ms_s      : std_logic;
    signal columnas_in_s  : std_logic_vector(3 downto 0);
    signal columnas_f_s   : std_logic_vector(3 downto 0);
begin

    -- Empaquetado de columnas de entrada
    columnas_in_s(0) <= col0_in;
    columnas_in_s(1) <= col1_in;
    columnas_in_s(2) <= col2_in;
    columnas_in_s(3) <= col3_in;

    ----------------------------------------------------------------
    -- U0: divisor de reloj -> pulso tic cada 5 ms
    ----------------------------------------------------------------
    U0: entity work.clk_div(rtl)
        port map(
            clk  => clk,
            nRST => nRST,
            tic  => tic_5ms_s
        );

    ----------------------------------------------------------------
    -- U1: filtro de rebotes de columnas
    ----------------------------------------------------------------
    U1: entity work.rebotes(rtl)
        port map(
            clk         => clk,
            nRST        => nRST,
            columnas_in => columnas_in_s,
            columnas_out=> columnas_f_s
        );

    ----------------------------------------------------------------
    -- U2: controlador de teclado matricial
    ----------------------------------------------------------------
    U2: entity work.ctrl_tec(rtl)
        port map(
            clk           => clk,
            nRST          => nRST,
            tic           => tic_5ms_s,

            col0          => columnas_f_s(0),
            col1          => columnas_f_s(1),
            col2          => columnas_f_s(2),
            col3          => columnas_f_s(3),

           

            fil0          => fil0_out,
            fil1          => fil1_out,
            fil2          => fil2_out,
            fil3          => fil3_out,

            tecla         => tecla_out,
            tecla_pulsada => tecla_pulsada_out,
            pulso_largo   => pulso_largo_out
        );

end estructural;