library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lab4 is
  port(CLOCK_50            : in  std_logic;
       KEY                 : in  std_logic_vector(3 downto 0);
       SW                  : in  std_logic_vector(17 downto 0);
       LEDG						: out std_logic_vector(7 downto 0);
       VGA_R, VGA_G, VGA_B : out std_logic_vector(9 downto 0);  -- The outs go to VGA controller
       VGA_HS              : out std_logic;
       VGA_VS              : out std_logic;
       VGA_BLANK           : out std_logic;
       VGA_SYNC            : out std_logic;
       VGA_CLK             : out std_logic);
end lab4;

architecture rtl of lab4 is

 -- Component from the Verilog file: vga_adapter.v
	component vga_adapter
		generic(RESOLUTION : string);
		port (
			 resetn                                       : in  std_logic;
			 clock                                        : in  std_logic;
			 colour                                       : in  std_logic_vector(2 downto 0);
			 x                                            : in  std_logic_vector(7 downto 0);
			 y                                            : in  std_logic_vector(6 downto 0);
			 plot                                         : in  std_logic;
			 VGA_R, VGA_G, VGA_B                          : out std_logic_vector(9 downto 0);
			 VGA_HS, VGA_VS, VGA_BLANK, VGA_SYNC, VGA_CLK : out std_logic);
	  end component;
  
	component fsm is
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
	end component;	
	
	component datapath is
		PORT (
			clock : IN STD_LOGIC;
			resetb : IN STD_LOGIC;
			resetx, resety, incr_y, incr_x, initl, drawl : IN STD_LOGIC;
			x : OUT STD_LOGIC_VECTOR(7 downto 0);
			y : OUT STD_LOGIC_VECTOR(6 downto 0);
			xin : IN STD_LOGIC_VECTOR(7 downto 0); -- x1
			yin : IN STD_LOGIC_VECTOR(6 downto 0); -- y1
			xdone, ydone, ldone : OUT STD_LOGIC
		);
	end component;

  signal s_x      : std_logic_vector(7 downto 0) := "00000000";
  signal s_y      : std_logic_vector(6 downto 0) := "0000000";
  signal colour : std_logic_vector(2 downto 0);
  signal plot   : std_logic;
  
  signal resety, resetx, initl : std_logic;
  signal xdone, ydone, ldone : std_logic;
  signal incr_y, incr_x, drawl : std_logic;

  signal x_int      : std_logic_vector(7 downto 0);
  signal y_int      : std_logic_vector(6 downto 0);


begin


  vga_u0 : vga_adapter
    generic map(RESOLUTION => "160x120") 
    port map(resetn    => KEY(3),
             clock     => CLOCK_50,
             colour    => colour,
             x         => s_x,
             y         => s_y,
             plot      => plot,
             VGA_R     => VGA_R,
             VGA_G     => VGA_G,
             VGA_B     => VGA_B,
             VGA_HS    => VGA_HS,
             VGA_VS    => VGA_VS,
             VGA_BLANK => VGA_BLANK,
             VGA_SYNC  => VGA_SYNC,
             VGA_CLK   => VGA_CLK
		);

	fsm0 : fsm PORT MAP(
		clock		=> CLOCK_50,
		resetb		=> KEY(3),
		xdone		=> xdone,
		ydone		=> ydone,
		ldone		=> ldone,
		sw		=> SW,
		draw		=> KEY(0),
		resetx		=> resetx,
		resety		=> resety,
		incr_y		=> incr_y,
		incr_x		=> incr_x,
		plot		=> plot,
		initl		=> initl,
		drawl		=> drawl,
		colour		=> colour,
		x		=> x_int,
		y		=> y_int,
		ledg		=> LEDG
	);
		
	datapath0 : datapath PORT MAP(
		clock		=> CLOCK_50,
		resetb		=> KEY(3),
		resetx		=> resetx,
		resety		=> resety,
		initl		=> initl,
		drawl		=> drawl,
		x		=> s_x,
		y		=> s_y,
		xin		=> x_int,
		yin		=> y_int,
		xdone		=> xdone,
		ydone		=> ydone,
		ldone		=> ldone,
		incr_y		=> incr_y,
		incr_x		=> incr_x
	);
end rtl;
