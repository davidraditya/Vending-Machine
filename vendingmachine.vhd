LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL; 
ENTITY hitunguang IS
	PORT(
-- Untuk mangakumulasi uang yang dimasukkan
	CLOCK, U5R, U10R, Reset : IN STD_LOGIC;
	SM1, SM2, SM3, SK : OUT STD_LOGIC;
	PM1, PM2, PM3 : IN STD_LOGIC); -- Tombol AmbiL Minum
	SIGNAL DIV : BIT; 
END hitunguang; 

ARCHITECTURE behavioral OF hitunguang IS
CONSTANT LRts 	  : STD_LOGIC_VECTOR(2 DOWNTO 0) := "001";
CONSTANT SRb 	  : STD_LOGIC_VECTOR(2 DOWNTO 0) := "010";
TYPE executionStage IS (A,B,C,D);
SIGNAL currentstate,nextstate:executionStage;
 
SIGNAL Total	: STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
SIGNAL S_M1, S_M2, S_M3, S_K : STD_LOGIC;
 
COMPONENT CLOCKDIV
	PORT(	CLK: IN std_logic;
		DIVOUT: buffer BIT);
END COMPONENT; 

BEGIN
TEST : CLOCKDIV PORT MAP (DIVOUT => DIV, CLK => CLOCK); 

PROCESS(U5R, U10R, PM1, PM2, PM3, DIV) 

-- Keterangan : Signal Total memakai bilangan biner 3 bit, dengan 
-- representasi '000' = 0, '001' = 500, '010' = 1000, dst.
BEGIN
--Total := "000";
--IF( DIV'EVENT ) AND ( DIV = '1' ) THEN
 
	IF (U5R = '1') THEN
		IF (Total <= "111") THEN
		Total <= Total + LRts;
		ELSE
		Total <= Total + "000";
		END IF;
	END IF;
	IF (U10R = '1') THEN
		IF (Total <= "111") THEN
		Total <= Total + SRb;
		ELSE
		Total <= Total + "000";
		END IF;
	IF (Reset = '1') THEN
		Total <= "000";
	END IF;
--	END IF; 

-- Pengambilan Uang
	IF (PM1 = '1') AND (S_M1 = '1') THEN
		Total <= Total - "001";
	ELSIF (PM1 = '1') AND (S_M1 = '0') THEN
		Total <= Total - "000";
	END IF;
	IF (PM2 = '1') AND (S_M2 = '1') THEN
		Total <= Total - "010";
	ELSIF (PM2 = '1') AND (S_M2 = '0') THEN
		Total <= Total - "000";
	END IF;
	IF (PM3 = '1') AND (S_M3 = '1') THEN
		Total <= Total - "110";
	ELSIF (PM3 = '1') AND (S_M3 = '0') THEN
		Total <= Total - "000";
	END IF; 

END IF; 

END PROCESS; 

PROCESS(currentstate, Total, DIV, Reset) 
-- Penggantian antara bisa dibeli atau tidak
BEGIN 
-- Keterangan : Signal Total memakai bilangan biner 3 bit, dengan\
-- representasi '000' = 0, '001' = 500, '010' = 1000, dst.
IF (Reset = '1') THEN
currentstate <= A;
ELSIF( DIV'EVENT ) AND ( DIV = '1' ) THEN 

CASE currentstate IS
	when A => -- Total Uang 0 / State Awal 

				S_M1 <= '0';
				S_M2 <= '0';
				S_M3 <= '0';
				S_K <= '0';
				SM1 <= '0';
				SM2 <= '0';
				SM3 <= '0';
				SK <= '0';

		IF (Total = "000") THEN 
	
			currentstate <= A ; 
	
		ELSIF (Total = "001") THEN
			currentstate <= B ;
 	
		ELSIF (Total >= "010") AND (Total < "110") THEN
			currentstate <= C ;
 	
		ELSIF (Total >= "110") THEN
			currentstate <= D ; 
	
		ELSE 
			currentstate <= currentstate;
		END IF; 
	
	when B => -- Uang yang dimasukkan antara 500 -> 1000

				S_M1 <= '1';
				S_M2 <= '0';
				S_M3 <= '0';
				S_K <= '1';
				SM1 <= '1';
				SM2 <= '0';
				SM3 <= '0';
				SK <= '1';

		IF (Total = "000") THEN

			currentstate<= A ;

		ELSIF (Total = "001") THEN
			currentstate <= B ;

		ELSIF (Total >= "010") AND (Total < "110") THEN 
			currentstate <= C ; 

		ELSIF (Total >= "110") THEN
			currentstate <= D ; 
		ELSE 
			currentstate <= currentstate;
		END IF;

	when C => -- Uang yang dimasukkan antara 1000 -> 3000

			S_M1 <= '1';
				S_M2 <= '1';
				S_M3 <= '0';
				S_K <= '1';
				SM1 <= '1';
				SM2 <= '1';
				SM3 <= '0';
				SK <= '1'; 

		IF (Total = "000") THEN

			currentstate<= A ;
 
		ELSIF (Total = "001") THEN
			currentstate <= B ;
 
		ELSIF (Total >= "010") AND (Total < "110") THEN
			currentstate <= C ;
 
		ELSIF (Total >= "110") THEN
			currentstate <= D ; 

		ELSE 
			currentstate <= currentstate;
		END IF;
	when D => -- Uang yang dimasukkan Lebih dari 3000 

				S_M1 <= '1'; 
				S_M2 <= '1'; 
				S_M3 <= '1'; 
				S_K <= '1'; 
				SM1 <= '1'; 
				SM2 <= '1'; 
				SM3 <= '1'; 
				SK <= '1'; 

		IF (Total = "000") THEN

			currentstate<= A ;

		ELSIF (Total = "001") THEN 
			currentstate <= B ;

		ELSIF (Total >= "010") AND (Total < "110") THEN
			currentstate <= C ; 
		
		ELSIF (Total >= "110") THEN
			currentstate <= D ; 

		ELSE 
			currentstate <= currentstate;
		END IF; 
	END CASE;
END IF;
END PROCESS; 
END behavioral;