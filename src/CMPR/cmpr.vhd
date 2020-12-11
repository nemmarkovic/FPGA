-------------------------------------------------------------------------
-------------------------------------------------------------------------
-- file        : cmpr.vhd
-- Author      : Nebojsa Markovic
-- Mail        : nemarkovic@yandex.com
-- Date        : 09 December 2020
-- Description :
--
-------------------------------------------------------------------------
-------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;

    use work.p_common.all;

entity cmpr is
    generic(
        G_NO_OF_INPUTS : natural := 8;
        G_VEC_SIZE     : natural := 16 );
    port (
        i_vec          : in  std_logic_vector (G_NO_OF_INPUTS * G_VEC_SIZE -1 downto 0);
        o_vec          : out std_logic_vector (G_NO_OF_INPUTS -1 downto 0));
end cmpr;

architecture RTL of cmpr is

   -- MAT type is array of inputs for the OR circuits, which outputs are used as MUX select
   type TYPE_or_MTRX is array (G_VEC_SIZE -1 downto 0 ) of std_logic_vector(G_NO_OF_INPUTS -1 downto 0);
   signal s_iOR_vec  : TYPE_or_MTRX; -- := (others =>  ( others => '0'));
   signal s_oOR_vec  : std_logic_vector (G_VEC_SIZE -1 downto 0);

   type TYPE_iMUX_MTRX is array (G_VEC_SIZE -1 downto 0 ) of std_logic_vector(G_NO_OF_INPUTS *2 -1 downto 0);
   signal s_iMUX_vec  : TYPE_iMUX_MTRX; -- := (others =>  ( others => '0'));
--   signal s_iMUX_sel : std_logic_vector (f_clog2(G_NO_OF_INPUTS) -1 downto 0);

   type TYPE_oMUX_MTRX is array (G_VEC_SIZE -1 downto 0 ) of std_logic_vector(G_NO_OF_INPUTS -1 downto 0);
   signal s_oMUX_vec  : TYPE_oMUX_MTRX; -- := (others =>  ( others => '0'));

   type TYPE_iAND_MTRX is array (G_VEC_SIZE -1 -1 downto 0 ) of std_logic_vector(2 * G_NO_OF_INPUTS -1 downto 0);
   signal s_iAND_vec : TYPE_iAND_MTRX;

   type TYPE_oAND_MTRX is array (G_VEC_SIZE -1 downto 0 ) of std_logic_vector(G_NO_OF_INPUTS -1 downto 0);
   signal s_oAND_vec : TYPE_oAND_MTRX;
begin



genX : for i in G_VEC_SIZE -1 downto 0 generate

   s_iOR_vec(i)  <= s_oAND_vec(i);

   logic_inst : logic
      generic map (
         G_NO_OF_INPUTS => G_NO_OF_INPUTS,
         G_VEC_SIZE     => 1,
         G_LGC_FNC      => "OR")
      port map(
         i_vec          => s_iOR_vec(i),
         o_vec          => s_oOR_vec(i downto i));


   genY : for j in G_NO_OF_INPUTS -1 downto 0 generate

      gen_and_1st_lev :  if i = G_VEC_SIZE -1 generate
         s_oAND_vec(i)(j downto j) <= (others => '1');
         s_iMUX_vec(i)((j+1) *2 -1 downto 2 * j) <= i_vec( j * G_VEC_SIZE +i) & s_oAND_vec(i)(j downto j);
      end generate gen_and_1st_lev;

      gen_and :  if i < G_VEC_SIZE -1 generate
         s_iAND_vec(i)((j+1) *2 -1 downto 2 * j) <= s_oMUX_vec(i +1)(j downto j) & i_vec( j * G_VEC_SIZE +i);

         logic_inst : logic
            generic map (
               G_NO_OF_INPUTS => 2,
               G_VEC_SIZE     => 1,
               G_LGC_FNC      => "AND")
            port map(
               i_vec          => s_iAND_vec(i)((j+1) *2 -1 downto 2 * j),
               o_vec          => s_oAND_vec(i)(j downto j));

         s_iMUX_vec(i)((j+1) *2 -1 downto 2 * j) <= s_oAND_vec(i)(j downto j) & s_oMUX_vec(i +1)(j downto j);
      end generate gen_and;

      mux_inst : mux
         generic map(
            G_NO_OF_INPUTS => 2,
            G_INPUT_SIZE   => 1 )
         port map(
            i_vec => s_iMUX_vec(i)((j+1) *2 -1 downto 2 * j),
            i_sel => s_oOR_vec(i downto i),
            o_vec => s_oMUX_vec(i)(j downto j));


   end generate genY;
end generate genX;

   o_vec <= s_oMUX_vec(0)(G_NO_OF_INPUTS -1 downto 0);

end RTL;
