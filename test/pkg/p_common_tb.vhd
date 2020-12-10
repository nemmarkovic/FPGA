-------------------------------------------------------------------------
-------------------------------------------------------------------------
-- file        : p_common_tb.vhd
-- Author      : Nebojsa Markovic
-- Mail        : nemarkovic@yandex.com
-- Date        : 10 December 2020
-- Description :
--
-------------------------------------------------------------------------
-------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;
   use ieee.MATH_REAL.all;

package p_common_tb is

---------------------------------------------
--   functions declaration
---------------------------------------------
   impure function f_rand_slv(len : integer) return std_logic_vector;
   shared variable seed1, seed2 : integer := 999;
---------------------------------------------
--   Data Types
---------------------------------------------


end package;

package body p_common_tb is

   impure function f_rand_slv(len : integer) return std_logic_vector is
      variable r   : real;
      variable slv : std_logic_vector(len - 1 downto 0);
   begin
      for i in slv'range loop
         uniform(seed1, seed2, r);
         if r > 0.5 then
            slv(i) := '1';
         else
            slv(i) := '0';
         end if;
      end loop;
      return slv;
   end function;

end package body;
