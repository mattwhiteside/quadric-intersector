/*
This module converts from IEEE encoded floating
point numbers to UC Berkeley internal recoded format.

This file was generated by chisel from this scala module:

https://github.com/ucb-bar/berkeley-hardfloat/blob/master/src/main/scala/floatNToRecodedFloatN.scala

*/




module UCBFloatEncoder(
    input [63:0] io_in,
    output[64:0] io_out
);

  wire[64:0] T0;
  wire[63:0] T1;
  wire[51:0] T2;
  wire[51:0] T3;
  wire[51:0] T4;
  wire[126:0] T5;
  wire[5:0] T6;
  wire[5:0] T31;
  wire[5:0] T32;
  wire[5:0] T33;
  wire[5:0] T34;
  wire[5:0] T35;
  wire[5:0] T36;
  wire[5:0] T37;
  wire[5:0] T38;
  wire[5:0] T39;
  wire[5:0] T40;
  wire[5:0] T41;
  wire[5:0] T42;
  wire[5:0] T43;
  wire[5:0] T44;
  wire[5:0] T45;
  wire[5:0] T46;
  wire[5:0] T47;
  wire[5:0] T48;
  wire[5:0] T49;
  wire[5:0] T50;
  wire[5:0] T51;
  wire[5:0] T52;
  wire[5:0] T53;
  wire[5:0] T54;
  wire[5:0] T55;
  wire[5:0] T56;
  wire[5:0] T57;
  wire[5:0] T58;
  wire[5:0] T59;
  wire[5:0] T60;
  wire[5:0] T61;
  wire[5:0] T62;
  wire[4:0] T63;
  wire[4:0] T64;
  wire[4:0] T65;
  wire[4:0] T66;
  wire[4:0] T67;
  wire[4:0] T68;
  wire[4:0] T69;
  wire[4:0] T70;
  wire[4:0] T71;
  wire[4:0] T72;
  wire[4:0] T73;
  wire[4:0] T74;
  wire[4:0] T75;
  wire[4:0] T76;
  wire[4:0] T77;
  wire[4:0] T78;
  wire[3:0] T79;
  wire[3:0] T80;
  wire[3:0] T81;
  wire[3:0] T82;
  wire[3:0] T83;
  wire[3:0] T84;
  wire[3:0] T85;
  wire[3:0] T86;
  wire[2:0] T87;
  wire[2:0] T88;
  wire[2:0] T89;
  wire[2:0] T90;
  wire[1:0] T91;
  wire[1:0] T92;
  wire T93;
  wire[63:0] T8;
  wire T94;
  wire T95;
  wire T96;
  wire T97;
  wire T98;
  wire T99;
  wire T100;
  wire T101;
  wire T102;
  wire T103;
  wire T104;
  wire T105;
  wire T106;
  wire T107;
  wire T108;
  wire T109;
  wire T110;
  wire T111;
  wire T112;
  wire T113;
  wire T114;
  wire T115;
  wire T116;
  wire T117;
  wire T118;
  wire T119;
  wire T120;
  wire T121;
  wire T122;
  wire T123;
  wire T124;
  wire T125;
  wire T126;
  wire T127;
  wire T128;
  wire T129;
  wire T130;
  wire T131;
  wire T132;
  wire T133;
  wire T134;
  wire T135;
  wire T136;
  wire T137;
  wire T138;
  wire T139;
  wire T140;
  wire T141;
  wire T142;
  wire T143;
  wire T144;
  wire T145;
  wire T146;
  wire T147;
  wire T148;
  wire T149;
  wire T150;
  wire T151;
  wire T152;
  wire T153;
  wire T154;
  wire T155;
  wire[63:0] T9;
  wire T10;
  wire[10:0] T11;
  wire[11:0] T12;
  wire[11:0] T156;
  wire[9:0] T13;
  wire T14;
  wire T15;
  wire T16;
  wire T17;
  wire[1:0] T18;
  wire[11:0] T19;
  wire[11:0] T157;
  wire[10:0] T20;
  wire[10:0] T21;
  wire[10:0] T158;
  wire[1:0] T22;
  wire T23;
  wire T24;
  wire T25;
  wire[11:0] T26;
  wire[11:0] T159;
  wire[11:0] T27;
  wire[11:0] T28;
  wire[5:0] T29;
  wire T30;


  assign io_out = T0;
  assign T0 = {T30, T1};
  assign T1 = {T12, T2};
  assign T2 = T10 ? T4 : T3;
  assign T3 = io_in[6'h33:1'h0];
  assign T4 = T5[6'h3e:4'hb];
  assign T5 = T9 << T6;
  assign T6 = ~ T31;
  assign T31 = T155 ? 6'h3f : T32;
  assign T32 = T154 ? 6'h3e : T33;
  assign T33 = T153 ? 6'h3d : T34;
  assign T34 = T152 ? 6'h3c : T35;
  assign T35 = T151 ? 6'h3b : T36;
  assign T36 = T150 ? 6'h3a : T37;
  assign T37 = T149 ? 6'h39 : T38;
  assign T38 = T148 ? 6'h38 : T39;
  assign T39 = T147 ? 6'h37 : T40;
  assign T40 = T146 ? 6'h36 : T41;
  assign T41 = T145 ? 6'h35 : T42;
  assign T42 = T144 ? 6'h34 : T43;
  assign T43 = T143 ? 6'h33 : T44;
  assign T44 = T142 ? 6'h32 : T45;
  assign T45 = T141 ? 6'h31 : T46;
  assign T46 = T140 ? 6'h30 : T47;
  assign T47 = T139 ? 6'h2f : T48;
  assign T48 = T138 ? 6'h2e : T49;
  assign T49 = T137 ? 6'h2d : T50;
  assign T50 = T136 ? 6'h2c : T51;
  assign T51 = T135 ? 6'h2b : T52;
  assign T52 = T134 ? 6'h2a : T53;
  assign T53 = T133 ? 6'h29 : T54;
  assign T54 = T132 ? 6'h28 : T55;
  assign T55 = T131 ? 6'h27 : T56;
  assign T56 = T130 ? 6'h26 : T57;
  assign T57 = T129 ? 6'h25 : T58;
  assign T58 = T128 ? 6'h24 : T59;
  assign T59 = T127 ? 6'h23 : T60;
  assign T60 = T126 ? 6'h22 : T61;
  assign T61 = T125 ? 6'h21 : T62;
  assign T62 = T124 ? 6'h20 : T63;
  assign T63 = T123 ? 5'h1f : T64;
  assign T64 = T122 ? 5'h1e : T65;
  assign T65 = T121 ? 5'h1d : T66;
  assign T66 = T120 ? 5'h1c : T67;
  assign T67 = T119 ? 5'h1b : T68;
  assign T68 = T118 ? 5'h1a : T69;
  assign T69 = T117 ? 5'h19 : T70;
  assign T70 = T116 ? 5'h18 : T71;
  assign T71 = T115 ? 5'h17 : T72;
  assign T72 = T114 ? 5'h16 : T73;
  assign T73 = T113 ? 5'h15 : T74;
  assign T74 = T112 ? 5'h14 : T75;
  assign T75 = T111 ? 5'h13 : T76;
  assign T76 = T110 ? 5'h12 : T77;
  assign T77 = T109 ? 5'h11 : T78;
  assign T78 = T108 ? 5'h10 : T79;
  assign T79 = T107 ? 4'hf : T80;
  assign T80 = T106 ? 4'he : T81;
  assign T81 = T105 ? 4'hd : T82;
  assign T82 = T104 ? 4'hc : T83;
  assign T83 = T103 ? 4'hb : T84;
  assign T84 = T102 ? 4'ha : T85;
  assign T85 = T101 ? 4'h9 : T86;
  assign T86 = T100 ? 4'h8 : T87;
  assign T87 = T99 ? 3'h7 : T88;
  assign T88 = T98 ? 3'h6 : T89;
  assign T89 = T97 ? 3'h5 : T90;
  assign T90 = T96 ? 3'h4 : T91;
  assign T91 = T95 ? 2'h3 : T92;
  assign T92 = T94 ? 2'h2 : T93;
  assign T93 = T8[1'h1:1'h1];
  assign T8 = T9[6'h3f:1'h0];
  assign T94 = T8[2'h2:2'h2];
  assign T95 = T8[2'h3:2'h3];
  assign T96 = T8[3'h4:3'h4];
  assign T97 = T8[3'h5:3'h5];
  assign T98 = T8[3'h6:3'h6];
  assign T99 = T8[3'h7:3'h7];
  assign T100 = T8[4'h8:4'h8];
  assign T101 = T8[4'h9:4'h9];
  assign T102 = T8[4'ha:4'ha];
  assign T103 = T8[4'hb:4'hb];
  assign T104 = T8[4'hc:4'hc];
  assign T105 = T8[4'hd:4'hd];
  assign T106 = T8[4'he:4'he];
  assign T107 = T8[4'hf:4'hf];
  assign T108 = T8[5'h10:5'h10];
  assign T109 = T8[5'h11:5'h11];
  assign T110 = T8[5'h12:5'h12];
  assign T111 = T8[5'h13:5'h13];
  assign T112 = T8[5'h14:5'h14];
  assign T113 = T8[5'h15:5'h15];
  assign T114 = T8[5'h16:5'h16];
  assign T115 = T8[5'h17:5'h17];
  assign T116 = T8[5'h18:5'h18];
  assign T117 = T8[5'h19:5'h19];
  assign T118 = T8[5'h1a:5'h1a];
  assign T119 = T8[5'h1b:5'h1b];
  assign T120 = T8[5'h1c:5'h1c];
  assign T121 = T8[5'h1d:5'h1d];
  assign T122 = T8[5'h1e:5'h1e];
  assign T123 = T8[5'h1f:5'h1f];
  assign T124 = T8[6'h20:6'h20];
  assign T125 = T8[6'h21:6'h21];
  assign T126 = T8[6'h22:6'h22];
  assign T127 = T8[6'h23:6'h23];
  assign T128 = T8[6'h24:6'h24];
  assign T129 = T8[6'h25:6'h25];
  assign T130 = T8[6'h26:6'h26];
  assign T131 = T8[6'h27:6'h27];
  assign T132 = T8[6'h28:6'h28];
  assign T133 = T8[6'h29:6'h29];
  assign T134 = T8[6'h2a:6'h2a];
  assign T135 = T8[6'h2b:6'h2b];
  assign T136 = T8[6'h2c:6'h2c];
  assign T137 = T8[6'h2d:6'h2d];
  assign T138 = T8[6'h2e:6'h2e];
  assign T139 = T8[6'h2f:6'h2f];
  assign T140 = T8[6'h30:6'h30];
  assign T141 = T8[6'h31:6'h31];
  assign T142 = T8[6'h32:6'h32];
  assign T143 = T8[6'h33:6'h33];
  assign T144 = T8[6'h34:6'h34];
  assign T145 = T8[6'h35:6'h35];
  assign T146 = T8[6'h36:6'h36];
  assign T147 = T8[6'h37:6'h37];
  assign T148 = T8[6'h38:6'h38];
  assign T149 = T8[6'h39:6'h39];
  assign T150 = T8[6'h3a:6'h3a];
  assign T151 = T8[6'h3b:6'h3b];
  assign T152 = T8[6'h3c:6'h3c];
  assign T153 = T8[6'h3d:6'h3d];
  assign T154 = T8[6'h3e:6'h3e];
  assign T155 = T8[6'h3f:6'h3f];
  assign T9 = T3 << 4'hc;
  assign T10 = T11 == 11'h0;
  assign T11 = io_in[6'h3e:6'h34];
  assign T12 = T19 | T156;
  assign T156 = {2'h0, T13};
  assign T13 = T14 << 4'h9;
  assign T14 = T17 & T15;
  assign T15 = T16 ^ 1'h1;
  assign T16 = T3 == 52'h0;
  assign T17 = T18 == 2'h3;
  assign T18 = T19[4'hb:4'ha];
  assign T19 = T26 + T157;
  assign T157 = {1'h0, T20};
  assign T20 = T25 ? 11'h0 : T21;
  assign T21 = 11'h400 | T158;
  assign T158 = {9'h0, T22};
  assign T22 = T23 ? 2'h2 : 2'h1;
  assign T23 = T10 & T24;
  assign T24 = T16 ^ 1'h1;
  assign T25 = T10 & T16;
  assign T26 = T10 ? T27 : T159;
  assign T159 = {1'h0, T11};
  assign T27 = T16 ? 12'h0 : T28;
  assign T28 = {6'h3f, T29};
  assign T29 = ~ T6;
  assign T30 = io_in[6'h3f:6'h3f];
endmodule

