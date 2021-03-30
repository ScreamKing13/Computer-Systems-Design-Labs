library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

	-- Add your library and packages declaration here ...

entity ralu_tb is
end ralu_tb;

architecture TB_ARCHITECTURE of ralu_tb is
	-- Component declaration of the tested unit
	component ralu
	port(
		CLK : in STD_LOGIC;
		RST : in STD_LOGIC;
		START : in STD_LOGIC;
		X : in STD_LOGIC_VECTOR(15 downto 0);
		Y : out STD_LOGIC_VECTOR(15 downto 0);
		RDY : out STD_LOGIC );
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal CLK : STD_LOGIC;
	signal RST : STD_LOGIC;
	signal START : STD_LOGIC;
	signal X : STD_LOGIC_VECTOR(15 downto 0);
	-- Observed signals - signals mapped to the output ports of tested entity
	signal Y : STD_LOGIC_VECTOR(15 downto 0);
	signal RDY : STD_LOGIC;
	constant T : time := 20 ns;


	-- Add your code here ...

begin

	-- Unit Under Test port map
	UUT : ralu
		port map (
			CLK => CLK,
			RST => RST,
			START => START,
			X => X,
			Y => Y,
			RDY => RDY
		);
	
		process
		begin
			CLK <= '0';
			wait for T/2;
			CLK <= '1';
			wait for T/2;
		end process;

	-- Add your stimulus here ...
	STIMULUS : process
	begin
		RST <= '0';
		wait for T;
		RST <= '1';
		wait for T;
		START <= '1';
		RST <= '0';
		wait for T;
		START <= '0';
		X <= CONV_STD_LOGIC_VECTOR(integer(0.5 * 2.0 ** 15), 16);
		wait for 14 * T * 2;
		
		wait;
	end process;
	

end TB_ARCHITECTURE;


