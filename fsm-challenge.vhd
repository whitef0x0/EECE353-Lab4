LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY WORK;
USE WORK.ALL;

ENTITY fsm IS
	PORT (
		clock : IN STD_LOGIC;
		resetb : IN STD_LOGIC;
		xdone, ydone, ldone : IN STD_LOGIC;
		sw : IN STD_LOGIC_VECTOR(17 downto 0);
		draw : IN STD_LOGIC;
		initx, inity, loady, loadx, plot, initl, drawl : OUT STD_LOGIC;
		colour : OUT STD_LOGIC_VECTOR(2 downto 0);
		x : OUT STD_LOGIC_VECTOR(7 downto 0);
		y : OUT STD_LOGIC_VECTOR(6 downto 0);
		ledg : OUT STD_LOGIC_VECTOR(7 downto 0);
		initLoad : OUT STD_LOGIC
	);
END fsm;

ARCHITECTURE behavioural OF fsm IS
  TYPE state_types is (START, LOAD_Y, LOAD_X, LOAD_DONE, INIT_LINE, DRAW_LINE, DONE_LINE);
  SIGNAL curr_state, next_state : state_types := START;
  
  SIGNAL loadCount : integer := 0;
BEGIN

	PROCESS(clock, resetb)
		--VARIABLE next_state : state_types;
	BEGIN
		IF (resetb = '0') THEN
			curr_state <= START;
			loadCount <= 0;
		ELSIF rising_edge(clock) THEN
			curr_state <= next_state;
			IF(next_state = DONE_LINE) THEN
			  loadCount <= loadCount + 1;
			END IF;
		END IF;
	END PROCESS;


	
	PROCESS(curr_state, next_state)
	BEGIN
		CASE curr_state IS
			WHEN START => 
				INITX <= '1';
				INITY <= '1';
				LOADY <= '1';
				LOADX <= '1';
				INITL <= '0';
				DRAWL <= '0';
				PLOT <= '0';
				initLoad <= '0';
				
				colour <= "111";
				ledg <= "00000000";
				next_state := LOAD_X;
			WHEN LOAD_Y => 
				INITX <= '1';
				INITY <= '0';
				LOADY <= '1';
				LOADX <= '1';
				INITL <= '0';
				DRAWL <= '0';
				PLOT <= '0';
				
				IF(loadCount > 0) THEN
				  initLoad <= '1';
				ELSE
				  initLoad <= '0';
				END IF;
				
				ledg <= "00000001";
				next_state := LOAD_X;
				
			WHEN LOAD_X => 
				INITX <= '0';
				INITY <= '0';
				LOADY <= '0';
				LOADX <= '1';
				INITL <= '0';
				DRAWL <= '0';
				PLOT <= '1';
				
				IF(loadCount > 0) THEN
				  initLoad <= '1';
				ELSE
				  initLoad <= '0';
				END IF;
				
				ledg <= "00000010";
				IF (XDONE = '0') THEN
					next_state := LOAD_X;
				ELSIF (XDONE = '1' AND YDONE = '0') THEN
					next_state := LOAD_Y;
				ELSE 
					next_state := LOAD_DONE;
				END IF;
				
			when LOAD_DONE =>
				
				INITX <= '0';
				INITY <= '0';
				LOADY <= '0';
				LOADX <= '0';
				INITL <= '0';
				DRAWL <= '0';
				PLOT <= '0';
			
				ledg <= "00000100";
				IF (draw = '0') THEN
					x <= sw(17 downto 10);
					y <= sw(9 downto 3);
					--Clip input to within bounds
					IF (unsigned(sw(17 downto 10)) > 159) THEN
						x <= "10011111";
					END IF;
					IF unsigned(sw(9 downto 3)) > 119) THEN
						y <= "1110111";
					END IF;
					
					next_state := INIT_LINE;
				ELSE
					next_state := LOAD_DONE;
				END IF;
				
			WHEN INIT_LINE =>
				INITX <= '0';
				INITY <= '0';
				LOADY <= '0';
				LOADX <= '0';
				INITL <= '1';
				DRAWL <= '0';
				PLOT <= '0';
				
				colour <= "000";
				next_state := DRAW_LINE;
				
			WHEN DRAW_LINE =>
				INITX <= '0';
				INITY <= '0';
				LOADY <= '0';
				LOADX <= '0';
				INITL <= '0';
				DRAWL <= '1';
				PLOT <= '1';
				IF (LDONE = '1') THEN
					ledg <= "11111111";
					next_state := DONE_LINE;
				ELSE
					next_state := DRAW_LINE;
				END IF;
				
				
			WHEN DONE_LINE =>
				INITX <= '0';
				INITY <= '0';
				LOADY <= '0';
				LOADX <= '0';
				INITL <= '0';
				DRAWL <= '0';
				PLOT <= '0';
				next_state := LOAD_DONE;
			
			WHEN others => 
				INITX <= '0';
				INITY <= '0';
				LOADY <= '0';
				LOADX <= '0';
				INITL <= '0';
				DRAWL <= '0';
				PLOT <= '0';
				next_state := DONE_LINE;
		END CASE;
	END PROCESS;
		
END behavioural;
