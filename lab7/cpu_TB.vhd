library ieee;
use ieee.NUMERIC_STD.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

	-- Add your library and packages declaration here ...
entity CPU_TB is
end CPU_TB;

architecture TB_ARCHITECTURE of CPU_TB is
	constant TC:time:=10 ns; 
	component CPU port(CLK,RST : in std_logic;
		 RDYP : in std_logic;
		 DI : in std_logic_VECTOR(15 downto 0);
		 WRP : out std_logic;
		 RDP : out std_logic;
		 AP : out std_logic_VECTOR(4 downto 0);
		 DO : out std_logic_VECTOR(15 downto 0) );
	end component;

	signal CLK,RST,RDY,selp,WRP,RDP : std_logic;
	signal DI, DO,RP1: std_logic_VECTOR(15 downto 0);
	signal ADDRP : std_logic_VECTOR(4 downto 0);
	begin
		 CLK<=not CLK after 0.5*TC ; 
		 RST<='1', '0' after 33 ns; 
		 UUT : CPU port map (CLK,RST, 
		 RDYP => RDY,
		 DI => DI,
		 WRP => WRP, RDP => RDP,
		 AP => ADDRP,DO => DO );
	
		 selp<='1' when ADDRP="00001" else '0'; 
		 RDY<= WRP or RDP after TC+3ns; 
		 DI<=X"5A5A" when (selp and RDP) = '1' else 
		 X"0000" after 5 ns;
		 R:process(CLK) 
		 begin
			 if CLK='1' and CLK'event and selp='1' and WRP='1' then
			 	RP1<=DO;
		 	 end if;
		 end process;
end TB_ARCHITECTURE;

