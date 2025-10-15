library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity axi4_lite_slave_tb is
end axi4_lite_slave_tb;

architecture behaviour of axi4_lite_slave_tb is
    constant C_AXI_ADDRESS_WIDTH: integer := 4;
    constant C_NUM_REGISTERS: integer := 3;
    constant C_START_TIME: time := 1 us;
    constant C_CLOCK_FREQUENCY: real := 100.0E6;
    constant C_CLOCK_PHASE: time := 0 fs;

    procedure clock_generator(signal CLK : out std_logic; 
                              constant FREQ : real; 
                              PHASE : time := 0 fs; 
                              signal RUN : std_logic) is
        constant HIGH_TIME   : time := 0.5 sec / FREQ;
        variable low_time_v  : time;
        variable cycles_v    : real := 0.0;
        variable freq_time_v : time := 0 fs;
    begin
        assert (HIGH_TIME /= 0 fs) report "clk_gen: High time is zero; time resolution to large for frequency" severity FAILURE;
        clk <= '0';
        wait for PHASE;
        loop
            if (run = '1') or (run = 'H') then
                clk <= run;
            end if;
            wait for HIGH_TIME;
            clk <= '0';
            low_time_v := 1 sec * ((cycles_v + 1.0) / FREQ) - freq_time_v - HIGH_TIME; 
            wait for low_time_v;
            cycles_v := cycles_v + 1.0;
            freq_time_v := freq_time_v + HIGH_TIME + low_time_v;
        end loop;
    end procedure;

    signal S_CLOCK_EN: std_logic := '0';
    signal S_AXI_ACLK: std_logic := '0';
    signal S_AXI_ARESETN: std_logic := '0';
    signal S_AXI_AWADDR: std_logic_vector(C_AXI_ADDRESS_WIDTH - 1 downto 0) := (others => '0');
    signal S_AXI_AWPROT: std_logic_vector(2 downto 0) := (others => '0');
    signal S_AXI_AWVALID: std_logic := '0';
    signal S_AXI_AWREADY: std_logic := '0';
    signal S_AXI_WVALID: std_logic := '0';
    signal S_AXI_WREADY: std_logic := '0';
    signal S_AXI_BRESP: std_logic_vector(1 downto 0) := (others => '0');
    signal S_AXI_BVALID: std_logic := '0';
    signal S_AXI_BREADY: std_logic := '0';
    signal S_AXI_ARADDR: std_logic_vector(C_AXI_ADDRESS_WIDTH - 1 downto 0) := (others => '0');
    signal S_AXI_ARPROT: std_logic_vector(2 downto 0) := (others => '0');
    signal S_AXI_ARVALID: std_logic := '0';
    signal S_AXI_ARREADY: std_logic := '0';
    signal S_AXI_RRESP: std_logic_vector(1 downto 0) := (others => '0');
    signal S_AXI_RVALID: std_logic := '0';
    signal S_AXI_RREADY: std_logic := '0';
    signal REGISTER_WR: std_logic_vector(C_NUM_REGISTERS - 1 downto 0) := (others => '0');
    signal REGISTER_RD: std_logic_vector(C_NUM_REGISTERS - 1 downto 0) := (others => '0');
begin
    clock_generator(CLK => S_AXI_ACLK,
                    FREQ => C_CLOCK_FREQUENCY,
                    PHASE => C_CLOCK_PHASE,
                    RUN => S_CLOCK_EN);

    S_CLOCK_EN <= '1' after C_START_TIME;
    S_AXI_ARESETN <= '1' after C_START_TIME;

    -- DUT instantiation
    dut: entity work.axi4_lite_slave_if generic map (C_AXI_DATA_WIDTH    => 32,
                                                     C_AXI_ADDRESS_WIDTH => C_AXI_ADDRESS_WIDTH,
                                                     C_NUM_REGISTERS     => C_NUM_REGISTERS)
                                        port map (S_AXI_ACLK    => S_AXI_ACLK,
                                                  S_AXI_ARESETN => S_AXI_ARESETN,
                                                    
                                                  -- Write Address Channel
                                                  S_AXI_AWADDR  => S_AXI_AWADDR,
                                                  S_AXI_AWPROT  => S_AXI_AWPROT,
                                                  S_AXI_AWVALID => S_AXI_AWVALID,
                                                  S_AXI_AWREADY => S_AXI_AWREADY,
                                                    
                                                  -- Write Data Channel
                                                  S_AXI_WVALID  => S_AXI_WVALID,
                                                  S_AXI_WREADY  => S_AXI_WREADY,
                                                    
                                                  -- Write Response Channel
                                                  S_AXI_BRESP   => S_AXI_BRESP,
                                                  S_AXI_BVALID  => S_AXI_BVALID,
                                                  S_AXI_BREADY  => S_AXI_BREADY,
                                                    
                                                  -- Read Address Channel
                                                  S_AXI_ARADDR  => S_AXI_ARADDR,
                                                  S_AXI_ARPROT  => S_AXI_ARPROT,
                                                  S_AXI_ARVALID => S_AXI_ARVALID,
                                                  S_AXI_ARREADY => S_AXI_ARREADY,
                                                    
                                                  -- Read Data Channel
                                                  S_AXI_RRESP   => S_AXI_RRESP,
                                                  S_AXI_RVALID  => S_AXI_RVALID,
                                                  S_AXI_RREADY  => S_AXI_RREADY,
                                                    
                                                  -- Register Interface
                                                  REGISTER_WR => REGISTER_WR,
                                                  REGISTER_RD => REGISTER_RD);

    -- Stimulus process to write to address 0x00000000 four times
    stimulus_proc: process
        
        -- Procedure to perform a single AXI4-Lite write transaction
        procedure axi_write(constant addr : in std_logic_vector(C_AXI_ADDRESS_WIDTH - 1 downto 0);
                            constant write_num : in integer) is
        begin
            report "Starting AXI Write #" & integer'image(write_num) & " to address 0x" & 
                   to_hstring(to_bitvector(addr));
            
            -- Wait for clock and reset to be ready
            wait until rising_edge(S_AXI_ACLK) and S_AXI_ARESETN = '1';
            
            -- Phase 1: Address Write Phase
            -- Assert address and address valid
            S_AXI_AWADDR <= addr;
            S_AXI_AWVALID <= '1';
            S_AXI_BREADY <= '1';  -- Ready to accept response
            
            -- Also assert write data valid (can be done simultaneously or after address)
            S_AXI_WVALID <= '1';
            
            -- Wait for address handshake (AWREADY)
            wait until rising_edge(S_AXI_ACLK) and S_AXI_AWREADY = '1';
            report "Address handshake completed for write #" & integer'image(write_num);
            
            -- Deassert address valid after handshake
            S_AXI_AWVALID <= '0';
            
            -- Phase 2: Write Data Phase
            -- Wait for data handshake (WREADY) 
            wait until rising_edge(S_AXI_ACLK) and S_AXI_WREADY = '1';
            report "Data handshake completed for write #" & integer'image(write_num);
            
            -- Deassert write valid after handshake
            S_AXI_WVALID <= '0';
            
            -- Phase 3: Write Response Phase
            -- Wait for write response (BVALID)
            wait until rising_edge(S_AXI_ACLK) and S_AXI_BVALID = '1';
            report "Write response received for write #" & integer'image(write_num) & 
                   " - Response: " & to_hstring(to_bitvector(S_AXI_BRESP));
            
            -- Deassert response ready to complete transaction
            S_AXI_BREADY <= '0';
            
            -- Wait a few cycles between transactions
            wait for 3 * (1 sec / C_CLOCK_FREQUENCY);
            
            report "Write transaction #" & integer'image(write_num) & " completed";
            
        end procedure;
        
    begin
        -- Initialize all control signals
        S_AXI_AWADDR <= (others => '0');
        S_AXI_AWVALID <= '0';
        S_AXI_WVALID <= '0';
        S_AXI_BREADY <= '0';
        S_AXI_ARADDR <= (others => '0');
        S_AXI_ARVALID <= '0';
        S_AXI_RREADY <= '0';
        
        -- Wait for reset deassertion and a few clock cycles
        wait until rising_edge(S_AXI_ACLK) and S_AXI_ARESETN = '1';
        wait for 5 * (1 sec / C_CLOCK_FREQUENCY);
        
        report "=== Starting AXI4-Lite Write Test Sequence ===";
        report "Will perform 4 consecutive writes to address 0x00000000";
        
        -- Add 2 microsecond delay before starting the first write
        report "Waiting 2 microseconds before first AXI transaction...";
        wait for 2 us;
        report "2 microsecond delay completed, starting first write";
        
        -- Perform four consecutive writes to address 0x00000000
        for i in 1 to 4 loop
            axi_write(x"0", i);
        end loop;
        
        report "=== All 4 writes to address 0x00000000 completed ===";
        
        -- Additional wait to observe final states
        wait for 10 * (1 sec / C_CLOCK_FREQUENCY);
        
        -- Stop the simulation
        report "Simulation completed successfully" severity note;
        wait;
        
    end process;

    -- Monitor process to observe register write signals
    monitor_proc: process
    begin
        wait until rising_edge(S_AXI_ACLK);
        if S_AXI_ARESETN = '1' then
            -- Monitor register write strobes
            if REGISTER_WR /= "00" then
                for i in REGISTER_WR'range loop
                    if REGISTER_WR(i) = '1' then
                        report ">>> REGISTER_WR(" & integer'image(i) & ") asserted at time " & time'image(now);
                    end if;
                end loop;
            end if;
        end if;
    end process;
end behaviour;