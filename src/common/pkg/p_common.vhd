-------------------------------------------------------------------------
-------------------------------------------------------------------------
-- file        : p_common_tb.vhd
-- Author      : Nebojsa Markovic
-- Mail        : nemarkovic@yandex.com
-- Date        : 09 December 2020
-- Description : the package contains common functions and common data type
--               definition, also as common components declarations
--
-------------------------------------------------------------------------
-------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;

package p_common is

---------------------------------------------
--   Constants
---------------------------------------------
--   constant G_DATA_WIDTH         : positive  :=  8;      -- Default 8

---------------------------------------------
--   functions declaration
---------------------------------------------
   -- takes natural value and gives bacl ceil(log2(in_vaql))
   function f_clog2 (in_value : natural) return integer;

---------------------------------------------
--   Data Types
---------------------------------------------

---------------------------------------------
--   Components
---------------------------------------------

-------------------------------------------------------------------------
-------------------------------------------------------------------------
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
   component mux is
       generic (
           G_NO_OF_INPUTS : natural := 5;
           G_INPUT_SIZE   : natural := 8 );
       port (
           i_vec : in  STD_LOGIC_VECTOR (G_INPUT_SIZE * G_NO_OF_INPUTS -1 downto 0);
           i_sel : in  STD_LOGIC_VECTOR (f_clog2(G_NO_OF_INPUTS) -1 downto 0);
           o_vec : out STD_LOGIC_VECTOR (G_INPUT_SIZE -1 downto 0));
   end component mux;

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-- Description : Basig logic element with variable number of inputs
--      inputs :
--               i_vec - LOGIC expects all inputs to be concatenated in one
--                       input vec
--     outputs :
--               o_val - output
--    generics :
--               G_NO_OF_INPUTS - number of inputs.
--               G_LGC_FNC      - logic function, available values:
--                                "AND", "OR", "XOR", "NOT"
--
--        NOTE : if G_LGC_FNC = "NOT" it is expected for G_NO_OF_INPUTS
--               to be set to 1
-------------------------------------------------------------------------
-------------------------------------------------------------------------
   component logic is
      generic (
         --! Number of MUX inputs
         G_NO_OF_INPUTS : natural := 2;
         --! Bit size of one MUX input
         G_VEC_SIZE     : natural := 1;
         --! Logic function, available values:
         --! "AND", "OR", "XOR", "NOT"
         G_LGC_FNC      : string := "OR" );
      port (
         i_vec : in  std_logic_vector (G_NO_OF_INPUTS * G_VEC_SIZE -1 downto 0);
         o_vec : out std_logic_vector (                 G_VEC_SIZE -1 downto 0));
   end component logic;


end package;

package body p_common is
    ---------------------------------------------------------------
   -- function called f_clog2 that returns an integer which has the
   -- value of the ceiling of the log base 2
   ---------------------------------------------------------------
   function f_clog2 (in_value : natural) return integer is
      variable in_to_real : real;
      variable ret_val    : integer := 0;
   begin
      -- trivial rejection and acceptance
      if  in_value = 1 or in_value = 0 then
         return 0;
      end if;

      in_to_real := real(in_value);
      while in_to_real >= 2.0 loop
         in_to_real := in_to_real / 2.0;
         ret_val    := ret_val + 1;
      end loop;
      -- round up to the nearest log2
      if in_to_real > 1.0 then
         ret_val := ret_val + 1;
      end if;

      return ret_val;
   end function f_clog2;

end package body;
