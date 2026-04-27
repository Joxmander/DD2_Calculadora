-- SumadorBCD_1Digito.vhd
-- Este módulo implementa un sumador combinacional de un solo dígito BCD (4 bits).
-- Toma dos números BCD (0-9) y un acarreo de entrada, y produce su suma en BCD (0-9)
-- junto con un acarreo de salida. Incluye la corrección automática sumando 6 ("0110") 
-- si el resultado excede el valor 9.
--
-- Es un bloque diseñado específicamente para instanciarse dentro del 
-- conversor de Binario a BCD.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all; 

entity SumadorBCD_1Digito is
    port(
        A    : in     std_logic_vector(3 downto 0); 
        B    : in     std_logic_vector(3 downto 0); 
        cin  : in     std_logic;                    
        Suma : buffer std_logic_vector(3 downto 0); 
        cout : buffer std_logic                     
    );
end SumadorBCD_1Digito;

architecture rtl of SumadorBCD_1Digito is
    signal suma_temp : std_logic_vector(4 downto 0);
begin
    
    -- Se actualiza instantáneamente cuando A, B o cin cambian.
    suma_temp <= ('0' & A) + ('0' & B) + ("0000" & cin);
    
    process(suma_temp)
    begin
        -- Ajuste BCD
        if suma_temp > "01001" then 
            Suma <= suma_temp(3 downto 0) + "0110";
            cout <= '1';
        else
            Suma <= suma_temp(3 downto 0);
            cout <= '0';
        end if;
    end process;

end rtl;