lis r4,0
ori r4,r4,6
lwz r5,0(r4)
cmpwi cr7,r5,1
blt- cr7,0x000C
beq- cr7,0x000C
bgt- cr7,0x000C
v_zero:
b 0x0148
v_one:
b 0x0144

v_two:
lis r7,-32699
ori r7,r7,48936
lis r5,-1
ori r5,r5,65535
stw r5,0(r7)
stw r5,4(r7)
nop 
lis r4,-32734
ori r4,r4,54840
lis r5,14336
ori r5,r5,6
stw r5,0(r4)
nop 
lis r4,-32734
ori r4,r4,50756
lis r5,14336
ori r5,r5,44
stw r5,0(r4)
nop 
lis r4,-32705
ori r4,r4,41560
lis r5,0
ori r5,r5,1
stw r5,0(r4)
nop 
lis r4,-32746
ori r4,r4,46208
lis r5,24576
ori r5,r5,0
stw r5,0(r4)
nop 
lis r4,-32746
ori r4,r4,43748
lis r5,24576
ori r5,r5,0
stw r5,0(r4)
nop 
lis r4,-32707
ori r4,r4,19016
lis r5,52
ori r5,r5,258
stw r5,0(r4)
nop 
lis r4,-32707
ori r4,r4,19020
lis r5,1024
ori r5,r5,2560
stw r5,0(r4)
nop 
lis r4,-32707
ori r4,r4,19024
lis r5,2049
ori r5,r5,256
stw r5,0(r4)
nop 
lis r4,-32707
ori r4,r4,19040
lis r5,-256
ori r5,r5,0
stw r5,0(r4)
nop 
lis r4,-32707
ori r4,r4,19056
lis r5,0
ori r5,r5,0
stw r5,0(r4)
nop 
lis r4,-32707
ori r4,r4,19060
lis r5,15360
ori r5,r5,0
stw r5,0(r4)
nop 
lis r4,-32707
ori r4,r4,19064
lis r5,-6400
ori r5,r5,176
stw r5,0(r4)
nop 
b 0x0004

end_code:
lis r23,-32733
ori r23,r23,40604
mtlr r23
blr 
