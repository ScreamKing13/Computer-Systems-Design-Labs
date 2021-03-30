-- Розрядність 12 біт 
-- Операція: A - B - C0, not A and B
--library IEEE;
--use IEEE.numeric_bit.all;
library cnetlist;
use cnetlist.all;
use cnetlist.Cnetwork_lib.all;
library IEEE;
use IEEE.std_logic_1164.all;   
use ieee.NUMERIC_BIT.all;

entity LSM is
	port(A,B: in bit_vector (11 downto 0); 
	C0: in bit;
	F: in bit;
	Y: out bit_vector (11 downto 0);
	N: out bit;
	CY: out bit;
	Z: out bit);
end LSM;

architecture BEH of LSM is
  signal ai, bi, b1i, yi: unsigned (12 downto 0);
  signal ybi: bit_vector (12 downto 0);

begin
  ai <= resize(unsigned(A), 13);
  bi <= resize(unsigned(B), 13);
  b1i <= bi + 1 when C0='1' else bi;
  yi <= ai + b1i; 
  with F select 
    ybi <= bit_vector(yi) when '0',
         '0'&(A or B) when '1';
  Y <= ybi(11 downto 0);
  N <= '0';
  CY <= ybi(12);
  Z <= '1' when ybi(11 downto 0) = "000000000000" else '0';
    
end BEH;
--architecture BEH of OPERATOR is
--	signal ai, bi, b1i, yi: signed (12 downto 0);
--	signal ybi: bit_vector (12 downto 0);
--
--begin
--	ai <= resize(signed(A), 13);
--	bi <= resize(signed(B), 13);
--	b1i <= bi + 1 when C0='1' else bi;
--	yi <= ai - b1i; 
--	with F select 
--		ybi <= bit_vector(yi) when '0',
--			   '0'&((not A) and B) when '1';
--	Y <= ybi(11 downto 0);
--	N <= ybi(12);
--	CY <= '1' xor ybi(12) when F = '0' else '0';
--    Z <= '1' when ybi(11 downto 0) = "000000000000" else '0';
--		
--end BEH;
 
--architecture STR_LUT of LSM is
--	signal C, X, yi, Ai, Bi: std_logic_vector (12 downto 0);
--	signal Zv: std_logic_vector (3 downto 0);
-- 	
----	component LUT3 is
---- 	generic(mask:bit_vector(7 downto 0):= X"ff";
---- 		td:time:=1 ns);
---- 	port(a : in BIT;
---- 		 b : in BIT;
---- 		 c : in BIT;
---- 		 Y : out BIT);
----    end component;
----	
----	component LUT4 is
---- 	generic(mask:bit_vector(15 downto 0):=X"ffff";
---- 		td:time:=1 ns);
---- 	port(a : in BIT;
---- 		 b : in BIT;
---- 		 c : in BIT;
----		 d : in BIT;
---- 		 Y : out BIT);
----    end component;
--
--	component LUT4 is
--		generic(INIT:bit_vector:= X"FFFF");
--		port( o: out std_ulogic;
--			i0: in std_ulogic;
--			i1: in std_ulogic;
--			i2: in std_ulogic;
--			i3: in std_ulogic);
--	end component;
--	
--	component LUT3 is
--		generic( INIT:bit_vector:= X"FF");
--		port( o: out std_ulogic;
--			i0: in std_ulogic;
--			i1: in std_ulogic;
--			i2: in std_ulogic);
--	end component;
--
--
--	
--	begin
--		c(0)<=C0;
--		Ai (11 downto 0) <= A;
--		Bi (11 downto 0) <= B;
--		Bi (12) <= '1';
--		-- Схема арифметико-логического устройства
--		LSM_STR:for i in 0 to 12 generate
--			LNI:LUT3 generic map(init=>X"9200")
--				port map(I0=>A(i),I1=>B(i),I2=> F, O =>X(i));
--			LNO:LUT3 generic map(init=>X"9300")
--				port map(I0=>C(i),I1=>X(i),I2=> F, O =>yi(i));
--			LNC:LUT3 generic map(init=>X"4D00")
--				port map(I0=>A(i),I1=>B(i),I2=> C(i), O =>c(i+1));
--		end generate;
--		
--		Y <= yi(11 downto 0);
--		N <= yi(12);
--		CY <= C(12);
--		
--		zero1: for i in 0 to 2 generate
--			Z: LUT4 generic map(init => x"0001")
--			port map(I0 => yi(i), I1 => yi(i+3), I2 => yi(i+6), I3 =>yi(i+9), O => Zv(i));
--		end generate;
--		
--		zero2: LUT4 generic map(init => x"8000")
--			port map(I0 => Zv(0), I1 => Zv(1), I2 => Zv(2), I3 => Zv(3), O => Z);
--	end STR_LUT;
