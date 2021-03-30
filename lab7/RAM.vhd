
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity RAM is
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
end RAM;		  

architecture BEH of RAM is
	type MEM8KX16 is array(0 to 8191) of STD_LOGIC_VECTOR(15 downto 0);
	constant R0: std_logic_VECTOR(2 downto 0) :="000";
	constant R1: std_logic_VECTOR(2 downto 0) :="001";
	constant R2: std_logic_VECTOR(2 downto 0) :="010";
	constant R3: std_logic_VECTOR(2 downto 0) :="011";
	constant R4: std_logic_VECTOR(2 downto 0) :="100";
	constant R5: std_logic_VECTOR(2 downto 0) :="101";
	constant R6: std_logic_VECTOR(2 downto 0) :="110";
	constant R7: std_logic_VECTOR(2 downto 0) :="111";
	constant RR0: std_logic_VECTOR(5 downto 0):="000000";
	-- Operations -- 
	constant BRA:  std_logic_VECTOR(2 downto 0) :="000";
	constant LJMP: std_logic_VECTOR(2 downto 0) :="001";
	constant CALL: std_logic_VECTOR(2 downto 0) :="010";
	constant LD:   std_logic_VECTOR(6 downto 0) :="0110000";
	constant SD:   std_logic_VECTOR(6 downto 0) :="0110100";
	constant \IN\: std_logic_VECTOR(4 downto 0) :="01110";
	constant \OUT\:std_logic_VECTOR(4 downto 0) :="01111";
	constant ALOP: std_logic_VECTOR(2 downto 0) :="100";
	constant LI:   std_logic_VECTOR(6 downto 0) :="1010000";
	constant RET:  std_logic_VECTOR(15 downto 0):="1100000000000000";
	constant NOOP: std_logic_VECTOR(15 downto 0):="0000000000000000"; 
	-- ALU Operations --								   
	constant \AND\:  std_logic_VECTOR(6 downto 0) :="1000000"; -- AND 000
	constant SUB:  std_logic_VECTOR(6 downto 0) :="1000011"; --	Sub 011
	constant \XOR\:std_logic_VECTOR(6 downto 0) :="1000001"; --	Xor 001
	constant ADD:std_logic_VECTOR(6 downto 0) :="1000010"; --	ADD 010
	constant \SRL\:std_logic_VECTOR(6 downto 0) :="1000100"; -- SRL 110
	constant SP:   std_logic_VECTOR(6 downto 0) :="1000101"; --	SP  111
	-- Commands --
	constant NOP:  std_logic_VECTOR(2 downto 0) :="000";
	constant JUMP: std_logic_VECTOR(2 downto 0) :="001";
	constant NEQ:  std_logic_VECTOR(2 downto 0) :="010";
	constant EQ:   std_logic_VECTOR(2 downto 0) :="011";
	constant GE:   std_logic_VECTOR(2 downto 0) :="100";
	constant LT:   std_logic_VECTOR(2 downto 0) :="101";
	constant NCY:  std_logic_VECTOR(2 downto 0) :="110";
	constant CY:   std_logic_VECTOR(2 downto 0) :="111";
	constant RAM_init: MEM8KX16:= (
	0=> SUB &R0&R0&R0, -- R0=0 -1я команда
	1=> LI &R1&RR0, -- непосредственная константа в R1
	2=> X"0040", -- константа –2-е слово команды
	3=> LD &R2&R1&R0, -- данное в R2 из RAM[R1]
	4=> ADD &R1&R1&R0, -- R1=R1+1
	5=> SUB &R2&R0&R2, -- вычли 1: R2=R2-1, т.е. счетчик
	6=> BRA &NEQ&"1111111101", --переход на адрес-2, если не 0
	7=> LJMP &"0000000110000", -- длинный переход на адрес 48
	8=> CALL &"0000000100000", -- вызов ПП по адресу 32
	9=> \SRL\ &R2&R0&R4,
	10=> SD &R0&R2&R6, -- по адресу (R2) записывает операнд из R6,
	11=> NOOP,
	12=> BRA & JUMP&"1111111111", --вечный цикл окончания программы
	-- Подпрограмма -----
	-- умножает число R4 на число из периферийного устройства 001 и
	-- старшее слово результата записывает в периферийное устройство 001
	32=> \IN\ &"00"&R3&"001"&R0, -- ввод данного
	33=> \XOR\ &R5&R4&R3, -- R5,R6=R4*R3
	34=> \OUT\ &"00"&R0&"001"&R5, -- вывод данного
	35=> RET,
	-- Отработка длинного перехода
	48=> \AND\ &R4&R1&R1, -- R4=R1+R1
	49=> LJMP &"0000000001000", -- переход на адрес 8
	-- Область данных
	64=> X"0004", -- исходное данное
	others=> X"0000"
	);
	shared variable RAM: MEM8KX16:= RAM_init; 
	
	begin		
		------ блок памяти ------------------
		P1:process(CLK)
		begin
	 		if CLK='1' and CLK'event then
				 if EN1='1' then				 
					if WR = '1' then
		 				RAM(to_integer(unsigned(AD1))):= ID; -- запись 
					end if;			 
					
					-- тристабильный выходной буфер ---------------------   
		 			if (OE = '1') then
						if R='1' then 
							OD1 <= X"0000";
						else 
							OD1 <= RAM(to_integer(unsigned(AD1)));
						end if;
					else 
						OD1 <= (others => 'Z');
					end if;
				 end if;
	 		end if;
		end process;
		
		P2:process(CLK)
		begin
	 		if CLK='1' and CLK'event then			 
				OD2 <= RAM(to_integer(unsigned(AD2)));
	 		end if;
		end process;
		   
end BEH;