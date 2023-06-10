library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.mips_types.all;

ENTITY datapath IS
  PORT ( pc : IN STD_LOGIC_VECTOR ( 31 downto 0 );
          nextPC: OUT STD_LOGIC_VECTOR (31 downto 0));
END datapath;

Architecture path of datapath is 
  
  --signals
  signal gnd                        : STD_LOGIC := '0';
  signal RegDst                     : STD_LOGIC;
  signal Branch                     : STD_LOGIC;
  signal MemRead                    : STD_LOGIC; 
  signal MemtoReg                   : STD_LOGIC;
  signal ALUOp_signal               : STD_LOGIC_VECTOR(1 downto 0);
  signal MemWrite                   : STD_LOGIC;
  signal ALUSrc                     : STD_LOGIC;
  signal RegWrite                   : STD_LOGIC;
  signal Zero                       : STD_LOGIC;
  signal branchcntrol               : STD_LOGIC;
  signal Instruc31_26               : STD_LOGIC_VECTOR(5 downto 0);
  signal Instruc25_21               : STD_LOGIC_VECTOR(5 downto 0);
  signal Instruc20_16               : STD_LOGIC_VECTOR(5 downto 0);
  signal Instruc15_11               : STD_LOGIC_VECTOR(5 downto 0);
  signal Instruc15_0                : STD_LOGIC_VECTOR(15 downto 0);
  signal Instruc5_0                 : STD_LOGIC_VECTOR(5 downto 0);
  signal regdst_mux_sig             : STD_LOGIC_VECTOR(4 downto 0);
  signal WriteData                  : STD_LOGIC_VECTOR(31 downto 0);
  signal next_pc_sig            	   : STD_LOGIC_VECTOR(31 downto 0);
  signal next_branch_sig            : STD_LOGIC_VECTOR(31 downto 0);
  signal signextend_signal          : STD_LOGIC_VECTOR(31 downto 0);
  signal shift_left_signal          : STD_LOGIC_VECTOR(31 downto 0);
  signal ALUCTRL_signal             : std_logic_vector(3 DOWNTO 0);
  signal register_read_data_1       : STD_LOGIC_VECTOR(31 downto 0);
  signal register_read_data_2       : STD_LOGIC_VECTOR(31 downto 0);
  signal ALUSrc_mux_sig             : STD_LOGIC_VECTOR(31 downto 0);
  signal datamem_read_data_signal   : STD_LOGIC_VECTOR(31 downto 0);
  signal ALUResult                  : STD_LOGIC_VECTOR(31 downto 0);
  signal immem_data_sig             : STD_LOGIC_VECTOR(31 downto 0);
  signal carry_sig                  : STD_LOGIC_VECTOR(31 downto 0);
  signal result_sig                 : STD_LOGIC_VECTOR(15 downto 0);
  

  

  
  --components
 COMPONENT alu_control
        port( INSTR: in std_logic_vector(5 DOWNTO 0);
              ALUOP: in std_logic_vector(1 DOWNTO 0);
              ALUCTRL : OUT std_logic_vector(3 DOWNTO 0));
 END COMPONENT;
 
 COMPONENT control
        port( INSTR: in std_logic_vector(5 DOWNTO 0);
              REGDST: OUT std_logic;
              BRANCH: OUT std_logic;
              MEMREAD: OUT std_logic;
              MEMTOREG: OUT std_logic;
              ALUOP: OUT std_logic_vector(1 DOWNTO 0);
              MEMWRITE: OUT std_logic;
              ALUSRC: OUT std_logic;
              REGWRITE: OUT std_logic);
 END COMPONENT;
 
 COMPONENT dmemory
        port(
              DIN: in mips_data;
              ADDR: in mips_address;
              DOUT: out mips_data;
              WE, RE: in std_logic;
              CLK: in std_logic);
 END COMPONENT;
 
 COMPONENT imemory
        port(ADDR: in mips_address;
              DOUT: out mips_data);
 END COMPONENT;
 
 COMPONENT signextend
   port( INDATA: in STD_LOGIC_VECTOR(15 DOWNTO 0);
      OUTDATA: out mips_data);
 end COMPONENT;

 COMPONENT ALU32
 PORT( A, B: in std_logic_vector (31 downto 0);
       ALUOp: in std_logic_vector (3 downto 0);
       RESULT: out std_logic_vector (31 downto 0);
       Z, V, C: out std_logic );
 END COMPONENT ALU32;
 
 COMPONENT shiftleft
   port( INDATA: in mips_data;
      OUTDATA: out mips_data);
 END COMPONENT;
 
 COMPONENT reg_file
  port (a1 : in mips_reg_addr;
        q1 : out mips_data;
        a2 : in mips_reg_addr;
        q2 : out mips_data;
        a3 : in mips_reg_addr;
        d3 : in mips_data;
        write_en : in std_logic;
        clk : in std_logic);
 END COMPONENT;
 
 COMPONENT mux2
   port( IN0: in mips_data;
      IN1: in mips_data;
      SEL: in std_logic;
      DOUT: out mips_data);
 END COMPONENT;
    
  COMPONENT mux2a
   port( IN0: in mips_reg_addr;
      IN1: in mips_reg_addr;
      SEL: in STD_LOGIC;
      DOUT: out mips_reg_addr);
  END COMPONENT;
    
    

  
  SIGNAL sys_clock : std_logic := '0';
  CONSTANT Tcycle : time := 100 ns;

  BEGIN
 -- create clock process
 clk_gen: process
 begin
 sys_clock <= '1' after Tcycle/3, '0' after Tcycle;
 wait until sys_clock = '0';
 end process clk_gen;
  
  
  instructmem:    imemory    port map(ADDR => pc, DOUT => immem_data_sig);
  signextend0: signextend   port map(INDATA => immem_data_sig(15 downto 0) , OUTDATA => signextend_signal); -- check
  dmemory0: dmemory         port map(DIN => register_read_data_2 , ADDR => ALUResult , DOUT => datamem_read_data_signal, WE => MemWrite, RE => MemRead , CLK => sys_clock); -- check
  alu0: alu32               port map(A => register_read_data_1, B => ALUSrc_mux_sig, ALUOp => ALUCTRL_signal, Result => ALUResult, Z => Zero); -- check
  pcalu1: alu32             port map(A => pc, B => "00000000000000000000000000000100", ALUOp => "0010", Result => next_pc_sig); -- check
  branchalu2: alu32         port map(A => next_pc_sig, B => shift_left_signal, ALUOp => "0010", Result => next_branch_sig); -- check
  pcMuxSel: mux2            port map(IN0 => next_pc_sig, IN1 => next_branch_sig, SEL => branchcntrol, DOUT => nextPC); -- check
  shiftleft0: shiftleft     port map(INDATA => signextend_signal, OUTDATA => shift_left_signal); -- check
  mux2_32: mux2             port map(IN0 => register_read_data_2 , IN1 => signextend_signal , SEL => ALUSrc , DOUT => ALUSrc_mux_sig); -- check
  datamemmux2_32: mux2      port map(IN0 => ALUResult, IN1 => datamem_read_data_signal  , SEL => MemtoReg , DOUT => WriteData);  -- check
  mux2a_5: mux2a            port map(IN0 => immem_data_sig(20 downto 16), IN1 => immem_data_sig(15 downto 11), SEL => RegDst, DOUT => regdst_mux_sig); -- MAYBE ERROR
  reg_file0: reg_file       port map(a1 => immem_data_sig(25 downto 21), q1 => register_read_data_1, a2 => immem_data_sig(20 downto 16), q2 => register_read_data_2, a3 => regdst_mux_sig, d3 => WriteData , write_en => RegWrite, clk => sys_clock); -- MAYBE ERROR
  control0: control         port map(INSTR => immem_data_sig(31 downto 26), REGDST => RegDst , BRANCH => Branch , MEMREAD => MemRead , MEMTOREG => MemtoReg, ALUOP => ALUOp_signal, MEMWRITE => MemWrite , ALUSRC => ALUSrc , REGWRITE => RegWrite);
  alu_con0: alu_control     port map(INSTR => immem_data_sig(5 downto 0), ALUOP => ALUOp_signal,ALUCTRL => ALUCTRL_signal);  

  branchcntrol <= Zero and Branch; 

   
end path;