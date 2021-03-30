Library IEEE;
use IEEE.std_logic_1164.all; 
use IEEE.numeric_std.all;	 
use IEEE.std_logic_arith.all;
 
 
entity CPU is 
	port(
		CLK  : in  std_logic;  -- CLocK
		RST  : in  std_logic;  -- ReSeT
		RDYP : in  std_logic;  -- ReaDY
		DI   : in  std_logic_vector(15 downto 0); -- Data In
		WRP  : out std_logic;  -- WRite Peripheral
		RDP  : out std_logic;  -- ReaD Peripheral
		AP   : out std_logic_vector(4 downto 0);  -- Address of Peripheral
		DO   : out std_logic_vector(15 downto 0)  -- Data Output
		);
end entity;
 
architecture CPU_arch of CPU is	
component AU 
	port( CLK : in STD_LOGIC;
	 RST : in STD_LOGIC;
	 START : in STD_LOGIC; --начать операцию AU
	 RD: in STD_LOGIC; -- чтение из FM на шину DO
	 WRD : in STD_LOGIC; -- запись с шины DI
	 RET : in STD_LOGIC; -- возврат из подпрограммы
	 CALL: in STD_LOGIC; -- вызов подпрограммы
	 DI : in STD_LOGIC_VECTOR(15 downto 0); --вх. шина данных
	 AB : in STD_LOGIC_VECTOR(5 downto 0); -- адрес регистра В
	 AD : in STD_LOGIC_VECTOR(5 downto 0); -- адрес регистра D
	 AQ : in STD_LOGIC_VECTOR(5 downto 0); -- адрес регистра Q
	 ARET : in STD_LOGIC_VECTOR(12 downto 0); -- адрес возврата
	 ACOP : in STD_LOGIC_VECTOR(2 downto 0); -- код операции AU
	 RDY : out STD_LOGIC; --готовность результата
	 ARETO : out STD_LOGIC_VECTOR(12 downto 0);-- адрес возврата
	 DO : out STD_LOGIC_VECTOR(15 downto 0); --вых. шина данных
	 BO : out STD_LOGIC_VECTOR(15 downto 0); --вых. шина данного В
	 CNZ: out STD_LOGIC_VECTOR(2 downto 0)); --вых. рег. состояний
end component;	   
 
component ICTR is
	port(CLK, RST: in STD_LOGIC;
	 D : in STD_LOGIC_VECTOR(12 downto 0); 
	 I : in STD_LOGIC_VECTOR(9 downto 0); 
	 B : in STD_LOGIC_VECTOR(12 downto 0); 
	 F : in STD_LOGIC_VECTOR(3 downto 0); 
	 ARETI: in STD_LOGIC_VECTOR(12 downto 0); 
	 A : out STD_LOGIC_VECTOR(12 downto 0); 
	 ARET : out STD_LOGIC_VECTOR(12 downto 0));
end component ;	 
 
component RAM is 
	port(CLK : in STD_LOGIC; -- Sync signal
 R: in STD_LOGIC;  -- Reset signal
 WR: in STD_LOGIC; -- Write signal
 OE: in STD_LOGIC; -- Read word output signal
 EN1: in STD_LOGIC;
 AD1 : in STD_LOGIC_VECTOR(12 downto 0); -- Adress for the first port
 ID : in STD_LOGIC_VECTOR(15 downto 0);	-- Input data (through first port)
 OD1 : out STD_LOGIC_VECTOR(15 downto 0);	-- Output data of the first port
 AD2 : in STD_LOGIC_VECTOR(12 downto 0); -- Adress for the second port
 OD2 : out STD_LOGIC_VECTOR(15 downto 0) -- Output data of the second port
 );
end component;
 
component COP is 
	port(CLK,RST: in STD_LOGIC;
	 RDYA : in STD_LOGIC; 
	 RDYP : in STD_LOGIC; 
	 IRG0 : in STD_LOGIC_VECTOR(15 downto 0);
	 CNZ : in STD_LOGIC_VECTOR(2 downto 0); 
	 LINST0 : out STD_LOGIC; 
	 LINST1 : out STD_LOGIC; 
	 EIRG : out STD_LOGIC; 
	 EDI : out STD_LOGIC; 
	 START : out STD_LOGIC; 
	 RET : out STD_LOGIC; 
	 WRRET : out STD_LOGIC; 
	 RD : out STD_LOGIC; 
	 RDP : out STD_LOGIC; 
	 WR : out STD_LOGIC; 
	 WRD : out STD_LOGIC; 
	 WRP : out STD_LOGIC; 
	 FI : out STD_LOGIC_VECTOR(3 downto 0));
end component;
 
	signal START  : std_logic;
	signal RD     : std_logic;
	signal WRD,WR : std_logic;
	signal RET, WRRET : std_logic;
	signal CALL   : std_logic;
	signal DIA,DIB,DII,DIM,DOM,BO,DOA : std_logic_vector(15 downto 0); 
	signal IRG0,IRG1 : std_logic_vector(15 downto 0);  		
	signal AB,AD,AQ  : std_logic_vector(5 downto 0);
	signal ARET,ARETO,AM,ADDR  : std_logic_vector(12 downto 0);
	signal ACOP : std_logic_vector(2 downto 0);
	signal RDYA : std_logic;
	signal DISP : std_logic_vector(9 downto 0);
	signal F,L  : std_logic_vector(1 downto 0);
	signal FI   : std_logic_vector(3 downto 0);
	signal CNZ  : std_logic_vector(2 downto 0);
	signal EIRG, EDI : std_logic;
	signal linstr0,linstr1 : std_logic;
	signal OP,COND : std_logic_vector(2 downto 0);
 
begin
	MUXD : DIA <= IRG1 when EIRG='1' else DII;
	U_A : AU port map 
	(
		CLK,
		RST,
		START => START,
		RD    => RD,
		WRD   => WRD,
		RET   => RET,
		CALL  => WRRET,
		DI    => DIA,
		AB    => AB,
		AD    => AD,
		AQ    => AQ,
		ARET  => ARET,
		ACOP  => ACOP,
		RDY   => RDYA,
		ARETO => ARETO,
		DO    => DOA,
		BO    => BO,
		CNZ   => CNZ
	);
 
	U_R : RAM port map
	(
	CLK,
	RST,
	WR,
	OE => '1',
	EN1 => '1',
	AD1 => AM,
	ID => DI, 
	OD1 => DO, 
	AD2 => "0000000000000"
	);
 
	U_I: ICTR port map
	(
		CLK,
		RST,
		D     => ADDR,
		I     => DISP, 
		ARETI => ARETO,	
		B     => BO(12 downto 0),
		F     => FI,
		A     => AM,
		ARET  => ARET
	);
 
	U_COP: COP 	port map
	(
		CLK,
		RST,
		RDYA  => RDYA,
		RDYP  => RDYP, 		  
		IRG0  => IRG0,
		CNZ   => CNZ,
		LINST0=> linstr0, 
		LINST1=> linstr0, 
		EIRG  => EIRG, 
		EDI   => EDI, 
		START => START,
		RET   => RET,
		WRRET => CALL,
		RD    => RD, 
		RDP   => RDP,
		WR    => WR,
		WRD   => WRD,
		WRP   => WRP, 
		FI    => FI
	);
 
	MUXI : DII <= DI when EDI='1' else DOM; 	  
 
	IRG : process (CLK, RST)
	begin  
		if (RST = '1') then
			IRG0 <= X"0000";
			IRG1 <= X"0000";
		elsif rising_edge(CLK) then
			if linstr0 = '1'then
				IRG0 <= DII;
			elsif linstr1 = '1'then
				IRG1 <= DII;
			end if;	 
		end if;
	end process;  
 
	OP  <= IRG0(15 downto 13);
	F   <= IRG0(12 downto 11); 
	L   <= IRG0(7 downto 6);
	COND<= IRG0(12 downto 10);  
	DISP<= IRG0(9 downto 0);	 
	ADDR<= IRG0(12 downto 0);	 
	AQ  <= "000"&IRG0(10 downto 8);
	AB  <= "000"&IRG0(5 downto 3);
	AD  <= "000"&IRG0(2 downto 0); 
	AP  <= IRG0(7 downto 3);	 
 
	FI(3) <= '1' when (OP = "011" and F(1) = '0') or OP = "100" else '0';
 
end architecture;