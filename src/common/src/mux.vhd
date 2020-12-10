-------------------------------------------------------------------------
-------------------------------------------------------------------------
-- file        : mux.vhd
-- Author      : Nebojsa Markovic
-- Mail        : nemarkovic@yandex.com
-- Date        : 09 December 2020
-- Description : G_NO_OF_INPUTS x 1 mulitplexer
--      inputs :
--               i_vec - MUX expects all inputs to be concatenated in one
--                       input vec
--               i_sel - select one of G_NO_OF_INPUTS as output of the module
--     outputs :
--               o_vec - MUX output
--    generics :
--               G_NO_OF_INPUTS - number of inputs.
--                                recommanded G_NO_OF_INPUTS = 2^M
--               G_INPUT_SIZE   - bit size of one input (in the same time
--                                output bit size)
-------------------------------------------------------------------------
-------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    use work.p_common.all;

entity mux is
   generic (
      --! Number of MUX inputs
      G_NO_OF_INPUTS : natural := 5;
      --! Bit size of one MUX input
      G_INPUT_SIZE   : natural := 8 );
   port (
      --! Input vector (all mux inputs concatenated)
      i_vec : in  std_logic_vector (G_INPUT_SIZE * G_NO_OF_INPUTS -1 downto 0);
      --! Input select signal
      i_sel : in  std_logic_vector (f_clog2(G_NO_OF_INPUTS) -1 downto 0);
      --! Mux output
      --! Selected input will arive as the output
      o_vec : out std_logic_vector (G_INPUT_SIZE -1 downto 0));
end mux;

architecture Behavioral of mux is
begin

   process(i_sel, i_vec)
      variable v_sel : natural range 0 to G_NO_OF_INPUTS;
   begin
      v_sel := to_integer(unsigned(i_sel));
      o_vec <= i_vec( (v_sel +1)* G_INPUT_SIZE -1 downto v_sel * G_INPUT_SIZE);
   end process;

end Behavioral;