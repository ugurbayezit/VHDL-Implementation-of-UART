library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Uart_Tx is

generic(
clk_freq  : integer := 100_000_000;
baud_rate : integer := 9600);
port(
clk,trig,rst : in std_logic;
data_to_send : in std_logic_vector(7 downto 0);
tx,tx_done 	 : out std_logic);

end Uart_Tx;

architecture Behavioral of Uart_Tx is

type state is(S_Idle,S_Start,S_Sending_data,S_Stop);
signal present_state,next_state: state:= S_Idle;

constant sending_clock_timer_limit : integer := clk_freq/(2*baud_rate);
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
		if (sending_clock_timer_limit=sending_clock_timer) then 
			clk_baudrate<= not clk_baudrate;
			sending_clock_timer<=1;
		end if;
	end if;
end process;

State_based_timer_process: process(clk_baudrate,rst)

begin
	if (rst='1') then 
		present_state<=S_Idle;
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

Uart_Transmit_Process: process(present_state,trig)
begin
	case present_state is 
	
		when S_Idle =>
			bit_timer<=1;
			tx<='1';
			tx_done<='0';
			if (trig='1') then
				next_state<=S_Start;
			else
				next_state<=S_Idle;
			end if;
			
		when S_Start =>
			bit_timer<=1;
			tx<='0';
			next_state<=S_Sending_data;
			
		when S_Sending_data =>
			bit_timer<=8;
			tx<=data_to_send(bit_index);
			next_state<=S_Stop;
			
		when S_Stop =>
			tx<='1';
			bit_timer<=1;
			tx_done<='1';
			if (trig='0') then
				next_state<=S_Idle;
			else
				next_state<=S_Start;
			end if;
			
		end case;
	end process;
end Behavioral;
