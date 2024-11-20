;buildInfoPackage: chisel3, version: 3.3.2, scalaVersion: 2.12.11, sbtVersion: 1.3.10
circuit SystemTop : 
  module DataMemory : 
    input clock : Clock
    input reset : Reset
    output io : {flip address : UInt<16>, dataRead : UInt<32>, flip writeEnable : UInt<1>, flip dataWrite : UInt<32>, flip testerEnable : UInt<1>, flip testerAddress : UInt<16>, testerDataRead : UInt<32>, flip testerWriteEnable : UInt<1>, flip testerDataWrite : UInt<32>}
    
    cmem memory : UInt<32>[65536] @[DataMemory.scala 18:20]
    when io.testerEnable : @[DataMemory.scala 22:24]
      read mport _T = memory[io.testerAddress], clock @[DataMemory.scala 24:37]
      io.testerDataRead <= _T @[DataMemory.scala 24:23]
      io.dataRead <= UInt<32>("h00") @[DataMemory.scala 26:17]
      when io.testerWriteEnable : @[DataMemory.scala 27:32]
        write mport _T_1 = memory[io.testerAddress], clock
        _T_1 <= io.testerDataWrite
        io.testerDataRead <= io.testerDataWrite @[DataMemory.scala 30:25]
        skip @[DataMemory.scala 27:32]
      skip @[DataMemory.scala 22:24]
    else : @[DataMemory.scala 32:16]
      read mport _T_2 = memory[io.address], clock @[DataMemory.scala 34:31]
      io.dataRead <= _T_2 @[DataMemory.scala 34:17]
      io.testerDataRead <= UInt<32>("h00") @[DataMemory.scala 36:23]
      when io.writeEnable : @[DataMemory.scala 37:26]
        write mport _T_3 = memory[io.address], clock
        _T_3 <= io.dataWrite
        io.dataRead <= io.dataWrite @[DataMemory.scala 40:19]
        skip @[DataMemory.scala 37:26]
      skip @[DataMemory.scala 32:16]
    
  module Accelerator : 
    input clock : Clock
    input reset : Reset
    output io : {flip start : UInt<1>, done : UInt<1>, address : UInt<16>, flip dataRead : UInt<32>, writeEnable : UInt<1>, dataWrite : UInt<32>}
    
    
  module SystemTop : 
    input clock : Clock
    input reset : UInt<1>
    output io : {done : UInt<1>, flip start : UInt<1>, flip testerDataMemEnable : UInt<1>, flip testerDataMemAddress : UInt<16>, testerDataMemDataRead : UInt<32>, flip testerDataMemWriteEnable : UInt<1>, flip testerDataMemDataWrite : UInt<32>}
    
    inst dataMemory of DataMemory @[SystemTop.scala 18:26]
    dataMemory.clock <= clock
    dataMemory.reset <= reset
    inst accelerator of Accelerator @[SystemTop.scala 19:27]
    accelerator.clock <= clock
    accelerator.reset <= reset
    io.done <= accelerator.io.done @[SystemTop.scala 23:11]
    accelerator.io.start <= io.start @[SystemTop.scala 24:24]
    accelerator.io.dataRead <= dataMemory.io.dataRead @[SystemTop.scala 27:27]
    dataMemory.io.address <= accelerator.io.address @[SystemTop.scala 28:25]
    dataMemory.io.dataWrite <= accelerator.io.dataWrite @[SystemTop.scala 29:27]
    dataMemory.io.writeEnable <= accelerator.io.writeEnable @[SystemTop.scala 30:29]
    dataMemory.io.testerAddress <= io.testerDataMemAddress @[SystemTop.scala 33:31]
    io.testerDataMemDataRead <= dataMemory.io.testerDataRead @[SystemTop.scala 34:28]
    dataMemory.io.testerDataWrite <= io.testerDataMemDataWrite @[SystemTop.scala 35:33]
    dataMemory.io.testerEnable <= io.testerDataMemEnable @[SystemTop.scala 36:30]
    dataMemory.io.testerWriteEnable <= io.testerDataMemWriteEnable @[SystemTop.scala 37:35]
    
