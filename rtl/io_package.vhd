-------------------------------------------------------------------------------
----                                                                       ----
---- WISHBONE XXX IP Core                                                  ----
----                                                                       ----
---- This file is part of the XXX project						           ----
---- http://www.opencores.org/cores/xxx/			        	           ----
----                                                                       ----
---- Description                                                           ----
---- Implementation of XXX IP core according to                            ----
---- XXX IP core specification document.                                   ----
----                                                                       ----
---- To Do:                                                                ----
----	NA                                                                 ----
----                                                                       ----
---- Author(s):                                                            ----
----   Andrew Mulcock, amulcock@opencores.org                              ----
----                                                                       ----
-------------------------------------------------------------------------------
----                                                                       ----
---- Copyright (C) 2008 Authors and OPENCORES.ORG                          ----
----                                                                       ----
---- This source file may be used and distributed without                  ----
---- restriction provided that this copyright statement is not             ----
---- removed from the file and that any derivative work contains           ----
---- the original copyright notice and the associated disclaimer.          ----
----                                                                       ----
---- This source file is free software; you can redistribute it            ----
---- and/or modify it under the terms of the GNU Lesser General            ----
---- Public License as published by the Free Software Foundation           ----
---- either version 2.1 of the License, or (at your option) any            ----
---- later version.                                                        ----
----                                                                       ----
---- This source is distributed in the hope that it will be                ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied            ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR               ----
---- PURPOSE. See the GNU Lesser General Public License for more           ----
---- details.                                                              ----
----                                                                       ----
---- You should have received a copy of the GNU Lesser General             ----
---- Public License along with this source; if not, download it            ----
---- from http://www.opencores.org/lgpl.shtml                              ----
----                                                                       ----
-------------------------------------------------------------------------------
----                                                                       ----
-- CVS Revision History                                                    ----
----                                                                       ----
-- $Log: not supported by cvs2svn $                                                                   ----
----                                                                       ----


--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 


library IEEE;
use IEEE.STD_LOGIC_1164.all;

-- -------------------------------------------------------------------------
package io_pack is
-- -------------------------------------------------------------------------

constant write32_time_out   : integer := 6;    -- number of clocks to wait 
                                                -- on w32, before an error

constant read32_time_out    : integer := 6;    -- number of clocks to wait 
                                                -- on r32, before an error

constant clk_period         : time := 10 ns;    -- period of simulation clock

type cycle_type is (    unknown,
                        bus_rst,
                        bus_idle,
                        rd32, rd16, rd8, 
                        wr32, wr16, wr8
                    );
  
type bus_cycle is
  record
     c_type     : cycle_type;
     add_o      : std_logic_vector( 31 downto 0);
     dat_o      : std_logic_vector( 31 downto 0);
     dat_i      : std_logic_vector( 31 downto 0);
     we         : std_logic;
     stb        : std_logic;
     cyc        : std_logic;
     ack        : std_logic;
     err        : std_logic;
     rty        : std_logic;
     lock       : std_logic;
     sel        : std_logic_vector( 3 downto 0);
     clk        : std_logic;
  end record;



-- define the wishbone bus signal to share 
--  with main procedure
-- Need to define it as the weekest possible ( 'Z' ) 
--  not so that we get a tri state bus, but so that 
--  procedures called can over drive the signal in the test bench.
--  else test bench gets 'U's.
--
signal bus_c    : bus_cycle :=
            (   unknown,
                (others => 'Z'),
                (others => 'Z'),
                (others => 'Z'),
                'Z',
                'Z',
                'Z',
                'Z',
                'Z',
                'Z',
                'Z',
                (others => 'Z'),
                'Z'
            );

-- ----------------------------------------------------------------------
--  clock_wait
-- ----------------------------------------------------------------------
-- usage clock_wait( number of cycles, bus_record ); -- wait n number of clock cycles
procedure clock_wait(
            constant    no_of_clocks  : in    integer;
            signal      bus_c         : inout bus_cycle
                    );


-- ----------------------------------------------------------------------
--  wb_init
-- ----------------------------------------------------------------------
-- usage wb_init( bus_record ); -- Initalises the wishbone bus
procedure wb_init( 
            signal   bus_c          : inout bus_cycle
                );           


-- ----------------------------------------------------------------------
--  wb_rst
-- ----------------------------------------------------------------------
-- usage wb_rst( 10, RST_sys, bus_record ); -- reset system for 10 clocks
procedure wb_rst ( 
            constant no_of_clocks   : in integer;
            signal   reset          : out std_logic;
            signal   bus_c          : inout bus_cycle
                );           



-- ----------------------------------------------------------------------
--  wr_32
-- ----------------------------------------------------------------------
-- usage wr_32 ( address, data , bus_record )-- write 32 bit data to a 32 bit address
procedure wr_32 ( 
            constant address_data   : in std_logic_vector( 31 downto 0);
            constant write_data     : in std_logic_vector( 31 downto 0);
            signal   bus_c          : inout bus_cycle
                );           

-- ----------------------------------------------------------------------
--  rd_32
-- ----------------------------------------------------------------------
-- usage rd_32 ( address, data , bus_record )-- read 32 bit data from a 32 bit address
procedure rd_32 ( 
            constant address_data   : in std_logic_vector( 31 downto 0);
            signal   read_data      : out std_logic_vector( 31 downto 0);
            signal   bus_c          : inout bus_cycle
                );           


-- -------------------------------------------------------------------------
end io_pack;
-- -------------------------------------------------------------------------





-- -------------------------------------------------------------------------
-- -------------------------------------------------------------------------
-- -------------------------------------------------------------------------
package body io_pack is
-- -------------------------------------------------------------------------


-- ----------------------------------------------------------------------
--  clock_wait
-- ----------------------------------------------------------------------
-- usage clock_wait( number of cycles, bus_record ); -- wait n number of clock cycles
procedure clock_wait(
            constant    no_of_clocks  : in    integer;
            signal      bus_c         : inout bus_cycle
                    ) is
begin
                    
    for n in 1 to no_of_clocks loop
        wait until rising_edge( bus_c.clk );
    end loop;

end procedure clock_wait;



-- --------------------------------------------------------------------
-- usage wb_init( bus_record ); -- Initalises the wishbone bus
procedure wb_init(
            signal   bus_c          : inout bus_cycle
                ) is           
begin

     bus_c.c_type <= bus_idle;
     bus_c.add_o <= ( others => '0');
     bus_c.dat_o <= ( others => '0');
     bus_c.we   <= '0';
     bus_c.stb  <= '0';
     bus_c.cyc  <= '0';
     bus_c.lock <= '0';

     wait until rising_edge( bus_c.clk );   -- allign to next clock
     
end procedure wb_init;


-- --------------------------------------------------------------------
-- usage wb_rst( 10, RST_sys, bus_record ); -- reset system for 10 clocks
procedure wb_rst ( 
            constant no_of_clocks   : in integer;
            signal   reset          : out std_logic;
            signal   bus_c          : inout bus_cycle
                ) is
begin
     bus_c.c_type <= bus_rst;
     bus_c.stb  <= '0';
     bus_c.cyc  <= '0';

     reset <= '1';
        for n in 1 to no_of_clocks loop 
            wait until falling_edge( bus_c.clk );
        end loop;
     reset <= '0';
            wait until rising_edge( bus_c.clk);
end procedure wb_rst;

-- --------------------------------------------------------------------
procedure wr_32 ( 
            constant address_data  : in std_logic_vector( 31 downto 0);
            constant write_data    : in std_logic_vector( 31 downto 0);
            signal   bus_c         : inout bus_cycle
                ) is

variable  bus_write_timer : integer;

begin

    bus_c.c_type    <= wr32;
    bus_c.add_o     <= address_data;
    bus_c.dat_o     <= write_data;    
    bus_c.we        <= '1';                 -- write cycle
    bus_c.sel       <= ( others => '1');    -- on all four banks
    bus_c.cyc       <= '1';
    bus_c.stb       <= '1';
    
    bus_write_timer := 0;
    
    wait until rising_edge( bus_c.clk );
    
    while bus_c.ack = '0' loop
        bus_write_timer := bus_write_timer + 1;
        wait until rising_edge( bus_c.clk );
        
        exit when bus_write_timer >= write32_time_out;
        
    end loop;

    bus_c.c_type    <= bus_idle;
    bus_c.add_o     <= ( others => '0');
    bus_c.dat_o     <= ( others => '0');    
    bus_c.we        <= '0';
    bus_c.sel       <= ( others => '0');
    bus_c.cyc       <= '0';
    bus_c.stb       <= '0';

    
    
end procedure wr_32;



-- ----------------------------------------------------------------------
--  rd_32
-- ----------------------------------------------------------------------
-- usage rd_32 ( address, data , bus_record )-- read 32 bit data from a 32 bit address
procedure rd_32 ( 
            constant address_data   : in std_logic_vector( 31 downto 0);
            signal   read_data      : out std_logic_vector( 31 downto 0);
            signal   bus_c          : inout bus_cycle
                ) is

variable  bus_read_timer : integer;

begin

    bus_c.c_type    <= rd32;
    bus_c.add_o     <= address_data;
    bus_c.we        <= '0';                 -- read cycle
    bus_c.sel       <= ( others => '1');    -- on all four banks
    bus_c.cyc       <= '1';
    bus_c.stb       <= '1';
    
    bus_read_timer := 0;

    wait until rising_edge( bus_c.clk );
    while bus_c.ack = '0' loop
        bus_read_timer := bus_read_timer + 1;
        wait until rising_edge( bus_c.clk );
        
        exit when bus_read_timer >= read32_time_out;
        
    end loop;

    read_data       <= bus_c.dat_i;
    bus_c.c_type    <= bus_idle;
    bus_c.add_o     <= ( others => '0');
    bus_c.dat_o     <= ( others => '0');    
    bus_c.we        <= '0';
    bus_c.sel       <= ( others => '0');
    bus_c.cyc       <= '0';
    bus_c.stb       <= '0';

end procedure rd_32;
    

-- -------------------------------------------------------------------------
end io_pack;
-- -------------------------------------------------------------------------