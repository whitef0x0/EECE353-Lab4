LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY WORK;
USE WORK.ALL;

ENTITY datapath_challenge IS
	PORT (
		clock : IN STD_LOGIC;
		resetb : IN STD_LOGIC;
		initx, inity, loady, loadx, initl, drawl : IN STD_LOGIC;
		x : OUT STD_LOGIC_VECTOR(7 downto 0); -- x0
		y : OUT STD_LOGIC_VECTOR(6 downto 0);
		xin : IN STD_LOGIC_VECTOR(7 downto 0); -- x1
		yin : IN STD_LOGIC_VECTOR(6 downto 0);
		initLoad: IN STD_LOGIC;
		ledr: OUT STD_LOGIC_VECTOR(17 downto 0);
		xdone, ydone, ldone : OUT STD_LOGIC
	);
END datapath_challenge;

ARCHITECTURE mixed OF datapath_challenge IS
  SIGNAL x_old : unsigned(7 downto 0);
  SIGNAL y_old : unsigned(6 downto 0);
BEGIN

	PROCESS(clock, resetb)
		VARIABLE x_tmp : unsigned(7 downto 0) := "00000000";
		VARIABLE y_tmp : unsigned(6 downto 0) := "0000000";
		
		VARIABLE dx : signed(8 downto 0);
		VARIABLE dy : signed(7 downto 0);
		VARIABLE x0 : unsigned(7 downto 0) := "01010000";	-- 80
		VARIABLE y0 : unsigned(6 downto 0) := "0111100";	-- 60
		VARIABLE x1 : unsigned(7 downto 0) := "01010000";
		VARIABLE y1 : unsigned(6 downto 0) := "0111100";		
		VARIABLE sx : signed(1 downto 0);
		VARIABLE sy : signed(1 downto 0);
		VARIABLE err : signed(8 downto 0);
		VARIABLE e2 : signed(9 downto 0);
	BEGIN
		IF (resetb = '0') THEN
			y_tmp := "0000000";
			x_tmp := "00000000"; 
			x0 := "01010000";	-- 80
			y0 := "0111100";	-- 60
			x1 := "01010000";	-- 80
			y1 := "0111100";	-- 60
		ELSIF rising_edge(clock) THEN
		
		  --initialize line if flag is set
			IF (initl = '1') THEN
			
			  if(initLoad = '1') THEN
				  x0 := x1;	-- 80
				  y0 := y1;	-- 60
				ELSE
				  x0 := x_old;
				  y0 := y_old;
				  LEDR(17 downto 11) <= y_old;
				  
				END IF;
				
				x1 := unsigned(xin);	-- destination point
				x_old <= x1;
				y1 := unsigned(yin); -- destination point
				y_old <= y1;
				LEDR(9 downto 3) <= y1;
				
				dx := to_signed(abs(to_integer(x1) - to_integer(x0)), 9);
				dy := to_signed(abs(to_integer(y1) - to_integer(y0)), 8);
				IF (x0 < x1) THEN
					sx := to_signed(1, 2);
				ELSE
					sx := to_signed(-1, 2);
				END IF;
				IF (y0 < y1) THEN
					sy := to_signed(1, 2);
				ELSE
					sy := to_signed(-1, 2);
				END IF;
				err := to_signed(to_integer(dx) - to_integer(dy), 9);
				ldone <= '0';
			
			--Draw line if flag is set
			ELSIF (drawl = '1') THEN
				X <= STD_LOGIC_VECTOR(x0);
				Y <= STD_LOGIC_VECTOR(y0);
				IF ((x0 = x1) and (y0 = y1)) THEN
					ldone <= '1';
				ELSE
					e2 := signed(2*err)(9 downto 0);
					IF (e2 > -dy) THEN
						err := err - dy;
						x0 := unsigned(signed(x0) + sx);
					END IF;
					IF (e2 < dx) THEN
						err := err + dx;
						y0 := unsigned(signed(y0) + sy);
					END IF;
				END IF;
				
			-- Screen clearing logic
			ELSE
				IF (INITY = '1') THEN
					y_tmp := "0000000";
				ELSIF (LOADY = '1') THEN 
					y_tmp := y_tmp + 1;
				END IF;
				
				IF (y_tmp = 119) THEN
					YDONE <= '1';
				ELSE
					YDONE <= '0';
				END IF;
				
				Y <= std_logic_vector(y_tmp);
				
				IF (INITX = '1') THEN
					x_tmp := "00000000";
				ELSIF (LOADX = '1') THEN
					x_tmp := x_tmp + 1;
				END IF;
				
				IF (x_tmp = 159) THEN
					XDONE <= '1';
				ELSE
					XDONE <= '0';
				END IF;
			
				X <= std_logic_vector(x_tmp);
				
			END IF;
		END IF;
	END PROCESS;

END mixed;
