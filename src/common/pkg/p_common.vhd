-------------------------------------------------------------------------
-------------------------------------------------------------------------
-- file        : p_common_tb.vhd
-- Author      : Nebojsa Markovic
-- Mail        : nemarkovic@yandex.com
-- Date        : 09 December 2020
-- Description :
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
   function f_clog2 (in_value : natural) return integer;

---------------------------------------------
--   Data Types
---------------------------------------------

   -- type TYPE_AXI_LITE_SLAVE_IN is record
      -- --write
      -- awaddr  : std_logic_vector(C_S_AXI_ADDR_WIDTH -1 downto 0);
      -- awprot  : std_logic_vector( 2 downto 0);
      -- awvalid : std_logic;
      -- wdata   : std_logic_vector(C_S_AXI_DATA_WIDTH -1 downto 0);
      -- wstrb   : std_logic_vector( 3 downto 0);
      -- wvalid  : std_logic;
      -- bready  : std_logic;
      -- -- read
      -- araddr  : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
      -- arprot  : std_logic_vector(2 downto 0);
      -- arvalid : std_logic;
      -- rready  : std_logic;
   -- end record;

   -- -- Reset Values for TYPE_AXI_LITE_SLAVE type data
   -- constant TYPE_AXI_LITE_SLAVE_IN_RST : TYPE_AXI_LITE_SLAVE_IN := (
      -- awaddr  => (others => '0'),
      -- awprot  => (others => '0'),
      -- awvalid => '0',
      -- wdata   => (others => '0'),
      -- wstrb   => (others => '0'),
      -- wvalid  => '0',
      -- bready  => '0',
      -- araddr  => (others => '0'),
      -- arprot  => (others => '0'),
      -- arvalid => '0',
      -- rready  => '0');

   -- type TYPE_AXI_LITE_SLAVE_IN_ARRAY is array (natural range <>) of TYPE_AXI_LITE_SLAVE_IN;

component mux is
    generic (
        G_NO_OF_INPUTS : natural := 5;
        G_INPUT_SIZE   : natural := 8 );
    port (
        i_vec : in  STD_LOGIC_VECTOR (G_INPUT_SIZE * G_NO_OF_INPUTS -1 downto 0);
        i_sel : in  STD_LOGIC_VECTOR (f_clog2(G_NO_OF_INPUTS) -1 downto 0);
        o_vec : out STD_LOGIC_VECTOR (G_INPUT_SIZE -1 downto 0));
end component mux;

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
