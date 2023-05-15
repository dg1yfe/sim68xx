### Altair 680 BASIC procedures

See https://gitlab.com/retroabandon/altair-680-basic.git for the original dumps. It contains a PROM of the Altair 680 monitor, and what I think was originally a tape of the BASIC interpreter. You would have used monitor commands to load the tape. However, for us it's easier to load BASIC before starting the monitor.

You need the `/MITS_RAW.TXT` and the `/monitor/PROM_S1.TXT` from that repo. Concatenate these to create a file called `basic_6800.s19`. The resulting file contains some comments (non-S1 lines) and a separate EOF record for each of the parts. The 6800 simulator will ignore these and load the contents of both parts.

Run `./sim_6800 basic_6800.s19`. It starts in the simulator's debugger, with the PC having been loaded from the reset vector which is part of the monitor PROM:
```
Couldn't open symbol file
PC=ffd8 A:B=0000 X=0000 SP=0000 CCR=d0(11hInzvc)	[0]
ffd8	8e 00 f3	lds  #00f3

>
```

Type `g <Enter>` to boot. This starts the Altair ROM monitor. Type `J0000` to jump to address 0, which is the starting location of the BASIC tape. It will be echoed back as `J 0000`, and you do not need to press `<Enter>` for the J command.

Then BASIC will ask you some questions. You enter the memory size in bytes, or press `<Enter>` to have it automatically determined. I think the automatic routine will scan memory until it finds the status register of the ACIA at `0xf000` does not read back as written. On normal hardware this would probably corrupt the channel, but on our hardware it works OK. Or type a value like `32768 <Enter>`.

Finally you receive the `OK` prompt and you can use BASIC. It should look like:
```
ffd8: Running...

.J 0000
MEMORY SIZE? 
TERMINAL WIDTH? 80
WANT SIN-COS-TAN-ATN? Y

55002 BYTES FREE

MITS ALTAIR 680 BASIC VERSION 1.1 REV 3.2
COPYRIGHT 1976 BY MITS INC.

OK
```

I have noticed that `<Backspace>` does not work, even though I put a translation from `<Del>` to `<Backspace>` in the simulator's I/O code. Examining the disassembly shows that BASIC does not seem to implement `<Backspace>` but it is doing something with `<Ctrl>G`. The `<Ctrl>G` does nothing for me and this could be investigated.

BASIC checks for `<Ctrl>C` while it is running and I assume it would abort the program, but unfortunately this conflicts with the simulator which also uses `<Ctrl>C` to break out to the simulator's debugger. I have not tried to remap this so I don't know if `<Ctrl>C` works in BASIC. It does drain the input and throw away the characters while running (in order to check `<Ctrl>C`), so you can't type ahead.

I created a test program based on some sample math routines in the Altair BASIC manual. Start the simulator with `./sim6800 basic_6800.s19` and paste this in:
```
g
J0000
80
Y
10 PRINT "HELLO"
20 REM P9=X9^Y9 === GOSUB 60030
30 X9=.3:Y9=.7:GOSUB 60030:PRINT .3^.7,P9
40 REM L9=LOG(X9) === GOSUB 60090
50 X9=.4:GOSUB 60090:PRINT LOG(.4),L9
60 REM E9=EXP(X9) === GOSUB 60160
70 X9=.5:GOSUB 60160:PRINT EXP(.5),E9
80 REM C9=COS(X9) === GOSUB 60240
90 X9=.6:GOSUB 60240:PRINT COS(.6),C9
100 REM T9=TAN(X9) === GOSUB 60280
110 X9=.7:GOSUB 60280:PRINT TAN(.7),T9
120 REM A9=ATN(X9) === GOSUB 60310
130 X9=.8:GOSUB 60310:PRINT ATN(.8),A9
140 END
60000 REM EXPONENTIATION: P9=X9^Y9
60010 REM NEED: EXP, LOG
60020 REM VARIABLES USED: A9,B9,C9,E9,L9,P9,X9,Y9
60030 P9=1 : E9=0 : IF Y9=0 THEN RETURN
60040 IF X9<0 THEN IF INT(Y9)=Y9 THEN P9=1-2*Y9+4*INT(Y9/2) : X9=-X9
60050 IF X9<>0 THEN GOSUB 60090 : X9=Y9*L9 : GOSUB 60160
60060 P9=P9*E9 : RETURN
60070 REM NATURAL LOGARITHM: L9=LOG(X9)
60080 REM VARIABLES USED: A9,B9,C9,E9,L9,X9
60090 E9=0 : IF X9<=0 THEN PRINT "LOG FC ERROR"; : STOP
60095 A9=1 : B9=2 : C9=.5 : REM THIS WILL SPEED UP THE FOLLOWING
60100 IF X9>=A9 THEN X9=C9*X9 : E9=E9+A9 : GOTO 60100
60110 IF X9<C9 THEN X9=B9*X9 : E9=E9-A9 : GOTO 60110
60120 X9=(X9-.707107)/(X9+.707107) : L9=X9*X9
60130 L9=(((.598979*L9+.961471)*L9+2.88539)*X9+E9-.5)*.693147
60135 RETURN
60140 REM EXPONENTIAL: E9=EXP(X9)
60150 REM VARIABLES USED: A9,E9,L9,X9
60160 L9=INT(1.4427*X9)+1 : IF L9<1E7 THEN 60180
60170 IF X9>0 THEN PRINT "EXP OV ERROR"; : STOP
60175 E9=0 : RETURN
60180 E9=.693147*L9-X9 : A9=1.32988E-3-1.41316E-4*E9
60190 A9=((A9*E9-8.30136E-3)*E9+4.16574E-2)*E9
60195 E9=(((A9-.166665)*E9+.5)*E9-1)*E9+1 : A9=2
60197 IF L9<=0 THEN A9=.5 : L9=-L9 : IF L9=0 THEN RETURN
60200 FOR X9=1 TO L9 : E9=A9*E9 : NEXT X9 : RETURN
60210 REM COSINE: C9=COS(X9)
60220 REM N.B. SIN MUST BE RETAINED AT LOAD-TIME
60230 REM VARIABLES USED: C9,X9
60240 C9=SIN(X9+1.5708) : RETURN
60250 REM TANGENT: T9=TAN(X9)
60260 REM NEEDS COS. (SIN NUST BE RETAINED AT LOAD-TIME)
60270 REM VARIABLES USED: C9,T9,X9
60280 GOSUB 60240 : T9=SIN(X9)/C9 : RETURN
60290 REM ARCTANGENT: A9=ATN(X9)
60300 REM VARIABLES USED: A9,B9,C9,T9,X9
60310 T9=SGN(X9): X9=ABS(X9): C9=0 : IF X9>1 THEN C9=1 : X9=1/X9
60320 A9=X9*X9 : B9=((2.86623E-3*A9-1.61657E-2)*A9+4.29096E-2)*A9
60330 B9=((((B9-7.5289E-2)*A9+.106563)*A9-.142089)*A9+.199936)*A9
60340 A9=((B9-.333332)*A9+1)*X9 : IF C9=1 THEN A9=1.5708-A9
60350 A9=T9*A9 : RETURN
RUN
```

The output of this test program (comparing 4K vs 8K math routines) should be:
```
HELLO
 .430512       .430512 
-.916291      -.916291 
 1.64872       1.64872 
 .825336       .825333 
 .842288       .842291 
 .674741       .674741 

OK
```
