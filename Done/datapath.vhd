LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY WORK;
USE WORK.ALL;

ENTITY datapath IS
	PORT (
		clk : IN STD_LOGIC;
		resetb : IN STD_LOGIC;
		RESETX, RESETY, incr_y, incr_x, initl, drawl : IN STD_LOGIC;
		x : OUT STD_LOGIC_VECTOR(7 downto 0); -- x0
		y : OUT STD_LOGIC_VECTOR(6 downto 0);
		xin : IN STD_LOGIC_VECTOR(7 downto 0); -- x1
		yin : IN STD_LOGIC_VECTOR(6 downto 0);
		xdone, ydone, ldone : OUT STD_LOGIC
	);
END datapath;

ARCHITECTURE mixed OF datapath IS
BEGIN

	PROCESS(clk, resetb)
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
		VARIABLE error : signed(8 downto 0);
		VARIABLE e2 : signed(9 downto 0);
	BEGIN
		IF (resetb = '0') THEN
			y_tmp := "0000000";
			x_tmp := "00000000";
			x0 := "01010000";	-- 80
			y0 := "0111100";	-- 60
			x1 := "01010000";	-- 80
			y1 := "0111100";	-- 60
		ELSIF rising_edge(clk) THEN
		
			--initialize line
			IF (initl = '1') THEN
				x0 := x1;	-- 80
				y0 := y1;	-- 60
				x1 := unsigned(xin);	-- destination
				y1 := unsigned(yin);
				
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
				
				error := to_signed(to_integer(dx) - to_integer(dy), 9);
				ldone <= '0';
				
				
			--draw line loop
			ELSIF (drawl = '1') THEN
				x <= STD_LOGIC_VECTOR(x0);
				y <= STD_LOGIC_VECTOR(y0);
				
				-- Exit loop if we are at destination point
				IF (x0 = x1) THEN
					IF(y0 = y1) THEN
						ldone <= '1';
					END IF;
				ELSE
					e2 := signed(2*error)(9 downto 0);
					IF (e2 > -dy) THEN
						error := error - dy;
						x0 := unsigned(signed(x0) + sx);
					END IF;
					IF (e2 < dx) THEN
						error := error + dx;
						y0 := unsigned(signed(y0) + sy);
					END IF;
				END IF;
				
			--clear screen
			ELSE
				IF (RESETY = '1') THEN
					y_tmp := "0000000";
				ELSIF (INCR_Y = '1') THEN 
					y_tmp := y_tmp + 1;
					IF (y_tmp = 119) THEN
						YDONE <= '1';
					ELSE
						YDONE <= '0';
					END IF;
				END IF;
				
				Y <= std_logic_vector(y_tmp);
				
				IF (RESETX = '1') THEN
					x_tmp := "00000000";
				ELSIF (INCR_X = '1') THEN
					x_tmp := x_tmp + 1;
					IF (x_tmp = 159) THEN
						XDONE <= '1';
					ELSE
						XDONE <= '0';
					END IF;
				END IF;

				X <= std_logic_vector(x_tmp);
			END IF;
		END IF;
	END PROCESS;

END mixed;
