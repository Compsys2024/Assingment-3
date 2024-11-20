import chisel3._
import chisel3.util._

class Accelerator extends Module {
  val io = IO(new Bundle {
    val start = Input(Bool())
    val done = Output(Bool())
z
    val address = Output(UInt (16.W))
    val dataRead = Input(UInt (32.W))
    val writeEnable = Output(Bool ())
    val dataWrite = Output(UInt (32.W))

  })

  //Write here your code

  //states
  val idle :: loadState :: process :: write :: Nil = Enum(5)
  val state = RegInit(idle)

  //registers
  val x = RegInit(0.U(5.W)) //20x20 image requires 5 bits size 2^5 in range(1-31)
  val y = RegInit(0.U(5.W))
  val curr_pixel = Reg(Unit(8.W))
  val neighbours = Reg(Vec(4, UInt(8.W)))

  //storage for image pixel and neighbours
  val readAddr = RegInit(0.U(16.W))
  val writeAddr = RegInit(0.U(16.W))

  //default output
  io.done = false.B
  io.address = readAdd
  io.writeEnable = false.B
  io.dataWrite = 0.U

  switch(state){
    is(idle) {
      when(io.start) {
        state = loadState
        x = 0.U
        y = 0.U
        readAddr = 0.U
        writeAddr = 400.U //start at address 400
      }
    }
    is(loadState) {
      readAddr = x + 20.U * y
      curr_pixel = io.dataRead

      when (x > 0.U) {neighbours(0) = io.dataRead}
      when (x < 19.U) {neighbours(1) = io.dataRead}
      when (y > 0.U) {neighbours(2) = io.dataRead}
      when (y < 19.U) {neighbours(3) = io.dataRead}

      state = process
    }
    is(process) {
      val boundary (x === 0.U || y === 0.U || x === 19.U || y === 19.U)
      val erode_pixel Mux(boundary, 0.U, Mux(neighbours.reduce(_ | _) === 0.U, 0.U, 255.U))
      io.dataWrite = erode_pixel

      state = write
    }
    is(write) {
      // Write processed pixel to memory
      io.address := writeAddr
      io.writeEnable := true.B

      writeAddr := writeAddr + 1.U
      x := Mux(x === 19.U, 0.U, x + 1.U)
      y := Mux(x === 19.U, y + 1.U, y)

      when(x === 19.U && y === 19.U) {
        state := done
      }.otherwise {
        state := load
      }

    is(done) {
      io.done = true.B
      state = idle
    }
  }
}
