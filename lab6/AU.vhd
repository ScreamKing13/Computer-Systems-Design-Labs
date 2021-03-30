library IEEE;
use IEEE.STD_LOGIC_1164.all, IEEE.STD_LOGIC_arith.all;

entity AU is port( CLK : in STD_LOGIC;
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
end AU;

architecture BEH of AU is
	component FM 
	port(
 		CLK:in STD_LOGIC; -- Sync signal
		WR:in STD_LOGIC; -- Write flag 
		INCQ:in STD_LOGIC;
		CALL:in STD_LOGIC;
		AB:in STD_LOGIC_VECTOR(5 downto 0);-- channel B addres
		AD:in STD_LOGIC_VECTOR(5 downto 0);-- channel D addres
		AQ:in STD_LOGIC_VECTOR(5 downto 0);-- channel Q addres
		ARETC: in STD_LOGIC_VECTOR(15 downto 0);
		Q: in STD_LOGIC_VECTOR  (15 downto 0); -- channel Q data
		B: out STD_LOGIC_VECTOR (15 downto 0);--  channel B data
		D: out STD_LOGIC_VECTOR (15 downto 0);--  channel D data
		ARETCO: out STD_LOGIC_VECTOR(15 downto 0)
		);
	end component;
	
	component LSM is
	port(A,B: in STD_LOGIC_VECTOR (15 downto 0); 
		 C0: in STD_LOGIC;
		 F: in STD_LOGIC_VECTOR (1 downto 0);
		 Y: out STD_LOGIC_VECTOR (15 downto 0);
		 N: out STD_LOGIC;
		 CY: out STD_LOGIC;
		 Z: out STD_LOGIC);
	end component;
	
	component RALU is port(CLK : in STD_LOGIC;
	RST : in STD_LOGIC;
	START : in STD_LOGIC;
	X : in STD_LOGIC_VECTOR(15 downto 0);
	Y : out STD_LOGIC_VECTOR(15 downto 0);
	N : out STD_LOGIC;
	Z : out STD_LOGIC;
	RDY : out STD_LOGIC);
	end component;

	type STAT_AU is (free,mpy,mpyl);-- состояния автомата
	signal st:STAT_AU;
	signal b,q,d,y,dp,aretc,aretco:STD_LOGIC_VECTOR(15 downto 0);
	signal c0,c15,csh,nlsm,zlsm,wr,mult,outhl:STD_LOGIC;
	signal rdym,zmpy,nmpy:STD_LOGIC;
 	signal cnzr,cnzo,cnzi:STD_LOGIC_VECTOR(2 downto 0);
	 
	begin
 		U_FM: FM port map( -- блок регистровой памяти
		CLK, 
 		WR=>wr, INCQ=>outhl, CALL=>CALL,
 		AB=>AB, AD=>AD, AQ=>AQ, ARETC=>aretc,
 		Q=>q, B=>b, D=>d,ARETCO=>aretco);
		aretc<=cnzr&ARET;
	 	cnzo<=aretco(15 downto 13);
	 	ARETO<=aretco(12 downto 0);
		MUX_C: c0<= cnzi(2) when ACOP(1 downto 0)="10" else '0'; -- мультиплексор С0 
		
		U_LSM: LSM port map( -- LSM
		F=>ACOP(1 downto 0), 
	 	A=>d,B=>b,
		C0=>c0, Y =>y,
		CY=>c15, Z =>zlsm, N => nlsm );
 		
		U_RALU: RALU port map( -- блок операции по варианту
		CLK,RST, 
 		START=>mult,
		X=>d,
 		RDY=>rdym,Z=>zmpy,
 		N=>nmpy, Y=>dp);
		
		csh<= '0';
		MUX_Q:q<=dp when st=mpyl else --результат умножения
				 csh&d(15 downto 1) when ACOP="100" else -- сдвиг вправо (SRL)
				 DI when WRD='1' else --входное данное
				 d when RD='1' else --данное из FM по адресу АD
				 y;
		
		SR: process(q, RST, ACOP) --регистр состояния c мультиплексором
		begin
			 if RST='1' then
			 	cnzi<="000";
			 elsif RET='1' then
			 	cnzi<=cnzo;
			 elsif st=mpyl then
			 	cnzi<='0'&nmpy&zmpy;
			 elsif mult='0' and ACOP(2)='0' then
			 	cnzi<=c15&nlsm&zlsm;
			 else 
				 cnzi<="000";
			 end if;
		end process;
		mult<='1', '0' after 20 ns when ACOP="101" else '0';
		
		FSM_AU:process(CLK,RST) -- автомат управления
		 begin
			 if RST='1' then
				 st<=free; -- регистр состояния автомата
			 elsif CLK='1' and CLK'event then
				 case st is
					 when free => 
					 	if START='1'and mult='1'then --свободен
					 		st<=mpy;
					 	end if;
					 when mpy=> 
					 	if rdym='1' then -- идет операция
					 		st<=mpyl ;
					 	end if;
					 when mpyl=> 
					 if ACOP/="101" then 
						 st<=free; --конец операции
					 end if;
				 end case;
			 end if;
		end process;
		
		--функции выходов автомата
		wr<='1' when WRD='1' or st=mpyl or (st=mpy and rdym='1')
		or (START='1' and mult='0') else '0';
		RDY<='1' when st=mpyl or (WRD='0' and st/=mpy and mult='0')else'0';
		DO<=q; --выходное данное
		BO<=B;
		CNZ<=cnzi; --выход регистра состояния
	end BEH;