library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity Interfaz_calculadora is
    port(
        clk           : in  std_logic;
        nRst          : in  std_logic;
        tecla         : in  std_logic_vector(3 downto 0);
        tecla_pulsada : in  std_logic;

        -- Señales de salida principales
        num_bcd_out   : out std_logic_vector(23 downto 0);
        res_sgn_out   : out std_logic;
        err_out       : out std_logic;

        -- Opcional: estado/presentación
        pres_out      : out std_logic_vector(1 downto 0)
    );
end entity;

architecture rtl of Interfaz_calculadora is

    -- Señales internas del controlador
    signal pres_sig        : std_logic_vector(1 downto 0);
    signal inicio_cal      : std_logic;
    signal fin_calculo     : std_logic;
    signal num_bcd_sig     : std_logic_vector(23 downto 0);
    signal res_sgn_sig     : std_logic;

    signal op1_sgn_sig     : std_logic;
    signal op2_sgn_sig     : std_logic;
    signal op_sel          : std_logic_vector(1 downto 0);
    signal op1_bcd_sig     : std_logic_vector(11 downto 0);
    signal op2_bcd_sig     : std_logic_vector(11 downto 0);

    -- Señales entre conversor y ALU
    signal op1_bin_sig     : std_logic_vector(10 downto 0);
    signal op2_bin_sig     : std_logic_vector(10 downto 0);

    -- Salida ALU
    signal res_bin_sig     : std_logic_vector(19 downto 0);
    signal err_sig         : std_logic;

begin

    -- Controlador principal
    U_CTRL: entity work.controlador_principal
        port map (
            clk            => clk,
            nRst           => nRst,
            tecla          => tecla,
            tecla_pulsada  => tecla_pulsada,

            pres           => pres_sig,
            inicio_cal     => inicio_cal,
            fin_calculo    => fin_calculo,

            num_bcd_in     => num_bcd_sig,
            num_bcd_out    => num_bcd_out,
            res_sgn_in     => res_sgn_sig,
            res_sgn_out    => res_sgn_out,

            op1_sgn        => op1_sgn_sig,
            op2_sgn        => op2_sgn_sig,

            OP             => op_sel,
            op1_bcd        => op1_bcd_sig,
            op2_bcd        => op2_bcd_sig
        );

    -- Conversor BCD -> Binario
    U_BCD_BIN: entity work.Conv_BCD_Bin
        port map (
            clk     => clk,
            nRst    => nRst,
            op1_bcd => op1_bcd_sig,
            op1_sgn => op1_sgn_sig,
            op2_bcd => op2_bcd_sig,
            op2_sgn => op2_sgn_sig,
            op1_bin => op1_bin_sig,
            op2_bin => op2_bin_sig
        );

    -- ALU
    U_ALU: entity work.alu_calc
        port map (
            A       => op1_bin_sig,
            B       => op2_bin_sig,
            OP      => op_sel,
            op1_sgn => op1_sgn_sig,
            op2_sgn => op2_sgn_sig,
            Res     => res_bin_sig,
            Sign    => res_sgn_sig,
            Err     => err_sig
        );

    -- Conversor Binario -> BCD
    U_BIN_BCD: entity work.BinarioToBCD
        port map (
            clk      => clk,
            nRst     => nRst,
            inicio   => inicio_cal,
            num_bin  => res_bin_sig,
            num_bcd  => num_bcd_sig,
            fin      => fin_calculo
        );

    -- Salidas externas
    err_out  <= err_sig;
    pres_out <= pres_sig;

end rtl;
