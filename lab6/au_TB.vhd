library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

	-- Add your library and packages declaration here ...

entity au_tb is
end au_tb;

architecture TB_ARCHITECTURE of au_tb is
	-- Component declaration of the tested unit
	component au
	port(
		CLK : in STD_LOGIC;
		RST : in STD_LOGIC;
		START : in STD_LOGIC;
		RD : in STD_LOGIC;
		WRD : in STD_LOGIC;
		RET : in STD_LOGIC;
		CALL : in STD_LOGIC;
		DI : in STD_LOGIC_VECTOR(15 downto 0);
		AB : in STD_LOGIC_VECTOR(5 downto 0);
		AD : in STD_LOGIC_VECTOR(5 downto 0);
		AQ : in STD_LOGIC_VECTOR(5 downto 0);
		ARET : in STD_LOGIC_VECTOR(12 downto 0);
		ACOP : in STD_LOGIC_VECTOR(2 downto 0);
		RDY : out STD_LOGIC;
		ARETO : out STD_LOGIC_VECTOR(12 downto 0);
		DO : out STD_LOGIC_VECTOR(15 downto 0);
		BO : out STD_LOGIC_VECTOR(15 downto 0);
		CNZ : out STD_LOGIC_VECTOR(2 downto 0) );
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal CLK : STD_LOGIC:= '0';
	signal RST : STD_LOGIC;
	signal START : STD_LOGIC;
	signal RD : STD_LOGIC;
	signal WRD : STD_LOGIC;
	signal RET : STD_LOGIC;
	signal CALL : STD_LOGIC;
	signal DI : STD_LOGIC_VECTOR(15 downto 0);
	signal AB : STD_LOGIC_VECTOR(5 downto 0);
	signal AD : STD_LOGIC_VECTOR(5 downto 0);
	signal AQ : STD_LOGIC_VECTOR(5 downto 0);
	signal ARET : STD_LOGIC_VECTOR(12 downto 0);
	signal ACOP : STD_LOGIC_VECTOR(2 downto 0);
	-- Observed signals - signals mapped to the output ports of tested entity
	signal RDY : STD_LOGIC;
	signal ARETO : STD_LOGIC_VECTOR(12 downto 0);
	signal DO : STD_LOGIC_VECTOR(15 downto 0);
	signal BO : STD_LOGIC_VECTOR(15 downto 0);
	signal CNZ : STD_LOGIC_VECTOR(2 downto 0);

	-- Add your code here ...
	 type MICROINST is record -- формат микрокоманды
	 	ACOP:STD_LOGIC_VECTOR(2 downto 0); -- код операции AU
 		AQ,AD,AB:STD_LOGIC_VECTOR(5 downto 0); -- адреса FM
 		DI:STD_LOGIC_VECTOR(15 downto 0); -- входное данное
 		START,WRD,RD:STD_LOGIC; -- биты управления
	 end record;
	 constant n: positive:=9; --число микрокоманд
	 constant value: STD_LOGIC_VECTOR(15 downto 0):= CONV_STD_LOGIC_VECTOR(integer(0.23 * 2.0 ** 15), 16);
	type MICROPROGR is array(0 to n-1) of MICROINST;
	constant mp:MICROPROGR:=( -- ПЗУ тестирующей микропрограммы
--   ACOP |	  AQ   |   AD   |   AB	 |	 DI	 |START|WRD|RD
	("111","000001","000000","000000",X"0002", '0', '1','0'), --WRITE R1, 0X0002
 	("111","000010","000000","000000",X"0003", '0', '1','0'), --WRITE R2, 0X0003
	("000","000011","000001","000010",X"0000", '1', '0','0'), --AND R3, R1, R2
 	("001","000100","000001","000010",X"0000", '1', '0','0'), --XOR R4, R1, R2
	("010","000101","000001","000010",X"0000", '1', '0','0'), --ADD R5, R1, R2
	("011","000110","000010","000001",X"0000", '1', '0','0'), --SUB R6, R2, R1
	("100","000111","000001","000000",X"0000", '1', '0','0'), -- SRL R1, R7
	("111","001000","000001","000000",value, '0', '1','0'),   --WRITE R8, 0.23 * 2 ** 15
	("101","001001","001000","000000",X"0000", '1', '0','0')  -- R9 <= ln(R8)
	); 
	constant T : time := 20 ns;
	signal maddr:natural;
	
	begin
	   
	process
		begin
			CLK <= '0';
			wait for T/2;
			CLK <= '1';
			wait for T/2;
		end process;
		
	-- Unit Under Test port map
	UUT : au
		port map (
			CLK => CLK,
			RST => RST,
			START => START,
			RD => RD,
			WRD => WRD,
			RET => RET,
			CALL => CALL,
			DI => DI,
			AB => AB,
			AD => AD,
			AQ => AQ,
			ARET => ARET,
			ACOP => ACOP,
			RDY => RDY,
			ARETO => ARETO,
			DO => DO,
			BO => BO,
			CNZ => CNZ
		);

	-- Add your stimulus here ...
	CTM:process
	begin -- счетчик микрокоманд
		RST <= '0';
		wait for T;
		RST <= '1';
		maddr <= 0;
		wait for T/2;
		RST <= '0';
		wait for T/2;
		(ACOP,AQ,AD,AB,DI,START,WRD,RD)<=mp(maddr);
		maddr<=(maddr+1);
		wait for T;
		(ACOP,AQ,AD,AB,DI,START,WRD,RD)<=mp(maddr);
		maddr<=(maddr+1);
		wait for T;
		(ACOP,AQ,AD,AB,DI,START,WRD,RD)<=mp(maddr);
		maddr<=(maddr+1);
		wait for T;
		(ACOP,AQ,AD,AB,DI,START,WRD,RD)<=mp(maddr);
		maddr<=(maddr+1);
		wait for T;
		(ACOP,AQ,AD,AB,DI,START,WRD,RD)<=mp(maddr);
		maddr<=(maddr+1);
		wait for T;
		(ACOP,AQ,AD,AB,DI,START,WRD,RD)<=mp(maddr);
		maddr<=(maddr+1);
		wait for T;
		(ACOP,AQ,AD,AB,DI,START,WRD,RD)<=mp(maddr);
		maddr<=(maddr+1);
		wait for T;
		(ACOP,AQ,AD,AB,DI,START,WRD,RD)<=mp(maddr);
		maddr<=(maddr+1);
		wait for T;
		(ACOP,AQ,AD,AB,DI,START,WRD,RD)<=mp(maddr);
		maddr<=(maddr+1);
		wait for T;
		wait;
	end process;

	
end TB_ARCHITECTURE;

