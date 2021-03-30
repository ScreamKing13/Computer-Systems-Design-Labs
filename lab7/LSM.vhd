library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity LSM is
	port(A,B: in STD_LOGIC_VECTOR (15 downto 0); 
	C0: in STD_LOGIC;
	F: in STD_LOGIC_VECTOR (1 downto 0);
	Y: out STD_LOGIC_VECTOR (15 downto 0);
	N: out STD_LOGIC;
	CY: out STD_LOGIC;
	Z: out STD_LOGIC);
end LSM;

architecture BEH of LSM is
  signal ai, bi, b1i, yi: signed (16 downto 0);
  signal ybi: STD_LOGIC_VECTOR (16 downto 0);

begin
  ai <= resize(signed(A), 17);
  bi <= resize(signed(B), 17); 
  b1i <= bi + 1 when C0='1' else bi;
  with F select 
  ybi <= '0'&(A and B) when "00",
  		 '0'&(A xor B) when "01",
         STD_LOGIC_VECTOR(ai + b1i) when "10",
		 STD_LOGIC_VECTOR(ai - bi) when others;
  Y <= ybi(15 downto 0);
  N <= ybi(16) when F(1)='1' else '0';
  with F select
  CY <= '1' xor ybi(16) when "11", 
  		ybi(16) when "10",
  		'0' when others;
  Z <= '1' when ybi(15 downto 0) = "0000000000000000" else '0';
    
end BEH;

