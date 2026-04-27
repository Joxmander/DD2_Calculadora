-- BinarioToBCD.vhd
-- Este bloque realiza la conversion de un numero binario de 20 bits a BCD (6 digitos).
-- Utiliza el algoritmo iterativo: Nuevo_Peso = 2 * Peso_Anterior + Bit_Actual.
-- La multiplicacion por 2 se realiza mediante el SumadorBCD_6Digitos (Suma = Peso + Peso).
-- El bit actual del numero binario se introduce a traves del 'cin' del sumador.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity BinarioToBCD is
    port(
        clk      : in  std_logic;
        nRst     : in  std_logic;
        inicio   : in  std_logic;                      -- Señal para empezar a convertir
        num_bin  : in  std_logic_vector(19 downto 0);  -- El resultado en binario (20 bits)
        num_bcd  : out std_logic_vector(23 downto 0);  -- El resultado en BCD (6 digitos)
        fin      : out std_logic                       -- Flag para avisar que ya ha terminado
    );
end BinarioToBCD;

architecture rtl of BinarioToBCD is

    -- Estados de la maquina
    type t_estados is (ST_REPOSO, ST_CALCULO, ST_FIN);
    signal estado : t_estados;

    -- Registros internos para no perder los datos
    signal reg_bin      : std_logic_vector(19 downto 0); -- Para ir desplazando el binario
    signal reg_bcd      : std_logic_vector(23 downto 0); -- Acumulador para el BCD
    signal suma_bcd_out : std_logic_vector(23 downto 0); -- Cable que viene del sumador
    signal cont         : integer range 0 to 20;         -- Contador de las 20 vueltas
    signal cout_ignorado   : std_logic; -- Acarreo de salida del sumador que no nos hace falta

begin

    -- Instanciacion directa del sumador de 6 digitos para hacer la multiplicacion por 2
    -- Metemos el bit que sale por la izquierda del binario (bit 19) por el carry de entrada
    SUMADOR: entity work.SumadorBCD_6Digitos port map (
        A    => reg_bcd,
        B    => reg_bcd,
        cin  => reg_bin(19),
        Suma => suma_bcd_out,
        cout => cout_ignorado    -- Conectamos la señal que luego ignoramos
    );

    -- Control del proceso secuencial
    process(clk, nRst)
    begin
        if nRst = '0' then
            estado  <= ST_REPOSO;
            reg_bin <= (others => '0');
            reg_bcd <= (others => '0');
            num_bcd <= (others => '0');
            cont    <= 0;
            fin     <= '0';
        elsif clk'event and clk = '1' then
            
            case estado is
                
                when ST_REPOSO =>
                    fin <= '0';
                    if inicio = '1' then
                        reg_bin <= num_bin;      -- Cargamos el numero de la ALU
                        reg_bcd <= (others => '0'); -- Limpiamos el acumulador para empezar de cero
                        cont    <= 0;
                        estado  <= ST_CALCULO;
                    end if;

                when ST_CALCULO =>
                    if cont < 20 then
                        -- Actualizamos el BCD con la suma del ciclo actual
                        reg_bcd <= suma_bcd_out;
                        -- Desplazamos el registro binario hacia la izquierda
                        reg_bin <= reg_bin(18 downto 0) & '0';
                        cont <= cont + 1;
                    else
                        estado <= ST_FIN;
                    end if;

                when ST_FIN =>
                    num_bcd <= reg_bcd; -- Sacamos el resultado final a los pines
                    fin     <= '1';     -- Avisamos al controlador principal
                    estado  <= ST_REPOSO;

                when others =>
                    estado <= ST_REPOSO;
            end case;
        end if;
    end process;

end rtl;