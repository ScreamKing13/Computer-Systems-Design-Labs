library IEEE;
use IEEE.STD_LOGIC_1164.all, IEEE.STD_LOGIC_arith.all;

entity AU is port( CLK : in STD_LOGIC;
	 RST : in STD_LOGIC;
	 START : in STD_LOGIC; --������ �������� AU
	 RD: in STD_LOGIC; -- ������ �� FM �� ���� DO
	 WRD : in STD_LOGIC; -- ������ � ���� DI
	 RET : in STD_LOGIC; -- ������� �� ������������
	 CALL: in STD_LOGIC; -- ����� ������������
	 DI : in STD_LOGIC_VECTOR(15 downto 0); --��. ���� ������
	 AB : in STD_LOGIC_VECTOR(5 downto 0); -- ����� �������� �
	 AD : in STD_LOGIC_VECTOR(5 downto 0); -- ����� �������� D
	 AQ : in STD_LOGIC_VECTOR(5 downto 0); -- ����� �������� Q
	 ARET : in STD_LOGIC_VECTOR(12 downto 0); -- ����� ��������
	 ACOP : in STD_LOGIC_VECTOR(2 downto 0); -- ��� �������� AU
	 RDY : out STD_LOGIC; --���������� ����������
	 ARETO : out STD_LOGIC_VECTOR(12 downto 0);-- ����� ��������
	 DO : out STD_LOGIC_VECTOR(15 downto 0); --���. ���� ������
	 BO : out STD_LOGIC_VECTOR(15 downto 0); --���. ���� ������� �
	 CNZ: out STD_LOGIC_VECTOR(2 downto 0)); --���. ���. ���������
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

	type STAT_AU is (free,mpy,mpyl);-- ��������� ��������
	signal st:STAT_AU;
	signal b,q,d,y,dp,aretc,aretco:STD_LOGIC_VECTOR(15 downto 0);
	signal c0,c15,csh,nlsm,zlsm,wr,mult,outhl:STD_LOGIC;
	signal rdym,zmpy,nmpy:STD_LOGIC;
 	signal cnzr,cnzo,cnzi:STD_LOGIC_VECTOR(2 downto 0);
	 
	begin
 		U_FM: FM port map( -- ���� ����������� ������
		CLK, 
 		WR=>wr, INCQ=>outhl, CALL=>CALL,
 		AB=>AB, AD=>AD, AQ=>AQ, ARETC=>aretc,
 		Q=>q, B=>b, D=>d,ARETCO=>aretco);
		aretc<=cnzr&ARET;
	 	cnzo<=aretco(15 downto 13);
	 	ARETO<=aretco(12 downto 0);
		MUX_C: c0<= cnzi(2) when ACOP(1 downto 0)="10" else '0'; -- ������������� �0 
		
		U_LSM: LSM port map( -- LSM
		F=>ACOP(1 downto 0), 
	 	A=>d,B=>b,
		C0=>c0, Y =>y,
		CY=>c15, Z =>zlsm, N => nlsm );
 		
		U_RALU: RALU port map( -- ���� �������� �� ��������
		CLK,RST, 
 		START=>mult,
		X=>d,
 		RDY=>rdym,Z=>zmpy,
 		N=>nmpy, Y=>dp);
		
		csh<= '0';
		MUX_Q:q<=dp when st=mpyl else --��������� ���������
				 csh&d(15 downto 1) when ACOP="100" else -- ����� ������ (SRL)
				 DI when WRD='1' else --������� ������
				 d when RD='1' else --������ �� FM �� ������ �D
				 y;
		
		SR: process(q, RST, ACOP) --������� ��������� c ���������������
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
		
		FSM_AU:process(CLK,RST) -- ������� ����������
		 begin
			 if RST='1' then
				 st<=free; -- ������� ��������� ��������
			 elsif CLK='1' and CLK'event then
				 case st is
					 when free => 
					 	if START='1'and mult='1'then --��������
					 		st<=mpy;
					 	end if;
					 when mpy=> 
					 	if rdym='1' then -- ���� ��������
					 		st<=mpyl ;
					 	end if;
					 when mpyl=> 
					 if ACOP/="101" then 
						 st<=free; --����� ��������
					 end if;
				 end case;
			 end if;
		end process;
		
		--������� ������� ��������
		wr<='1' when WRD='1' or st=mpyl or (st=mpy and rdym='1')
		or (START='1' and mult='0') else '0';
		RDY<='1' when st=mpyl or (WRD='0' and st/=mpy and mult='0')else'0';
		DO<=q; --�������� ������
		BO<=B;
		CNZ<=cnzi; --����� �������� ���������
	end BEH;