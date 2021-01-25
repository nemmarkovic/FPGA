-------------------------------------------------------------------------
-------------------------------------------------------------------------
-- file        : cmpr.vhd
-- Author      : Nebojsa Markovic
-- Mail        : nemarkovic@yandex.com
-- Date        : 09 December 2020
-- Description : The comparator finds the biggest number!
--               The design is intended to be used while developing
--               alghorithms which would need such a design block, but it
--               still it is not deacided how much operands there is on the
--               input of the block and what is thers size. 
--               The design is parametrised and size of the input operand
--               and nuber of the operands on the input.
--               When the final parameter numbers are deacided, it is possible
--               to implementdesign in other ways in order to save resources
--       Input - It is expected for all operands to be concatenated in one
--               input vector, i_vec
--      Output - Output - G_NO_OF_INPUTS'size vector. Bits on the position
--               of the biggest number from input vector is set to one.
--               Other bits are set to zero
--  Parameters - G_NO_OF_INPUTS - number of operands
--               G_VEC_SIZE     - Operand size in bits
-------------------------------------------------------------------------
-------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;

    use work.p_common.all;

entity cmpr is
    generic(
        -- Number of input operands
        G_NO_OF_INPUTS : natural :=  8;
        -- Size of one operand
        G_VEC_SIZE     : natural := 32);
    port (
        -- Input vector - input operands concatenated in one vector
        i_vec          : in  std_logic_vector (G_NO_OF_INPUTS * G_VEC_SIZE -1 downto 0);
        -- Output vector - set to '1' on the possition of the biggest number in input vector
        o_vec          : out std_logic_vector (G_NO_OF_INPUTS -1 downto 0));
end cmpr;

architecture RTL of cmpr is

   -- MAT type is array of inputs for the OR circuits, which outputs are used as MUX select
   type TYPE_or_MTRX is array (G_VEC_SIZE -1 downto 0) of std_logic_vector(G_NO_OF_INPUTS -1 downto 0);

   -- Input matrix for the OR circuits in the deign
   signal s_iOR_vec  : TYPE_or_MTRX; -- := (others =>  ( others => '0'));
   -- Output vector with results from OR circuits
   signal s_oOR_vec  : std_logic_vector (G_VEC_SIZE -1 downto 0);

   -- Input MUX matrix
   type TYPE_iMUX_MTRX is array (G_VEC_SIZE -1 downto 0) of std_logic_vector(G_NO_OF_INPUTS *2 -1 downto 0);
   signal s_iMUX_vec  : TYPE_iMUX_MTRX; -- := (others =>  ( others => '0'));
--   signal s_iMUX_sel : std_logic_vector (f_clog2(G_NO_OF_INPUTS) -1 downto 0);

   -- Output MUX matrix
   type TYPE_oMUX_MTRX is array (G_VEC_SIZE -1 downto 0) of std_logic_vector(G_NO_OF_INPUTS -1 downto 0);
   signal s_oMUX_vec  : TYPE_oMUX_MTRX; -- := (others =>  ( others => '0'));

   -- Input MUX matrix for the AND circuits in the deign
   type TYPE_iAND_MTRX is array (G_VEC_SIZE -1 -1 downto 0) of std_logic_vector(2 * G_NO_OF_INPUTS -1 downto 0);
   signal s_iAND_vec : TYPE_iAND_MTRX;

   -- Output MUX matrix for the AND circuits in the deign
   type TYPE_oAND_MTRX is array (G_VEC_SIZE -1 downto 0) of std_logic_vector(G_NO_OF_INPUTS -1 downto 0);
   signal s_oAND_vec : TYPE_oAND_MTRX;
begin

genX : for i in G_VEC_SIZE -1 downto 0 generate

   s_iOR_vec(i)  <= s_oAND_vec(i);

   -- OR circuit in the design is G_NO_OF_INPUTS size OR circuit
   -- that is used to check if any of the input operands, on the
   -- "i-th" possition has a '1' (this '1' is important only if the
   -- operand is still a candidate for the biggest number. AND cicuit
   -- in combination with MUXes is used to propagate ones for each 
   -- candidate for biggest num)
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
