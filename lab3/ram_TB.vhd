library ieee;
use ieee.NUMERIC_STD.all;
use ieee.std_logic_1164.all;

	-- Add your library and packages declaration here ...

entity ram_tb is
end ram_tb;

architecture TB_ARCHITECTURE of ram_tb is
	-- Component declaration of the tested unit
	component ram
	port(
		CLK : in STD_LOGIC;
		R : in STD_LOGIC;
		WR : in STD_LOGIC;
		OE : in STD_LOGIC;
		EN1 : in STD_LOGIC;
		AD1 : in STD_LOGIC_VECTOR(12 downto 0);
		ID : in STD_LOGIC_VECTOR(15 downto 0);
		OD1 : out STD_LOGIC_VECTOR(15 downto 0);
		AD2 : in STD_LOGIC_VECTOR(12 downto 0);
		OD2 : out STD_LOGIC_VECTOR(15 downto 0) );
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal CLK : STD_LOGIC;
	signal R : STD_LOGIC;
	signal WR : STD_LOGIC;
	signal OE : STD_LOGIC;
	signal EN1 : STD_LOGIC;
	signal AD1 : STD_LOGIC_VECTOR(12 downto 0);
	signal ID : STD_LOGIC_VECTOR(15 downto 0);
	signal AD2 : STD_LOGIC_VECTOR(12 downto 0);
	-- Observed signals - signals mapped to the output ports of tested entity
	signal OD1 : STD_LOGIC_VECTOR(15 downto 0):= (others => 'Z');
	signal OD2 : STD_LOGIC_VECTOR(15 downto 0);
	constant T : time := 20 ns;
	-- Add your code here ...

begin

	-- Unit Under Test port map
	UUT : ram
		port map (
			CLK => CLK,
			R => R,
			WR => WR,
			OE => OE,
			EN1 => EN1,
			AD1 => AD1,
			ID => ID,
			OD1 => OD1,
			AD2 => AD2,
			OD2 => OD2
		);

	-- Add your stimulus here ...
		process
		begin
			CLK <= '0';
			wait for T/2;
			CLK <= '1';
			wait for T/2;
		end process;
 
	STIMULUS : process
	variable value1 : std_logic_vector(ID'range) := X"ABCD";
	variable addr1  : std_logic_vector(AD1'range) := "1010101010101";
	variable value2 : std_logic_vector(ID'range) := X"DCBA";
	variable addr2  : std_logic_vector(AD1'range) := "0101010101010"; 
	begin
		-- Test ZZZZ output
		EN1 <= '1';
		R  <= '0'; 
		WR <= '0'; 
		OE <= '0'; 
		wait for 2*T;
 
		-- Test input
		AD1 <= addr1; 
		WR <= '1';  
		ID <= value1; 
		wait for T;
		AD1 <= addr2;
		ID <= value2;
		wait for T;
		
		-- Test output
		WR <= '0'; 
		OE <= '1';
		AD1 <= addr1;
		AD2 <= addr2;
		wait for T;
 
		-- Test Reset
		wait for T;
		R <= '1'; 
		wait for T;
		
		wait;
	end process;
end TB_ARCHITECTURE;

