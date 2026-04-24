-- SumadorBCD_6Digitos.vhd
-- Este módulo implementa un sumador combinacional de seis dígitos BCD (24 bits).

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity SumadorBCD_6Digitos is
    port(
        A    : in     std_logic_vector(23 downto 0); -- Número A (6 dígitos BCD)
        B    : in     std_logic_vector(23 downto 0); -- Número B (6 dígitos BCD)
        cin  : in     std_logic;                    -- Acarreo de entrada (0 o 1)
        Suma : buffer std_logic_vector(23 downto 0); -- Resultado BCD (6 dígitos)
        cout : buffer std_logic                     -- Acarreo de salida (0 o 1)
    );
end SumadorBCD_6Digitos;

architecture rtl of SumadorBCD_6Digitos is
    -- 1. Declaramos el componente que vamos a usar (la pieza de LEGO)
    component SumadorBCD_1Digito
        port(
            A    : in     std_logic_vector(3 downto 0);
            B    : in     std_logic_vector(3 downto 0);
            cin  : in     std_logic;
            Suma : buffer std_logic_vector(3 downto 0);
            cout : buffer std_logic
        );
    end component;

    -- 2. Señales internas para los acarreos intermedios (los cables entre bloques)
    -- Necesitamos 5 cables para unir los 6 bloques
    signal c : std_logic_vector(4 downto 0);

begin

    -- BLOQUE 0: Unidades
    DIGITO_0: SumadorBCD_1Digito port map (
        A    => A(3 downto 0),
        B    => B(3 downto 0),
        cin  => cin,       -- El acarreo inicial de la entidad global
        Suma => Suma(3 downto 0),
        cout => c(0)       -- Sale hacia el siguiente bloque
    );

    -- BLOQUE 1: Decenas
    DIGITO_1: SumadorBCD_1Digito port map (
        A    => A(7 downto 4),
        B    => B(7 downto 4),
        cin  => c(0),      -- Recibe el acarreo del bloque 0
        Suma => Suma(7 downto 4),
        cout => c(1)
    );

    -- BLOQUE 2: Centenas
    DIGITO_2: SumadorBCD_1Digito port map (
        A    => A(11 downto 8),
        B    => B(11 downto 8),
        cin  => c(1),
        Suma => Suma(11 downto 8),
        cout => c(2)
    );

    -- BLOQUE 3: Unidades de millar
    DIGITO_3: SumadorBCD_1Digito port map (
        A    => A(15 downto 12),
        B    => B(15 downto 12),
        cin  => c(2),
        Suma => Suma(15 downto 12),
        cout => c(3)
    );

    -- BLOQUE 4: Decenas de millar
    DIGITO_4: SumadorBCD_1Digito port map (
        A    => A(19 downto 16),
        B    => B(19 downto 16),
        cin  => c(3),
        Suma => Suma(19 downto 16),
        cout => c(4)
    );

    -- BLOQUE 5: Centenas de millar
    DIGITO_5: SumadorBCD_1Digito port map (
        A    => A(23 downto 20),
        B    => B(23 downto 20),
        cin  => c(4),
        Suma => Suma(23 downto 20),
        cout => cout       -- El último acarreo sale a la salida global
    );

end rtl;