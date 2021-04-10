library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Uart_Rx is

generic(
clk_freq  : integer := 100_000_000;
baud_rate : integer := 9600);

port(clk, rst: in std_logic;
outp: out std_logic_vector(7 downto 0);
rx: in std_logic);

end Uart_Rx;

architecture Behavioral of Uart_Rx is

type state is(S_Start_Stop,S_Recieve_Data);
signal present_state,next_state: state:= S_Start_Stop;

constant sending_clock_timer_limit : integer := (clk_freq/(2*baud_rate));
signal   sending_clock_timer   	   : positive range 1 to sending_clock_timer_limit :=1;
signal   clk_baudrate : std_logic :='0';

constant max_bit_length : natural :=8;
signal   bit_index      : natural range 0 to (max_bit_length -1) ;
signal 	 bit_timer 		: natural range 0 to  max_bit_length;

begin

Clock_division_process: process(clk,rst)
begin
	if (rst='1') then 
		sending_clock_timer<=1;
	elsif(rising_edge(clk)) then
		sending_clock_timer<=sending_clock_timer+1;
		if (sending_clock_timer=sending_clock_timer_limit) then
			clk_baudrate<= not clk_baudrate;
			sending_clock_timer<=1;
		end if;
	end if;
end process;

State_based_timer_process: process(clk_baudrate,rst)

begin
	if (rst='1') then 
		present_state<=S_Start_Stop;
		bit_index<=0;
	elsif(rising_edge(clk_baudrate)) then
		if(bit_index=bit_timer-1) then
			present_state<=next_state;
			bit_index<=0;
		else
			bit_index<=bit_index+1;
		end if;
	end if;
end process;

Uart_Receive_Process: process(present_state,rx)
begin
	case present_state is 
	
		when S_Start_Stop =>
			bit_timer<=1;
			if (rx='1') then
				next_state<=S_Start_Stop;
			else
				next_state<=S_Recieve_Data;
			end if;
			
		when S_Recieve_Data =>
			bit_timer<=8;
			outp(bit_index)<=rx;
			next_state<=S_Start_Stop;
		end case;
	end process;
end Behavioral;
