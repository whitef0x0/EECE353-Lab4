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
		resetx, resety, incr_y, incr_x, plot, initl, drawl : OUT STD_LOGIC;
		colour : OUT STD_LOGIC_VECTOR(2 downto 0);
		x : OUT STD_LOGIC_VECTOR(7 downto 0);
		y : OUT STD_LOGIC_VECTOR(6 downto 0);
		ledg : OUT STD_LOGIC_VECTOR(7 downto 0)
	);
END fsm;

ARCHITECTURE behavioural OF fsm IS
  TYPE state_types is (CLEAR_START, CLEAR_NEXTROW, CLEAR_NEXTCOL, LOAD_INPUT, INIT_LINE, DRAW_LINE, DONE_LINE);
  SIGNAL curr_state, next_state : state_types := CLEAR_START;
BEGIN

	PROCESS(clock, resetb)
		--VARIABLE next_state : state_types;
	BEGIN
		IF (resetb = '0') THEN
			curr_state <= CLEAR_START;
		ELSIF rising_edge(clock) THEN
			curr_state <= next_state;
		END IF;
	END PROCESS;


	
	PROCESS(curr_state, next_state)
	BEGIN
		CASE curr_state IS
			WHEN CLEAR_START => 
				resetx <= '1';
				resety <= '1';
				incr_y <= '1';
				incr_x <= '1';
				INITL <= '0';
				DRAWL <= '0';
				PLOT <= '0';
				
				colour <= "000";
				ledg <= "00000000";
				next_state := CLEAR_NEXTCOL;
			
			--Clear next row
			WHEN CLEAR_NEXTROW => 
				resetx <= '1';
				resety <= '0';
				incr_y <= '1';
				incr_x <= '1';
				INITL <= '0';
				DRAWL <= '0';
				PLOT <= '0';
				
				ledg <= "00000001";
				next_state := CLEAR_NEXTCOL;
			
			--Clear next column
			WHEN CLEAR_NEXTCOL => 
				resetx <= '0';
				resety <= '0';
				incr_y <= '0';
				incr_x <= '1';
				INITL <= '0';
				DRAWL <= '0';
				PLOT <= '1';
				
				ledg <= "00000010";
				IF (XDONE = '0') THEN
					next_state := CLEAR_NEXTCOL;
				ELSIF (XDONE = '1' AND YDONE = '0') THEN
					next_state := CLEAR_NEXTROW;
				ELSE 
					next_state := LOAD_INPUT;
				END IF;
				
			when LOAD_INPUT =>
				
				resetx <= '0';
				resety <= '0';
				incr_y <= '0';
				incr_x <= '0';
				INITL <= '0';
				DRAWL <= '0';
				PLOT <= '0';
			
				ledg <= "00000100";
				
				--When draw signal is low, initialize line with input
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
					next_state := LOAD_INPUT;
				END IF;
				
			WHEN INIT_LINE =>
				resetx <= '0';
				resety <= '0';
				incr_y <= '0';
				incr_x <= '0';
				INITL <= '1';
				DRAWL <= '0';
				PLOT <= '0';
				
				ledg <= "00001000";
				--colour <= "000";
				colour <= sw(2 downto 0);
				next_state := DRAW_LINE;
				
			WHEN DRAW_LINE =>
				colour <= sw(2 downto 0);
			
				resetx <= '0';
				resety <= '0';
				incr_y <= '0';
				incr_x <= '0';
				INITL <= '0';
				DRAWL <= '1';
				PLOT <= '1';
				ledg <= "00010000";
				
				--If line is done drawing, move to finished line (DONE_LINE) state
				IF (LDONE = '1') THEN
					ledg <= "11111111";
					next_state := DONE_LINE;
				ELSE
					next_state := DRAW_LINE;
				END IF;
				
				
			WHEN DONE_LINE =>
				resetx <= '0';
				resety <= '0';
				incr_y <= '0';
				incr_x <= '0';
				INITL <= '0';
				DRAWL <= '0';
				PLOT <= '0';
				next_state := LOAD_INPUT;
			
			WHEN others => 
				resetx <= '0';
				resety <= '0';
				incr_y <= '0';
				incr_x <= '0';
				INITL <= '0';
				DRAWL <= '0';
				PLOT <= '0';
				next_state := DONE_LINE;
		END CASE;
	END PROCESS;
		
END behavioural;
