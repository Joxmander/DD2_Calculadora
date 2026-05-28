-- ============================================================================
-- ALU de la calculadora
-- ============================================================================
-- Entradas:
--   A, B   : 11 bits en complemento a 2 (rango -999..999) vienen de BCDToBinario
--   OP     : 00 = SUMA, 01 = RESTA, 10 = MULTIPLICACION
--   op1_sgn, op2_sgn : informativos (el signo ya viene aplicado dentro de A y B)
--
-- Salidas:
--   Res    : 20 bits MAGNITUD POSITIVA (0..998001) que se entrega a BinarioToBCD
--   Sign   : '1' si el resultado es negativo, '0' si es positivo
--   Err    : '1' si la magnitud supera 998001 (fuera de rango de la calculadora)
--
-- Idea principal:
--   - Hacemos cada operacion en complemento a 2.
--   - Despues sacamos por separado la MAGNITUD (valor absoluto) y el SIGNO.
--   - Asi los displays reciben el numero "limpio" y un bit aparte para el '-'.
-- ============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity alu_calc is
    port(
        A, B    : in     std_logic_vector(10 downto 0);
        OP      : in     std_logic_vector(1 downto 0);
        op1_sgn : in     std_logic;
        op2_sgn : in     std_logic;
        Res     : buffer std_logic_vector(19 downto 0); -- magnitud positiva
        Sign    : buffer std_logic;                     -- '1' = negativo
        Err     : buffer std_logic                      -- '1' = fuera de rango
    );
end alu_calc;

architecture rtl of alu_calc is

    -- ---------------------------------------------------------------
    -- SUMA y RESTA en 12 bits (complemento a 2)
    -- ---------------------------------------------------------------
    -- Extendemos A y B a 12 bits copiando el bit de signo (A(10), B(10))
    -- para que la suma/resta de dos numeros de 11 bits no se desborde.
    -- Maximo valor posible: |+-999 +- +-999| = 1998, cabe de sobra en 12 bits.
    signal a_ext     : std_logic_vector(11 downto 0);
    signal b_ext     : std_logic_vector(11 downto 0);
    signal suma_c2   : std_logic_vector(11 downto 0);
    signal resta_c2  : std_logic_vector(11 downto 0);

    -- ---------------------------------------------------------------
    -- MULTIPLICACION: el IP "mult" esta configurado como SIGNED, asi que
    -- nos devuelve directamente 22 bits en complemento a 2.
    -- ---------------------------------------------------------------
    signal mult_c2   : std_logic_vector(21 downto 0);

    -- ---------------------------------------------------------------
    -- Magnitudes (valor absoluto) de cada operacion
    -- ---------------------------------------------------------------
    signal suma_mag  : std_logic_vector(11 downto 0);
    signal resta_mag : std_logic_vector(11 downto 0);
    signal mult_mag  : std_logic_vector(21 downto 0);

    -- ---------------------------------------------------------------
    -- Magnitud y signo seleccionados segun OP
    -- ---------------------------------------------------------------
    signal res_mag   : std_logic_vector(19 downto 0);
    signal res_sgn   : std_logic;

begin

    -- ===============================================================
    -- 1) Instanciacion del multiplicador IP (signed 11 x signed 11)
    -- ===============================================================
    U_MULT : entity work.mult(syn)
        port map (
            dataa  => A,
            datab  => B,
            result => mult_c2
        );

    -- ===============================================================
    -- 2) Suma y resta en complemento a 2 (con extension de signo)
    -- ===============================================================
    a_ext    <= A(10) & A;
    b_ext    <= B(10) & B;

    suma_c2  <= a_ext + b_ext;
    resta_c2 <= a_ext - b_ext;

    -- ===============================================================
    -- 3) Calculo de la MAGNITUD (valor absoluto) de cada operacion
    --    Si el bit de signo es '1' --> aplicamos (not + 1) para pasar
    --    el numero a positivo.
    --    Si es '0' --> el valor ya esta en positivo, lo dejamos igual.
    -- ===============================================================
    suma_mag  <= (not suma_c2)  + 1 when suma_c2(11)  = '1' else suma_c2;
    resta_mag <= (not resta_c2) + 1 when resta_c2(11) = '1' else resta_c2;
    mult_mag  <= (not mult_c2)  + 1 when mult_c2(21)  = '1' else mult_c2;

    -- ===============================================================
    -- 4) Seleccion final segun la operacion
    --    Separamos MAGNITUD (res_mag) y SIGNO (res_sgn) para mandarlos
    --    por caminos distintos a los displays.
    -- ===============================================================
    process(OP, suma_c2, resta_c2, mult_c2, suma_mag, resta_mag, mult_mag)
    begin
        -- Valores por defecto (evita latches)
        res_mag <= (others => '0');
        res_sgn <= '0';

        case OP is
            when "00" =>                                  -- SUMA
                res_mag <= "00000000" & suma_mag;         -- 8 + 12 = 20 bits
                res_sgn <= suma_c2(11);

            when "01" =>                                  -- RESTA
                res_mag <= "00000000" & resta_mag;        -- 8 + 12 = 20 bits
                res_sgn <= resta_c2(11);

            when "10" =>                                  -- MULTIPLICACION
                res_mag <= mult_mag(19 downto 0);         -- 999*999 = 998001 cabe en 20 bits
                res_sgn <= mult_c2(21);

            when others =>
                res_mag <= (others => '0');
                res_sgn <= '0';
        end case;
    end process;

    -- ===============================================================
    -- 5) Salidas finales
    -- ===============================================================
    Res  <= res_mag;
    Sign <= res_sgn;
    Err  <= '1' when (res_mag > 998001) else '0';

end rtl;
