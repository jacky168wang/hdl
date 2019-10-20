// ***************************************************************************
// ***************************************************************************
// Copyright 2011(c) Analog Devices, Inc.
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//     - Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     - Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimer in
//       the documentation and/or other materials provided with the
//       distribution.
//     - Neither the name of Analog Devices, Inc. nor the names of its
//       contributors may be used to endorse or promote products derived
//       from this software without specific prior written permission.
//     - The use of this software may or may not infringe the patent rights
//       of one or more patent holders.  This license does not release you
//       from the requirement that you obtain separate licenses from these
//       patent holders to use this software.
//     - Use of the software either in source or binary form, must be run
//       on or directly connected to an Analog Devices Inc. component.
//
// THIS SOFTWARE IS PROVIDED BY ANALOG DEVICES "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
// INCLUDING, BUT NOT LIMITED TO, NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A
// PARTICULAR PURPOSE ARE DISCLAIMED.
//
// IN NO EVENT SHALL ANALOG DEVICES BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, INTELLECTUAL PROPERTY
// RIGHTS, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
// THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// ***************************************************************************
// ***************************************************************************
// ***************************************************************************
// ***************************************************************************

`timescale 1ps/1ps

module ad_mul (

  // data_p = data_a * data_b;

  clk,
  data_a,
  data_b,
  data_p,

  // delay interface

  ddata_in,
  ddata_out);

  // delayed data bus width

  parameter   DELAY_DATA_WIDTH = 16;

  // data_p = data_a * data_b;

  input                               clk;
  input   [16:0]                      data_a;
  input   [16:0]                      data_b;
  output  [33:0]                      data_p;

  // delay interface

  input   [(DELAY_DATA_WIDTH-1):0]    ddata_in;
  output  [(DELAY_DATA_WIDTH-1):0]    ddata_out;

  // internal registers

  reg     [(DELAY_DATA_WIDTH-1):0]    p1_ddata = 'd0;
  reg     [(DELAY_DATA_WIDTH-1):0]    p2_ddata = 'd0;
  reg     [(DELAY_DATA_WIDTH-1):0]    ddata_out = 'd0;

  // a/b reg, m-reg, p-reg delay match

  always @(posedge clk) begin
    p1_ddata <= ddata_in;
    p2_ddata <= p1_ddata;
    ddata_out <= p2_ddata;
  end

  lpm_mult #(
    .lpm_type ("lpm_mult"),
    .lpm_widtha (17),
    .lpm_widthb (17),
    .lpm_widthp (34),
    .lpm_representation ("SIGNED"),
    .lpm_pipeline (3))
  i_lpm_mult (
    .clken (1'b1),
    .aclr (1'b0),
    .sum (1'b0),
    .clock (clk),
    .dataa (data_a),
    .datab (data_b),
    .result (data_p));

endmodule

// ***************************************************************************
// ***************************************************************************
