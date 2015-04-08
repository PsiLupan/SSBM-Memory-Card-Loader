#*********************************************
#**    wParam's SSBM assembler file        ***
#**                                        *********************************
#**  Not guaranteed to contain anything useful, or even to make sense    ***
#**  at all.  Read or use this file at your own risk.  If you can do     ***
#**  something cool based on this information, great, go for it, just    ***
#**  give me a little credit.  This is the file that contains all of     ***
#**  the code bits used by the mod.  I believe that everything is in     ***
#**  here, although a large part of it is inside the "EVERYTHING_ELSE"   ***
#**  block at the end.  When I went to work on the dpad moves section,   ***
#**  I had had enough of calculating branch instructions by hand, so I   ***
#**  did the work to switch from whatever crappy assembler I was using   ***
#**  to the gnu assembler that came with the gamecube dev kit thing.     ***
#**  So now, I can just enable a section and run assem.bat and have a    ***
#**  nice poke script generated for me.  It is sweet, much better than   ***
#**  the crap I had to go through before.                                ***
#**                                                                      ***
#**  Note: this file contains some profanity.                            ***
#***************************************************************************


.org 0x0000
StartOfMemory:
SOM:

.set ZERO, 0x7313

.set ITEM_DURATION_FUNCS, 0
.set DPAD_CPUSET, 0
.set DPAD_TESTBED, 0
.set DPAD_MOVES_BLOCK, 0
.set EVERYTHING_ELSE, 0
.set CLONE_WARS, 0
.set CLONE_WARS_2, 0
.set CLONE_WARS_3, 0
.set BUFFER_EXPLOIT, 0
.set MULTI_CRAZY_SIZE, 0
.set EXPLOIT_DOL_LOAD, 0
.set CHARACTER_MOVE_SWAP, 0
.set ONE_HIT_KILL_NOCRASH, 0
.set ONE_HIT_KILL_NOCRASH_2, 0
.set ONE_HIT_KILL_TWO, 0
.set FUN_WITH_PHYS, 0
.set MUSH_STACK_TOGGLE, 0
.set INF_JUMP_TOGGLE, 0
.set MUSH_DEADLY, 0
.set INVISIBLE_ITEMS, 0
.set INVISIBLE_PLAYERS, 0
.set NEW_ITEMS_WOOT, 0
.set POW_BLOCK_AR, 0
.set DPAD_DOWN_MOVES, 0
.set ITEMS_DONT_DISAPPEAR, 0
.set FIXED_CAMERA_TOGGLE, 0
.set CAMERA_KILL_TEST, 0
.set DUMMY_CAMERA, 0
.set CRASH_WATCH_1, 0
.set EVENT_STAGES, 0
.set DEBUG_MENU_DPAD, 0
.set NEW_ENUM_TEXT, 0
.set PROPER_SAVE_LOAD, 0
.set PROPER_SAVE_LOAD_ADDRESS, 0
.set RANDOM_STAGE_SELECT, 0
.set GRAPHICAL_CHAR_SELECT, 0
.set TRUE_INFINITE_JUMPS, 0
.set STUCK_TO_FLOOR, 0
.set ITEM_TRADE_TEST, 0
.set ITEM_STEAL_ON_GRAB, 0
.set ITEM_STEAL_ON_GRAB_AR, 0
.set HOT_SATURN, 0
.set FANCY_THROW, 0
.set RELEASE_STUFF, 0




.if RELEASE_STUFF

.org 0x3FA4B8
.string "More Rules ->"

.org 0x3FA4E8
.long (release_string - SOM) + 0x80000000

.org 0x3FA600
.long ZERO


.org 0x3FCC10
release_string:
.string "wParam SSBM+, release 1.1"
.org 0x3FCC2C
.long ZERO

.endif


.if FANCY_THROW

.org 0x26AD20
	b ft_start
ft_back:

.org 0x46ADEC
#.org 0x2F50


.if 0

ft_start:
	
	

	#make sure we even have a player
	lwz r8, 44(r3)
	lwz r8, 0x518(r8)
	cmpwi r8, 0
	beq ft_return #if player == NULL, do nothing

	lwz r8, 44(r8)

	lwz r9, 0x65C(r8)
	andis. r9, r9, 0x00F0
	beq ft_return #if no c-stick is registered as pressed, do nothing

	lfs f2, 0x638(r8)
	lfs f3, 0x63C(r8)

ft_lop:
	lis r9, 0x4040
	stw r9, 4(r1)
	lfs f5, 4(r1)
	fmul f2, f2, f5
	fmul f3, f3, f5
	stfs f2, 0(r5)
	stfs f3, 4(r5)	
	

.endif





ft_start:
	#do the check for enabled first of all, before we go all
	#stack frame on their ass
	lis r9, 0x8000
	lwz r9, 0x2054(r9)
	andi. r9, r9, 0x8000
	bne ft_gotime #if !=0, bit set, do stuff.

	#bit is not set, just run the function
	mflr r0
	b ft_back

ft_gotime:
	mflr r0
	stw r0, 4(r1)
	stwu r1, -16(r1)

	#8  is r3
	#12 is random scratch

	stw r3, 8(r1)

	#ok. The vector pointed at by r5 has the velocity, which we aim
	#to modify.  Note that f1, r3, r4, r5, and r6 are locked.
	#We've saved r3, so clear to use that once we need it.
	#I'm assuming that I can use f2-f6 as scratch.

	#make sure we even have a player
	lwz r8, 44(r3) #load sub item
	lwz r8, 0x518(r8) #r8 has player_t
	cmpwi r8, 0
	beq ft_return #if player == NULL, do nothing

	lwz r8, 44(r8) #r8 has sub_player_t

	lbz r3, 0xC(r8)
	bl SlotToButtonData
	cmpwi r3, 0
	beq ft_return #this is a CPU player

	lwz r9, 0(r3)
	andis. r9, r9, 0x00F0
	beq ft_return #no c-stick bit is set, we assume they aren't pushing it, so for
			#efficency, we just return rather than calculate |vel|.
	mr r9, r3 #r9 is the buttons

	lfs f2, 0(r5) #f2 has X
	lfs f3, 4(r5) #f3 has Y
	fmul f4, f2, f2  #f4 = x^2
	fmul f5, f3, f3  #f5 = y^2
	fadd f4, f4, f5  # f4 has (x^2 + y^2)
	frsqrte f6, f4 
	fres f6, f6  #f6 has |velocity|

	#load the c-stick X axis byte into f2
	lbz r3, 0x1A(r9)
	extsb r3, r3
	bl fcfi
	fmr f2, f8

	#load c-stick Y axis
	lbz r3, 0x1B(r9)
	extsb r3, r3
	bl fcfi
	fmr f3, f8

	
	fmul f4, f2, f2
	fmul f5, f3, f3
	fadd f4, f4, f5  #f4 = x^2 + y^2
	
	#this should be taken care of by checking c-stick bits
	#lis r9, 0x3E00
	#stw r9, 4(r1)
	#lfs f5, 4(r1)
	#fcmpo cr0, f4, f5
	#blt ft_return

	#now, normalize the 'vector' formed by the c-stick
	frsqrte r5, r4
	fmul f2, f2, f5
	fmul f3, f3, f5  #[f2,f3] is normalized.

	#scale [f2,f3] by the velocity
	fmul f2, f2, r6
	fmul f3, f3, r6

	#and store it off
	stfs f2, 0(r5) 
	stfs f3, 4(r5)

	#we're done.
ft_return:

	lwz r3, 8(r1)
	lwz r0, 20(r1)
	addi r1, r1, 16
	mtlr r0

	#mflr r0 (don't need to do this)
	b ft_back


#converts the integer in r3 to a double in f8.
#uses: r12, f7, f6, stack
fcfi:
	mflr r12
	stw r12, 4(r1)
	stwu r1, -16(r1)

	lis r12, 0x4330
	stw r12, 8(r1)
	lis r12, 0x8000
	stw r12, 12(r1)
	lfd f7, 8(r1) #f2 = 0x4330 0000 8000 0000

	xoris r12, r3, 0x8000
	stw r12, 12(r1)
	lfd f8, 8(r1)
	fsub f8, f8, f7 #in theory it worked.

	lwz r12, 20(r1)
	addi r1, r1, 16
	mtlr r12
	blr

#converts a player slot (subplayer_t+0xC) to a pointer to a block
#that should hold the buttons for their controller.
SlotToButtonData:
	lis r12, 0x8045
	ori r12, r12, 0x3080
	mulli r3, r3, 0xE90
	add r12, r12, r3
	lwz r3, 0x8(r12)
	cmpwi r3, 0
	bne error_return
	lbz r12, 0x45(r12)
	mulli r12, r12, 68
	lis r3, 0x804C
	ori r3, r3, 0x1FAC
	add r3, r3, r12
	blr
error_return:
	li r3, 0
	blr

.endif
	

.if HOT_SATURN

.org 0x1C5C
	b SaturnFrameChain

.org 0x6a364
FrameReturn:

.org 0x948A8
GiveItemToPlayer:

.org 0xC318C
PutToSleep:


.org 0xD3BC8
DoGroundDeath:

.org 0xD40B8
DoAirDeath:


.org 0x2839BC
	b SaturnHitHook
saturnhit_back:


.org 0x46AD0C
SaturnHitHook:
	#we've hooked an mflr instruction.  We're either going to return there as if
	#nothing happened, or open our own frame, close it, and then return to the function.

	lis r9, 0x8000
	lwz r9, 0x2054(r9)
	andi. r9, r9, 0x4000
	beq hook_donothing #0= 0, so not set, so do nothing

SaturnHooking:

	#note:  r3 _MUST_ be preserved!
	mflr r0
	stw r0, 4(r1)
	stwu r1, -24(r1)
	stmw r29, 8(r1)

	#8  is r29, subplayer_t of r30
	#12 is r30, player_t
	#16 is r31, item_t passed in
	#20 is temp space for lfs

	#r31 is the item passed in
	mr r31, r3

	lwz r5, 44(r3) #r5 has sub_item_t
	lwz r30, 0xCF4(r5) #r30 has target player
	cmpwi r30, 0
	beq hook_return #if target == NULL, do nothing

	lwz r29, 44(r30) #r29 has sub_player_t

	#check if they already have an item
	lwz r8, 0x1974(r29)
	cmpwi r8, 0
	bne hook_return

	#ok.  They exist, and they don't have an item.  Give them this one.
	mr r4, r31
	mr r3, r30
	
	bl GiveItemToPlayer

	mr r3, r30
	li r4, 1
	bl PutToSleep 

	#set the sleep duration
	lis r4, 0x4170  #15.. frames, I think
	stw r4, 0x1A4C(r29)


	#should be it.

hook_return:

	mr r3, r31
	lmw r29, 8(r1)
	lwz r0, 28(r1)
	addi r1, r1, 24
	mtlr r0
hook_donothing:
	mflr r0
	b saturnhit_back


#	  Player frame chain 80001C5C
#		(return address 8006a364)
SaturnFrameChain:

	lis r9, 0x8000
	lwz r9, 0x2054(r9)
	andi. r9, r9, 0x4000
	bne chain_go
framechain_done:
	mflr r0
	b FrameReturn

chain_go:

	lwz r6, 44(r3) #sub player t
	lwz r7, 0x1974(r6) #item held
	cmpwi r7, 0
	beq framechain_done #if they don't have an item, abort

	lwz r8, 44(r7) #subitem
	lwz r8, 0x10(r8)
	cmpwi r8, 7
	bne framechain_done  #if it isn't "mr. saturn", abort

	#ok, now.  They're holding mr. saturn.  How do we detect if seconds % 5 is zero?
	#first load the seconds.
	#the item doesn't matter anymore.  If seconds % 5 = 0, we kill them, otherwise, act normally.

	#lis r6, 0x8046
	#ori r6, r6, 0xB6A0
	#lwz r6, 0x28(r6) #r6 has seconds remaining.
	#these next two instructions are equivalent to the previous 3. 
	lis r6, 0x8047
	lwz r6, -((((~0xB6A0) & 0xFFFF) + 1) - 0x28)(r6)
	cmpwi r6, 0
	beq framechain_done #seconds = 0 means either end of match or no time limit

	li r7, 5 #period of happening.

	#if ((int)(seconds / period) * period == seconds, then seconds must have been a multiple of period.
	divw r8, r6, r7
	mullw r9, r8, r7

	cmpw r9, r6
	bne framechain_done #not equal, not a multiple of period, do nothing.

	#ok.  So, they die.

	b DoGroundDeath
	
	

.endif
######################################################################


.if ITEM_STEAL_ON_GRAB_AR

.org 0x2F00
steal_go:
	#r30 is already source player.
	lwz r4, 44(r30)
	lwz r8, 0x1A58(r4)  #r8 is target player

	cmpwi r8, 0
	beq steal_done

	#make sure source player doesn't already have an item
	#shouldn't be necessary since you can't grab while holding
	#something, but just in case...
	lwz r9, 0x1974(r4)
	cmpwi r9, 0
	bne steal_done

	#make sure they're holding L
	lwz r9, 0x65C(r4)
	andi. r9, r9, 0x40
	beq steal_done #branch if they're not pressing it

	#see if they have an item.
	lwz r5, 44(r8)
	lwz r31, 0x1974(r5) #r31 is the item, if any.

	cmpwi r31, 0
	beq steal_done #no item to steal

	#load f1 appropriately.
	#Need to load r3.
	#803FBBA4 has a vector of 0
	#803FBBA4 + 0x30 has float(1)

	lis r3, 0x8040
	lfs f1, -0x442C(r3)


	addi r4, r3, -0x445C
	addi r5, r3, -0x445C
	mr r3, r31
	li r6, 1

	bl ThrowItem

	#the item is free.  Give it to the source player.

	mr r3, r30
	mr r4, r31
	bl GiveItemToPlayer

	#hopefully, it worked.
steal_done:

	#put r31 back how it was
	lwz r31, 44(r30)
	lis r3, 0x800E
	b steal_back


.org 0x948A8
GiveItemToPlayer:

.org 0xDA214
	b steal_go
steal_back:

.org 0x26AD20
ThrowItem:


.endif

.if ITEM_STEAL_ON_GRAB

#replacing:
#800DA214:  3C60800E	lis	r3,-32754
#so be sure to set r3 back when you're done.  ALso, r30
#holds the source player, and r31 holds 44(r30), so we're
#going to use r31 for our own purposes, and then set it back
#after we reset r3


.org 0x21BC
steal_zerovect:

.org 0x21E4
steal_floatone:

#We're adding this because in the future I expect the start of THrowItem to be hooked.
#So we'll want a way to access the original, unhooked version
.org 0x27E4
ThrowItem:
	mflr r0
	b RealThrowItemContinue

.org 0x28B4

#steal_tempwords:
#this wastes 4 words, yes, but it saves us way more than that in not having to set
#up a stack frame in the steal_go function.  
#.long ZERO
#.long ZERO
#.long ZERO
#.long 0x3F800000
steal_go:
	#first see if we're even doing it
	lis r3, 0x8000
	lwz r9, 0x2054(r3)
	andi. r9, r9, 0x2000
	beq steal_done


	#r30 is already source player.
	lwz r4, 44(r30)
	lwz r8, 0x1A58(r4)  #r8 is target player

	cmpwi r8, 0
	beq steal_done

	#make sure source player doesn't already have an item
	#shouldn't be necessary since you can't grab while holding
	#something, but just in case...
	lwz r9, 0x1974(r4)
	cmpwi r9, 0
	bne steal_done

	#make sure they're holding B
	lwz r9, 0x65C(r4)
	andi. r9, r9, 0x200
	cmpwi r9, 0x200
	bne steal_done #branch if they're not pressing both L and Z

	#see if they have an item.
	lwz r5, 44(r8)
	lwz r31, 0x1974(r5) #r31 is the item, if any.

	cmpwi r31, 0
	beq steal_done #no item to steal

	#load f1 appropriately.
	#r3 is still 0x80000000
	lfs f1, (steal_floatone - SOM)(r3)

	addi r4, r3, (steal_zerovect - SOM)
	addi r5, r3, (steal_zerovect - SOM)
	mr r3, r31
	li r6, 1

	bl ThrowItem

	#the item is free.  Give it to the source player.

	mr r3, r30
	mr r4, r31
	bl GiveItemToPlayer

	#hopefully, it worked.
steal_done:

	#put r31 back how it was
	lwz r31, 44(r30)
	lis r3, 0x800E
	b steal_back

#the old branch link version
.if 0

.org 0x1AE4
steal_go:
	mflr r0
	stw r0, 4(r1)
	stwu r1, -44(r1)
	stmw r29, 8(r1)
	stfd f1, 36(r1)

	#first see if we're even doing it
	lis r3, 0x8000
	lwz r3, 0x2054(r3)
	andi. r3, r3, 0x2000
	beq steal_done

	#8, 12, and 16 taken by r29, r30, r31.
	#20, 24, 28 taken by the vector
	#32 will be used to load 1 into the floating point regs
	#36 and 40 are used to store f1 in case that's required
	#44 is not ours to use.

	#r30 is already source player.
	lwz r4, 44(r30)
	b steal_continue
.org 0x28B4
steal_continue:
	lwz r31, 0x1A58(r4)  #r31 is target player

	cmpwi r31, 0
	beq steal_done

	#see if they have an item.
	lwz r5, 44(r31)
	lwz r29, 0x1974(r5) #r29 is the item, if any.

	cmpwi r29, 0
	beq steal_done #no item to steal

	#ok.  Create the 'vector'
	li r3, 0
	stw r3, 20(r1)
	stw r3, 24(r1)
	stw r3, 28(r1)

	#load f1 appropriately.
	lis r3, 0x3F80
	stw r1, 32(r1)
	lfs f1, 32(r1)

	mr r3, r29
	addi r4, r1, 20
	addi r5, r1, 20
	li r6, 1

	bl ThrowItem

	#the item is free.  Give it to the source player.

	mr r3, r30
	mr r4, r29
	bl GiveItemToPlayer

	#hopefully, it worked.
steal_done:

	lfd f1, 36(r1)
	lmw r29, 8(r1)
	lis r3, 0x800E
	lwz r0, 48(r1)
	addi r1, r1, 44
	mtlr r0
	blr

.endif


.org 0x948A8
GiveItemToPlayer:

.org 0xDA214
	b steal_go
steal_back:

.org 0x26AD24
RealThrowItemContinue:



.endif
##############################################################################
.if ITEM_TRADE_TEST


.org 0x1B10
	b respawn_nana

.org 0x34110
PlayerFromIndex:

.org 0x68E98
AllocateAndInitPlayer:

.org 0x86724
RemoveItem:

.org 0x948A8
GiveItemToPlayer:

.org 0x95EFC
IhaveNoClue:

.org 0xBFD9C
RespawnPlayer:

.org 0x26AD20
ForceDropFreakingItem:

.org 0x273F34
RemoveItem2:

.org 0x2741f4
RemoveItem3:

.org 0x2754d4
SomeOtherItemFunc:

.org 0x3F2848
.long (give_clone - SOM) + 0x80000000


.org 0x469F1C
stuck_go:
	mflr r0
	stw r0, 4(r1)
	stwu r1, -48(r1)
	stmw r30, 8(r1)

	lwz r4, 44(r3)
	lwz r7, 0x1974(r4)
	cmpwi r7, 0
	beq stuck_return

	mr r30, r7

	#16(r1) and 28(r1) will be our vectors
	lwz r6, 0xB0(r4)
	stw r6, 16(r1)
	lwz r6, 0xB4(r4)
	stw r6, 20(r1)
	li r6, 0
	stw r6, 24(r1)
	stw r6, 28(r1) #X vel zero
	stw r6, 36(r1) #Z vel also zero

	lis r6, 0x4120
	stw r6, 32(r1)

	lis r6, 0x3F80
	stw r6, 40(r1)
	lfs f1, 40(r1)

	mr r3, r7
	addi r4, r1, 16
	addi r5, r1, 28
	li r6, 1

	bl ForceDropFreakingItem

	#ok, now give it to someone else.
	li r3, 1
	bl PlayerFromIndex
	mr r4, r30

	bl GiveItemToPlayer

/*

	lwz r6, 44(r4)
	lwz r7, 0x1974(r6)

	mr r3, r7
	mr r31, r7
	mr r30, r5
	li r4, 1

	bl RemoveItem3

	mr r31, r3
	bl IhaveNoClue

	mr r3, r30
	mr r4, r31

	bl GiveItemToPlayer
*/
stuck_return:

	lwz r0, 52(r1)
	lmw r30, 8(r1)
	addi r1, r1, 48
	mtlr r0
	blr
	
give_clone:
	mflr r0
	stw r0, 4(r1)
	stwu r1, -24(r1)
	stw r31, 20(r1)

	lwz r4, 44(r3)
	lwz r5, 0x518(r4)
	cmpwi r5, 0
	beq give_clone_done

	lwz r5, 44(r5)
	lwz r6, 0x4(r5)
	stw r6, 8(r1)
	lbz r6, 0xC(r5)
	stb r6, 12(r1)
	li r6, -1
	stb r6, 13(r1)
	#2A no good.
	li r6, 0x80
	stb r6, 14(r1)

	mr r31, r5

	addi r3, r1, 8
	bl AllocateAndInitPlayer

	lis r4, 0x8045
	ori r4, r4, 0x3080
	lbz r5, 0xC(r31)
	mulli r5, r5, 0xE90
	add r4, r4, r5

	lwz r6, 180(r4)
	cmpwi r6, 0
	bne dont_kill_nana

	stw r3, 180(r4)
dont_kill_nana:
	



give_clone_done:
	lwz r31, 20(r1)
	lwz r0, 28(r1)
	addi r1, r1, 24
	mtlr r0
	blr

respawn_nana:

	mflr r0
	stw r0, 4(r1)
	stwu r1, -16(r1)

	lis r3, 0x8045
	ori r3, r3, 0x3080
	mulli r5, r5, 0xE90 #r5 is the player index
	add r3, r3, r5
	lwz r6, 0xB4(r3)
	cmpwi r6, 0
	beq respnana_done

	mr r3, r6
	bl RespawnPlayer

respnana_done:
	lwz r0, 20(r1)
	addi r1, r1, 16
	mtlr r0
	blr



.endif

.if STUCK_TO_FLOOR

.org 0x2898

#800CB4FC:  38800018	li	r4,24

stf_hook:
	lis r4, 0x8000
	lwz r4, 0x2054(r4)
	andi. r4, r4, 0x1000
	li r4, 0x18
	beq stf_do_nothing

	li r4, 0x0E
stf_do_nothing:
	b stf_back

.org 0xCB4FC
	b stf_hook
stf_back:

.endif


.if TRUE_INFINITE_JUMPS

.org 0x2860
#Using the stage configuration word, 0x800

#8009694C:  38800023	li	r4,35

tij_statehook:
	lis r4, 0x8000
	lwz r4, 0x2054(r4)
	andi. r4, r4, 0x800
	li r4, 0x23
	beq tij_do_nothing

	#bit is set, force state 0x1D
	li r4, 0x1D
tij_do_nothing:
	b tij_state_back


#great.  The second one comes from:
#8007D698:  80030168	lwz	r0,360(r3)
#when infinite 3rds are enabled, we want to make this:
#li r0, 1
#we have full scratch (r4+)

tij_copyhook:
	lis r5, 0x8000
	lwz r5, 0x2054(r5)
	andi. r5, r5, 0x800
	lwz r0, 360(r3)
	beq tij_copy_normal

	li r0, 1

tij_copy_normal:
	b tij_copy_back

.org 0x7D698
	b tij_copyhook
tij_copy_back:

.org 0x9694C
	b tij_statehook
tij_state_back:

	


.if 0
#800693AC 7C0802A6	mflr	r0
#if r4 is 0x23, make it 0x1D

.org 0x1AE4
tij_begin:
	cmpwi r4, 0x23
	bne tij_past

	li r4, 0x1D
#	li r10, 1
#	lwz r11, 44(r3)
#	stb r10, 0x1968(r11)
tij_past:
	mflr r0
	b tij_back

.org 0x693AC
	b tij_begin
tij_back:
.endif

.endif


.if GRAPHICAL_CHAR_SELECT

.org 0x2934
#updated to work better, use less words, and have more features.
bcs_stage2_go:
	lis r4, 0x8047
	ori r4, r4, 0x9D30
	li r0, 6
	stb r0, 1(r4)
	li r0, 1
	stb r0, 12(r4)
	stw r0, 52(r4)
	lis r4, 0x8000
	stw r0, 0x285C(r4)
	mflr r0
	b bcs_stage2_back

bcs_stage3_go:

	#r5 will be 0x80000000
	#r3 will be 0

	lis r5, 0x8000
	lwz r4, 0x285C(r5)
	cmpwi r4, 1
	bne	bcs_stage3_skip

	li	r3, 0
	stw r3, 0x285C(r5)

	lis r6, 0x8048
	#ori r3, r3, 0x0820
	lis r7, 0x803F
	ori r7, r7, 0xA268

	#I guess this is the stage
	lwz r8, 0x2054(r5)
	andi. r8, r8, 0x100
	bne bcs_stage3_stagelock
	lbz r5, (0x0820 - 409)(r6)
	stw r5, -8(r7)
bcs_stage3_stagelock:

	#check for team mode
	lbz r5, (0x7C0 + 8)(r6)
	stw r5,  -4(r7)



	li r0, 4
	mtctr r0

skip_loop:

	#character
	lbz r5, (0x820 + 0)(r6)
	stw r5, 0(r7)

	#kind (human, cpu)
	lbz r5, (0x820 + 1)(r6)
	stw r5, 20(r7)

	#cpu level
	lbz r5, (0x820 + 15)(r6)
	stw r5, 168(r7)

	#team
	lbz r5, (0x820 + 9)(r6)
	stw r5, 0x48(r7)

	#color
	lbz r5, (0x820 + 3)(r6)
	stw r5, 0x28(r7)
	

	addi r6, r6, 36
	addi r7, r7, 4

	bdnz skip_loop


bcs_stage3_skip:
	#li	r3,0  #already done
	blr	



.org 0x1BA160
	b bcs_stage2_go
bcs_stage2_back:

.org 0x3FA584
.long (bcs_stage3_go - SOM) + 0x80000000

.endif


.if RANDOM_STAGE_SELECT


.org 0x2EC0
rss_begin:
	cmpwi r3, 1
	bne rss_done

	#they pressed A while focused on the stage.
	lis r3, 0x8000
	lwz r4, 0x2308(r3)
	mulli r4, r4, 16807
	rlwinm r4, r4, 0, 1, 31 #clear the sign bit
	stw r4, 0x2308(r3)

	#r4 = (r4 >> 8) & 0x7F
	rlwinm r4, r4, 24, 25, 31
	cmpwi r4, 0x55
	ble rss_nochange
	addi r4, r4, -0x55
rss_nochange:

	lis r3, 0x803F
	ori r3, r3, 0xA260
	stw r4, 0(r3)

rss_done:
	li r3, 0
	blr
	
.endif


.if PROPER_SAVE_LOAD_ADDRESS

.org 0x469D40
.long 0x103FA268
.long 0x103FA26C
.long 0x103FA270
.long 0x103FA274
.long 0x103FA278
.long 0x103FA25C
.long 0x103FA27C
.long 0x103FA280
.long 0x103FA284
.long 0x103FA288
.long 0x103FA28C
.long 0x103FA290
.long 0x103FA294
.long 0x103FA298
.long 0x103FA29C
.long 0x10001FFC
.long 0x103FA2A0
.long 0x103FA2A4
.long 0x103FA2A8
.long 0x103FA2AC
.long 0x403FA2F0
.long 0x403FA2F4
.long 0x403FA2F8
.long 0x403FA2FC
.long 0x203FA2C0
.long 0x203FA2C4
.long 0x203FA2C8
.long 0x203FA2CC
.long 0x403FA2D0
.long 0x403FA2D4
.long 0x403FA2D8
.long 0x403FA2DC
.long 0x403FA2E0
.long 0x403FA2E4
.long 0x403FA2E8
.long 0x403FA2EC
.long 0x103FA300
.long 0x103FA304
.long 0x103FA308
.long 0x103FA30C
.long 0x103FA310
.long 0x103FA314
.long 0x103FA318
.long 0x103FA31C
.long 0x103FA2B0
.long 0x103FA2B4
.long 0x103FA2B8
.long 0x103FA2BC
.long 0x203FA260
.long 0x103FA264
.long 0x10002820
.long 0x40002054
.long 0x103FA320
.long 0x103FA324
.long 0x103FA328
.long 0x113FA32C
.long 0x403FA344
.long 0x103FA334
.long 0x103FA338
.long 0x103FA33C
.long 0x103FA340
.long 0x103FA330
.long 0x1000269C
.long 0x103FA350
.long 0x10002000
.long 0x403FA348
.long 0x1000201C
.long 0x100022C0
.long 0x100022C4
.long 0x100022C8
.long 0x100022CC
.long 0x100022D0
.long 0x100022D4
.long 0x110024A8
.long 0x110024AC
.long 0x110024B0
.long 0x110024B4
.long 0x110024B8
.long 0x110024BC
.long 0x10001800
.long 0x103FA39C
.long 0x103FA3A0
.long 0x40002848
.long 0x4000284C
.long 0x20002850
.long 0x1049FAB4
.long 0x100019FC
.long 0x403FA15C
.long 0x403FA160
.long 0x400019F8
.long 0x40002830
.long 0x40002834
.long 0x1000280C
.long 0x10002810
.long 0x10002814
.long 0x10002824
.long 0x10002828
.long 0x1000282C
.long 0x10002818
.long 0x1000281C
.long 0x40001B98
.long 0x40001B9C
.long 0x40001BA0
.long 0x40001BA4
.long 0x200027F4
.long 0x200027F8
.long 0x200027FC
.long 0x20002800
.long 0x20002804
.long 0x20002808
.long 0x10001E8C
.long 0x10001E90
.long 0x10001E94
.long 0x10001E98
.long 0x10001E9C
.long 0x10001EA0
.long 0x103FA154
.long 0x10002858
.long ZERO

.endif



.if PROPER_SAVE_LOAD


.if 0
.org 0x1B00
save_hacko:
	mflr r0
	stw r0, 4(r1)
	stwu r1, -16(r1)
	stw r31, 8(r1)

	mr r31, r3

	lbz	r0,0(r3)
	lwz	r5,8(r3)
	rlwinm	r4,r0,5,0,26
	add r5, r4, r5
	#r5 should be our menu.  Print the data pointer
	lwz r4, 16(r5)
	lis r3, 0x8000
	ori r3, r3, (save_tempstring - StartOfMemory)

	bl printf

	mr r3, r31
	lwz r0, 20(r1)
	lwz r31, 8(r1)
	addi r1, r1, 16
	mtlr r0
	b save_back_to_code

save_tempstring:
.string "Address: %X\n"	

#80303720:  7C0802A6	mflr	r0
.org 0x303720
	b save_hacko
save_back_to_code:


.org 0x3456a8
	printf:

.endif


.org 0x1b14
#change handler for the save menu index.  Quite a bit more complicated
#than the string index handler
sl_saveload_index_handler:

	mflr r0
	stw r0, 4(r1)
	stwu r1, -16(r1)
	stmw r30, 8(r1)

	#this needs to run all the time.  (well, on open, inc, and dec, don't really care about close)
#	cmpwi r3, 3
#	beq sl_saveload_validinput
#	cmpwi r3, 2
#	bne sl_saveload_index_handler_done
sl_saveload_validinput:

	#Ok.  We need to load the effective address and check the checksum.
	#if it matches, copy the string over and enable the load menu.
	#if not, disable the load menu.

	lis r30, 0x8000
	lwz r4, (sl_saveload_index - StartOfMemory)(r30)
	mulli r5, r4, -0x1A4
	lis r4, (((sl_startofsaves - StartOfMemory) >> 16) & 0xFFFF) | 0x8000
	ori r4, r4, (sl_startofsaves - StartOfMemory) & 0xFFFF
	add r31, r4, r5

	addi r3, r31, 4
	li r4, 0x19C #0x1A4 - 4 for the rumble word at the end - 4 because we're starting 4 bytes in
	bl sl_checksum

	lwz r4, 0(r31)
	cmpw r3, r4
	bne sl_checksum_fail

	#these two sections set r6 to the value for the load menu,
	#and r7 to be the address of a string we'll copy in.

sl_checksum_match:
	li r6, 1
	addi r4, r31, 4
	b sl_checksum_merge

sl_checksum_fail:
	li r6, 0
	ori r4, r30, (sl_saveload_failstring - SOM)
	#no branch

sl_checksum_merge:

	#enable or disable the load menu, depending
	lis r3, (((sl_saveload_loadmenuentry - SOM) >> 16) & 0xFFFF) | 0x8000
	ori r3, r3, (sl_saveload_loadmenuentry - SOM) & 0xFFFF
	stw r6, 0(r3)

	#copy the appropriate string in
	ori r3, r30, (sl_saveload_string - SOM) & 0xFFFF
	#r4 already loaded
	li r5, 0xC
	bl memcpy

	#done

	
sl_saveload_index_handler_done:
	li r3, 0
	lwz r0, 20(r1)
	lmw r30, 8(r1)
	addi r1, r1, 16
	mtlr r0
	blr

	
.org 0x1B98
sl_unusable:


.org 0x26BC

#this address holds the beginning of the address table
sl_addresstable_loc:
.long (sd_default_addresslist - SOM) + 0x80000000

#the index that we'll be saving/loading
sl_saveload_index:
.long ZERO

#this is the working area for the string displayed in the menu; 3 words
sl_saveload_string:
.string "foo"
.long ZERO
.long ZERO
sl_saveload_stringindex:
.long ZERO #this word stores the index into the string.  This will be ok, because
	   #the index will always be contained in the low byte, so the high byte
	   #(the only important one as far as a string is concerned) will always
	   #by zero.

#for real this time.

#calculate a checksum.
#r3: start address
#r4: length, must be > 0
sl_checksum:

	#r5 will be the output
	li r5, 0x1010  #just don't make it zero
	mtctr r4

sl_cksumloop:
	lbz r6, 0(r3)

	# r5 ^= r6; r5 <<= 4; 
	xor r5, r5, r6
	rlwinm r5, r5, 4, 0, 31

	addi r3, r3, 1
	bdnz sl_cksumloop

	mr r3, r5
	blr


#save data from ram to the memcard area
#
#Address list has address encoded with their
#appropriate length.  The high byte contains flags:
#
#  0x80: error
#  0x40: 4 bytes long (float or int)
#  0x20: 2 bytes long (short)
#  0x10: 1 byte long
#  0x01: extend sign bit for 8 bit values (only valid on load)
#  0x02: extend sign bit for 16 bit values (only valid on load)
#
#   The length refers to the length on the save card, NOT in memory.
#   All values are loaded as 32 bits from ram.  The lengths must add
#   up properly with respect to alignment; this function does not
#   check for it.
#
#   Returns 0 on success, 1 on failure
#
#r3: address of addresses, NULL terminated
#r4: target address (on memcard; the data will begin here)
sl_savedata:

	#r5 has the 'source' address
	#r6 has the flags, shifted into the low byte

sl_savedata_loop:
	lwz r5, 0(r3)
	cmpwi r5, 0
	beq sl_savedata_done

	rlwinm. r6, r5, 8, 24, 31
	beq sl_savedata_error #no flags set is an error
	rlwinm r5, r5, 0, 8, 31
	oris r5, r5, 0x8000

	#load the value we're going to save from the source
	lwz r7, 0(r5)

	andi. r0, r6, 0x10
	bne sl_savedata_onebyte
	andi. r0, r6, 0x20
	bne sl_savedata_twobytes
	#so we assume it's 4 bytes.

sl_savedata_fourbytes:
	stw r7, 0(r4)
	b sl_savedata_merge
sl_savedata_twobytes:
	sth r7, 0(r4)
	b sl_savedata_merge
sl_savedata_onebyte:
	stb r7, 0(r4)
	#no branch; we're there

sl_savedata_merge:
	rlwinm r7, r6, 28, 28, 31 #this makes r7 = 1, 2, or 4
	add r4, r4, r7

	addi r3, r3, 4
	b sl_savedata_loop
sl_savedata_done:

	#success.
	li r3, 0
	b sl_savedata_return
sl_savedata_error:
	li r3, 1
sl_savedata_return:
	blr

		
#load data from memcard to ram
#
#Address list has address encoded with their
#appropriate length.  The high byte contains flags:
#
#  0x80: error
#  0x40: 4 bytes long (float or int)
#  0x20: 2 bytes long (short)
#  0x10: 1 byte long
#  0x01: extend sign bit for 8 bit values (only valid on load)
#  0x02: extend sign bit for 16 bit values (only valid on load)
#
#   The length refers to the length on the save card, NOT in memory.
#   All values are loaded as 32 bits from ram.  The lengths must add
#   up properly with respect to alignment; this function does not
#   check for it.
#
#   Returns 0 on success, 1 on failure
#
#r3: address of addresses, NULL terminated
#r4: target address (on memcard; the data will begin here)

sl_loaddata:

	#r5 is the "target" address
	#r6 is the flags that go with said address.

sl_loaddata_loop:
	lwz r5, 0(r3)
	cmpwi r5, 0
	beq sl_loaddata_done

	rlwinm. r6, r5, 8, 24, 31
	beq sl_loaddata_error
	rlwinm r5, r5, 0, 8, 31
	oris r5, r5, 0x8000

	andi. r0, r6, 0x10
	bne sl_loaddata_onebyte
	andi. r0, r6, 0x20
	bne sl_loaddata_twobytes
	#assume four bytes

sl_loaddata_fourbytes:
	lwz r7, 0(r4)
	b sl_loaddata_merge

sl_loaddata_twobytes:
	lhz r7, 0(r4)
	andi. r0, r6, 0x02
	beq sl_loaddata_merge #the and == 0, so the bit is not set
	extsh r7, r7
	b sl_loaddata_merge

sl_loaddata_onebyte:
	lbz r7, 0(r4)
	andi. r0, r6, 0x01
	beq sl_loaddata_merge
	extsb r7, r7
	#no branch

sl_loaddata_merge:

	rlwinm r8, r6, 28, 28, 31
	add r4, r4, r8

	stw r7, 0(r5)

	addi r3, r3, 4
	b sl_loaddata_loop

sl_loaddata_done:

	#success.
	li r3, 0
	b sl_loaddata_return
sl_loaddata_error:
	li r3, 1
sl_loaddata_return:
	blr

sl_saveload_failstring:
.string "CRC Failed"



.org 0x27EC
sl_invalidaddy:


.org 0x2F00
#the format for a save will be:
# save+0x00: checksum, computed last
# save+0x04 - 0x0C: string name
# save+0x10: data

#The code for when the user picks 'save'
#params: r3: if it's 1, return, otherwise go.
sl_savemenu:

	mflr r0
	stw r0, 4(r1)
	stwu r1, -16(r1)
	stmw r30, 8(r1)

	cmpwi r3, 1
	bne sl_savemenu_done

	#ok, we're going to use r31 as the pointer to where the data starts
	#r30 will be "0x80000000"

	#first zero out the whole range, so compute r31.  (Also sets r30)
	lis r30, 0x8000
	lwz r4, (sl_saveload_index - StartOfMemory)(r30)
	mulli r5, r4, -0x1A4
	lis r4, (((sl_startofsaves - StartOfMemory) >> 16) & 0xFFFF) | 0x8000
	ori r4, r4, (sl_startofsaves - StartOfMemory) & 0xFFFF
	add r31, r4, r5

	#ok.  First, zero out everything
	mr r3, r31
	li r4, 0
	li r5, 0x1A0 #not zeroing the last word in the range; rumble menu fiddles with it
	bl memset

	#copy the string
	addi r3, r31, 4
	ori r4, r30, ((sl_saveload_string - StartOfMemory) & 0xFFFF)
	li r5, 0xC
	bl memcpy

	#copy the data
	lwz r3, (sl_addresstable_loc - StartOfMemory)(r30)
	addi r4, r31, 0x10
	bl sl_savedata

	#finally, compute a checksum
	addi r3, r31, 4
	li r4, 0x19C #0x1A4 - 4 for the rumble word at the end - 4 because we're starting 4 bytes in
	bl sl_checksum
	stw r3, 0(r31)

	#call the index change handler.  It will enable the load menu.
	li r3, 2
	bl sl_saveload_index_handler

	#that's it.  TODO: call the memcard save function.
	#update:  this is not likely to ever happen, ever.
	

sl_savemenu_done:
	li r3, 0
	lwz r0, 20(r1)
	lmw r30, 8(r1)
	addi r1, r1, 16
	mtlr r0
	blr


#sl_loadmenu
#The code for the debug menu load thingie
sl_loadmenu:
	mflr r0
	stw r0, 4(r1)
	stwu r1, -16(r1)
	stmw r30, 8(r1)

	cmpwi r3, 1
	bne sl_savemenu_done

	#we assume that the checksum has already been consulted.  (Change handler for
	#the index disables this menu if the checksum is invalid.

	lis r30, 0x8000
	lwz r4, (sl_saveload_index - StartOfMemory)(r30)
	mulli r5, r4, -0x1A4
	lis r4, (((sl_startofsaves - StartOfMemory) >> 16) & 0xFFFF) | 0x8000
	ori r4, r4, (sl_startofsaves - StartOfMemory) & 0xFFFF
	add r31, r4, r5

	#restore the data from the card slot
	lwz r3, (sl_addresstable_loc - StartOfMemory)(r30)
	addi r4, r31, 0x10
	bl sl_loaddata

	#copy the string in
	addi r3, r30, (sl_saveload_string - StartOfMemory)
	addi r4, r31, 4
	li r5, 0xC
	bl memcpy

	#that should be it.
	

sl_loadmenu_done:
	li r3, 0
	lwz r0, 20(r1)
	lmw r30, 8(r1)
	addi r1, r1, 16
	mtlr r0
	blr

.org 0x3000
sl_morebaddata:



.org 0x3130
memset:

.org 0x3220
memcpy:


.org 0x303A64
# Change handler for the string char index menu entry.
# Just updates the string pointer to be sl_saveload_string + 
# sl_saveload_stringindex
sl_saveload_cindex_change:
	#we're ignoring r3; it won't matter why the change handler
	#is being called.

	lis r3, 0x8000
	lwz r4, (sl_saveload_stringindex - SOM)(r3)
	ori r3, r3, (sl_saveload_string - SOM)
	add r3, r3, r4

	lis r4, (((sl_saveload_menuvalue - SOM) >> 16) & 0xFFFF) | 0x8000
	ori r4, r4, (sl_saveload_menuvalue - SOM) & 0xFFFF
	stw r3, 0(r4)

	li r3, 0

	blr












.org 0x3FDAC4
str_1:
.string "Save/load"
str_index:
.string "Index :"
str_cind:
.string "cind  :"
str_char:
.string "char  :"
str_save:
.string "Save  >"
str_load:
.string "Load  >"

.org 0x3FDAF8
.long ZERO
.long ZERO
.long (str_1 - SOM) + 0x80000000
.long ZERO
.long ZERO
.long ZERO
.long ZERO
.long ZERO

.long 0x00000003
.long (sl_saveload_index_handler - SOM) + 0x80000000
.long (str_index - SOM) + 0x80000000
.long ZERO
.long (sl_saveload_index - SOM) + 0x80000000
.long ZERO
.long 0x42C80000
.long 0x3F800000

#this just needs to point at some value that's NULL
sd_default_addresslist:
.long ZERO
.long ZERO
.long (sl_saveload_string - SOM) + 0x80000000
.long ZERO
.long ZERO
.long ZERO
.long ZERO
.long ZERO

.long 0x00000003
.long (sl_saveload_cindex_change - SOM) + 0x80000000
.long (str_cind - SOM) + 0x80000000
.long ZERO
.long (sl_saveload_stringindex - SOM) + 0x80000000
.long ZERO
.long 0x41300000
.long 0x3F800000

.long 0x00000005
.long ZERO
.long (str_char - SOM) + 0x80000000
.long ZERO
sl_saveload_menuvalue:
.long (sl_saveload_string - SOM) + 0x80000000
.long ZERO
.long ZERO
.long 0x3F800000

.long 0x00000001
.long (sl_savemenu - SOM) + 0x80000000
.long (str_save - SOM) + 0x80000000
.long ZERO
.long ZERO
.long ZERO
.long ZERO
.long ZERO

sl_saveload_loadmenuentry:
.long ZERO
.long (sl_loadmenu - SOM) + 0x80000000
.long (str_load - SOM) + 0x80000000
.long ZERO
.long ZERO
.long ZERO
.long ZERO
.long ZERO

.long 0x00000009
.long ZERO
.long ZERO
.long ZERO
.long ZERO
.long ZERO
.long ZERO
.long ZERO





.org 0x469B98
sl_startofsaves:



.endif
###########################################################



.if NEW_ENUM_TEXT

.org 0x3FB430
net_00: .string "C.Falcon"
net_01: .string "D.Kong"
net_02: .string "Fox"
net_03: .string "Game&Watch"
net_04: .string "Kirby"
net_05: .string "Bowser"
net_06: .string "Link"
net_07: .string "Luigi"
net_08: .string "Mario"
net_09: .string "Marth"
net_0A: .string "Mewtwo"
net_0B: .string "Ness"
net_0C: .string "Peach"
net_0D: .string "Pikachu"
net_0E: .string "Ice Climbers"
net_0F: .string "Jigglypuff"
net_10: .string "Samus"
net_11: .string "Yoshi"
net_12: .string "Zelda"
net_13: .string "Shiek"
net_14: .string "Falco"
net_15: .string "Young Link"
net_16: .string "Dr.Mario"
net_17: .string "Roy"
net_18: .string "Pichu"
net_19: .string "Gannon"
net_1A: .string "Master Hand"
net_1B: .string "Male wire"
net_1C: .string "Female wire"
net_1D: .string "Giga bowser"
net_1E: .string "Crazy Hand"
net_1F: .string "Sandbag"
net_20: .string "Popo"
net_21: .string "Random"
.byte 0x00
.byte 0x73
.byte 0x13

.org 0x3FB538
.long (net_00 - StartOfMemory) + 0x80000000
.long (net_01 - StartOfMemory) + 0x80000000
.long (net_02 - StartOfMemory) + 0x80000000
.long (net_03 - StartOfMemory) + 0x80000000
.long (net_04 - StartOfMemory) + 0x80000000
.long (net_05 - StartOfMemory) + 0x80000000
.long (net_06 - StartOfMemory) + 0x80000000
.long (net_07 - StartOfMemory) + 0x80000000
.long (net_08 - StartOfMemory) + 0x80000000
.long (net_09 - StartOfMemory) + 0x80000000
.long (net_0A - StartOfMemory) + 0x80000000
.long (net_0B - StartOfMemory) + 0x80000000
.long (net_0C - StartOfMemory) + 0x80000000
.long (net_0D - StartOfMemory) + 0x80000000
.long (net_0E - StartOfMemory) + 0x80000000
.long (net_0F - StartOfMemory) + 0x80000000
.long (net_10 - StartOfMemory) + 0x80000000
.long (net_11 - StartOfMemory) + 0x80000000
.long (net_12 - StartOfMemory) + 0x80000000
.long (net_13 - StartOfMemory) + 0x80000000
.long (net_14 - StartOfMemory) + 0x80000000
.long (net_15 - StartOfMemory) + 0x80000000
.long (net_16 - StartOfMemory) + 0x80000000
.long (net_17 - StartOfMemory) + 0x80000000
.long (net_18 - StartOfMemory) + 0x80000000
.long (net_19 - StartOfMemory) + 0x80000000
.long (net_1A - StartOfMemory) + 0x80000000
.long (net_1B - StartOfMemory) + 0x80000000
.long (net_1C - StartOfMemory) + 0x80000000
.long (net_1D - StartOfMemory) + 0x80000000
.long (net_1E - StartOfMemory) + 0x80000000
.long (net_1F - StartOfMemory) + 0x80000000
.long (net_20 - StartOfMemory) + 0x80000000
.long (net_21 - StartOfMemory) + 0x80000000
 


.endif

.if DEBUG_MENU_DPAD


#r7: delay value (8 by default, set to 1 if R is pressed)
#r8: computed output
#r9: address of this player's button block
#r10:current player index
.org 0x3039A4

	#we're ignoring the parameter, it's always zero anyway.  We always
	#compute buttons from all controllers
	li r10, 0
	li r8, 0 #output value
	li r7, 8 #default delay value

dbd_beginning:
	

	lis r4, 0x804C
	ori r4, r4, 0x20BC
	mulli r5, r10, 68
	add r9, r4, r5

	#or in the immediate buttons
	lwz r3, 8(r9)
	andi. r3, r3, 0x1F10 #start, abxy, z
	or r8, r8, r3

	lwz r3, 0(r9)
	andi. r0, r3, 0x20
	beq dbd_nopacechange
	li r7, 0
dbd_nopacechange:

	#frob the d-pad to get its values in line with the analog selectors
	rlwinm r0, r3, 25, 3, 3
	rlwimi r0, r3, 27, 2, 2
	rlwimi r0, r3, 30, 0, 1
	or r8, r8, r0

	#regular analog
	rlwinm r0, r3, 12, 0, 3
	or r8, r8, r0

	#c-stick: always turbo
	rlwinm. r0, r3, 8, 0, 3
	beq dbd_nocstick
	li r7, 0
	or r8, r8, r0 #might as well skip this or as well, though it makes no difference
dbd_nocstick:

	addi r10, r10, 1
	cmpwi r10, 4
	blt dbd_beginning

	#ok.  We have everyone's buttons.  Test to see if they're pressing anything
	andis. r0, r8, 0xF000
	beq dbd_no_buttons_pressed
dbd_buttons_pressed:

	#something is pressed.  Look at the counter.  If it's nonzero, decrement it,
	#and clear the buttons.  If it's zero, set it to r7
	lbz r3, -18516(r13)
	cmpwi r3, 0
	beq dbd_is_zero

	#not zero.
	subi r3, r3, 1
	stb r3, -18516(r13)
	rlwinm r8, r8, 0, 4, 31 #mask off the upper 4 bits
	b dbd_all_done

dbd_is_zero:

	stb r7, -18516(r13)
	b dbd_all_done


dbd_no_buttons_pressed:

	#no buttons pressed.  Set the counter to 0 and return
	li r3, 0
	stb r3, -18516(r13)
	#b dbd_all_done

dbd_all_done:
	mr r3, r8
	blr


			

.org 0x303AC4
dbd_spaceclaimed:

#r30 would normally get p0's instant buttons here; we don't want
#that to happen
.org 0x303AE8
	li r30, 0

.endif

.if EVENT_STAGES

# Load chain 80001D08

.org 0x1cbc

#this isn't the most efficent, implementation, execution wise,
#but I think it's the best space wise
evs_loadchain:
	lhz r5, 0xE(r30)
	cmpwi r5, 0x15 #akaneia
	bne evs_not_akaneia
	li r5, 215 #goomba stage
evs_not_akaneia:
	cmpwi r5, 0x1A #icetop
	bne evs_not_icetop
	li r5, 227 #entei stage
evs_not_icetop:
	cmpwi r5, 0x4D #icetop adventure
	bne evs_not_iceadv
	li r5, 248
evs_not_iceadv:
	sth r5, 0xE(r30)
	b evs_load_return


.org 0x1D08
	b evs_loadchain
.org 0x2300
evs_load_return:


.endif

.if CRASH_WATCH_1

.org 0x1b00
crash_watch_one:
	lis r9, 0x8049
	ori r9, r9, 0xED94
	lwz r9, 0(r9)
	cmpwi r9, 0
	beq cw_donothing
	nop
cw_donothing:
	mflr r0
	b cw_back_to_code

.org 0x370BEC
	b crash_watch_one
cw_back_to_code:

.endif
	

.if DUMMY_CAMERA


#hook into the start of the fixed camera function.  If we're on stage 0, do
#something special



.org 0x1B98

duse_fc_fov:
.long 0x41F00000
duse_fc_depth:
.long 0x44098000
duse_fc_width:
.long 0x43660000
duse_fc_height:
.long 0x43390000


duse_fixed_cam:
	lis r6, 0x8046
	ori r6, r6, 0xDB68
	lhz r7, 0xE(r6)
	cmpwi r7, 0
	beq duse_special_case

	#it's != 0, so we're not on dummy, return to function
	mflr r0
	b duse_fixed_cam_back

duse_special_case:
	#ok.  We're on the dummy stage, and we're taking control of this
	#function, so fix the camera range, and then return

	lis r6, 0x8045
	ori r3, r6, 0x2C78
	li r4, 33
	mtctr r4

	#don't need to do this because we already know r7 is 0 (we wouldn't have
	#branched here if it wasn't
	#lis r5, 0
duse_zero_loop:
	stwu r7, 4(r3)
	bdnz duse_zero_loop

	#r6 still has the upper half word in it
	ori r3, r6, 0x2C68

	lis r4, 0x8000

	lwz r5, (duse_fc_fov - StartOfMemory)(r4)
	stw r5, 0x44(r3)
	lwz r5, (duse_fc_depth - StartOfMemory)(r4)
	stw r5, 0x34(r3)

	#yay
	blr



duse_kill_player:

	#first and foremost, ONLY do this if we're on the dummy stage
	lis r6, 0x8046
	ori r6, r6, 0xDB68
	lhz r7, 0xE(r6)
	cmpwi r7, 0
	bne duse_already_kild #obviously they aren't killed, but "do nothing" is what this does

	lis r7, 0x8000
	lwz r8, 44(r3)

	lwz r9, 0x10(r8)
	cmpwi r9, 4 #the "death from above" state
	beq duse_already_kild

	lwz r10, 0x2054(r7)

	#the way this works is by testing the wrap bit, then seeing if
	#the player crossed a boundary.  The cross edge code checks for
	#this bit, if it's clear, it kills the person, if it's set, it
	#moves them.  The move is done for an X coordinate, the way we
	#move their Y coordinate is by adding 4 to the address register,
	#causing all X loads to actually be y loads.

	andi. r9, r10, 0x0400
	lfs f0, 0xB0(r8)
	fabs f0, f0
	lfs f1, (duse_fc_width - StartOfMemory)(r7)
	fcmpo cr0, f0, f1
	bgt duse_edge_triggered

	addi r8, r8, 4 #fudge it so that we look at the Y coordinate.

	andi. r9, r10, 0x200
	lfs f0, 0xB0(r8) #note: actually comes from 0xB4(r8)
	fabs f0, f0
	lfs f1, (duse_fc_height - StartOfMemory)(r7)
	fcmpo cr0, f0, f1
	bgt duse_edge_triggered

	#passed both tests, run the frame as normal.
duse_already_kild:
	mflr r0
	b player_chain_back

duse_edge_triggered:
	cmpwi r9, 0
	beq duse_do_the_kill	

	#ok.  So it's in wrap around mode.
	lwz r9, 0xB0(r8)
	lfs f0, 0xB0(r8)

	#test the sign bit.
	andis. r9, r9, 0x8000
	bne duse_coord_negative
	#coordinate is positive.  Subtract f1 twice
	fsub f0, f0, f1
	fsub f0, f0, f1
	b duse_coord_done
duse_coord_negative:
	#coordinate is negative.  Add f1 twice
	fadd f0, f0, f1
	fadd f0, f0, f1
duse_coord_done:

	#now we have to move them.  f0 has their new coordinate.
	#"moving" a player consists of writing the new value to all
	#six x coordinates in the player structure.
	stfs f0, 0xB0(r8)
	stfs f0, 0xBC(r8)
	stfs f0, 0x6F4(r8)
	stfs f0, 0x700(r8)
	stfs f0, 0x70C(r8)
	stfs f0, 0x718(r8)

	#and run the frame as normal
	b duse_already_kild
	

duse_do_the_kill:

	b DoAirDeath

#this is just a shim run when dummy loads to clear some random pointer.  This
#pointer is set by every stage (Except dummy) when it loads, it's relevent to
#something, though I know not what.  It isn't cleared when the stage finishes,
#causing subsequent runs on dummy to crash.  So, the moral of the story is to
#null out this value.
duse_stage_load:
	lis r9, 0x804A
	#ori r9, r9, 0xED94
	li r8, 0
	stw r8, -0x126C(r9)
	blr

.org 0x2110
	b duse_kill_player


#this intercepts the fixed camera run function
.org 0x2DDC4
	b duse_fixed_cam
duse_fixed_cam_back:

#the return location for player frame chain
.org 0x6a364
player_chain_back:

.org 0xD40B8
DoAirDeath:

#this changes one of dummy's function pointers to be the shim above.
.org 0x3dfebC
.long (duse_stage_load - StartOfMemory) + 0x80000000

.endif


.if CAMERA_KILL_TEST

.org 0x2F04
camera_test_area:
	mflr r0
	stw r0, 4(r1)
	stwu r1, -8(r1)

	lis r3, 0x8045
	ori r3, r3, 0x3080
	lwz r3, 0xB0(r3)

	lwz r4, 44(r3)
	lwz r4, 0x0668(r4)
	andi. r4, r4, 0x10
	beq camera_nodeath

	bl DoAirDeath

	lis r3, 0x8000
	ori r3, r3, (camera_foostring - StartOfMemory)
	li r4, 354
	bl printf


camera_nodeath:
	lwz r0, 12(r1)
	addi r1, r1, 8
	mtlr r0
	blr

camera_foostring:
.string "Foo foo %i\n"

.org 0x2DDC4
	b camera_test_area

.org 0xD40B8
	DoAirDeath:

.org 0x3456a8
	printf:

.endif


.if FIXED_CAMERA_TOGGLE

#load chain 80001F20


.org 0x1CEC
fcam_begin:
	lis r5, 0x8000
	lwz r5, 0x2054(r5)
	andi. r5, r5, 0x80
	beq fcam_nothing
	lis r5, 0x8016
	ori r5, r5, 0x5290
	stw r5, 0x38(r30)
fcam_nothing:
	b fcam_load_chain

.org 0x1F20
	b fcam_begin
	
.org 0x2300
fcam_load_chain:

.endif



.if ITEMS_DONT_DISAPPEAR


.org 0x2128

#80269638:  D01F0D44	stfs	f0,3396(r31)
#we have r3 as scratch.
idd_hook:
	lis r3, 0x8000
	lwz r3, 0x2054(r3)
	andi. r3, r3, 0x40
	bne idd_nodothing
	stfs f0, 3396(r31)
idd_nodothing:
	b idd_back_to_code

.org 0x269638
	b idd_hook
idd_back_to_code:

.endif


.if DPAD_DOWN_MOVES

#Ok.  This block hooks HandleDeveloperKeys() at the point where it loads
#the value of the develop flag from global memory.  We do that load
#first thing, and then if it's /master/ mode, we do our little go time
#loop, which consists of calling the function that tests for dpad down
#and does stuff.  Note that said function is also hooked by the other
#dpad moves, so if you aren't in master mode, the other moves won't work.
#This part is ONLY for getting our function called; the function that's
#called can still decide to do nothing of its own accord.


.org 0x19F8
dpad_itemtypes:
.long 0x22222222
dpad_enabled:
.long ZERO

.org 0x1A00
dpad_alwaysdevelop:
	lwz r0,-27800(r13)
	cmpwi r0, 0
	beq go_time
	b back_to_DeveloperKeys
go_time:
#	stw r13, 24(r1)
	li	r30,0

go_time_loop:
	mr	r3,r30
	bl	DpadGoTimeFunction
	addi	r30,r30,1
	cmpwi	r30,4
	blt go_time_loop
	lwz r30, 32(r1)
#	lwz r13, 24(r1)
	lwz r0, -27800(r13)
	b back_to_DeveloperKeys

#next we have a function that returns the buttons being pressed.  To be
#honest, I can't remember why it's necessary.  The commands in the patch
#script say that develop mode uses a different location for buttons, so
#the function this replaces doesn't work in non-develop mode.
#Update:  We don't seem to need it at all, so I'm dropping it from the
#code.  We'll see if anything bad happens because of it.
#(I think what was happening is that the function I'm dropping was one
#of a pair, the other being the long one that appears below.  Originally,
#I just wanted items to drop in non-develop mode, so I thought I had to
#copy both.  Whatever.)


#Ok.  This is our own function that implements "what buttons is player x
#pushing?"  We decide that based on some extra information.
special_dpad_query:
	lis	r4, 0x8000
	lwz	r5, (dpad_enabled - StartOfMemory)(r4)
	cmpwi	r5, 0
	bne	pastbranch
	b do_no_auto_drop  #simply "return 0"
pastbranch:
	#first, load the item for this player and stick it in the spot
	li r5, (dpad_itemtypes - StartOfMemory)
	add r5, r5, r3
	
	lbzx r6, r4, r5 #r6 contains the player's item value.
	#load is from 80479D58
	lis r5, 0x8048 #load one of the heart's timers for randomness
	lwz r5, -0x62A8(r5)

	#move the mask bits of r6 to r7 in the low bits
	rlwinm r7, r6, 26, 30, 31
	and r5, r7, r5 #r5 should now have two lowest bits of heart timer

	add r6, r5, r6 #r6 has been increased by a random amount
	andi. r6, r6, 0x3F  #mask off the upper bits
	
	#now store this value in the 'develop mode item to spawn' spot
	#store is to 8049FAB0
	lis r5, 0x804A
	stw r6, -0x550(r5)

#ok, now for the item shits test
#see if it's enabled
	#r4 is still 0x80000000
	lwz r6, (dpad_shits_enabled - StartOfMemory)(r4)
	cmpwi r6, 0
	beq no_auto_drop

#it's enabled, see if they crap
	#test to see if they're even playing.
	lis r5, 0x8045
	ori r5, r5, 0x3080
	mulli r8, r3, 0xE90
	add r5, r5, r8
	lwz r8, 8(r5)
	cmpwi r8, 3
	beq do_no_auto_drop


	#lis r4, 0x8000 still the same
	ori r4, r4, (dpad_shits_temp - StartOfMemory)
	add r4, r3, r4
	lbz r5, 0(r4)
	subi r5, r5, 1
	stb r5, 0(r4)
	cmpwi r5, 0
	bne do_no_auto_drop  #if it's not zero, do nothing unusual

#if it is zero, return "dpad down" (i.e. they crap)
	#a cycle has been completed, so reset the counter.
	stb r6, 0(r4)
	li r3, 0x04 
	blr	

do_no_auto_drop:
	li r3, 0
	blr

no_auto_drop:
	mulli	r0,r3,68
	lis	r3,0x804C
	ori	r3,r3,0x1FAC
	add	r3,r3,r0
	lwz	r3,8(r3)
	blr	




.org 0x2850
dpad_shits_enabled:
.long ZERO
dpad_shits_temp:
.long 0x01010101

.org 0x22576C
	b dpad_alwaysdevelop
back_to_DeveloperKeys:

.org 0x226308
	bl special_dpad_query

.org 0x2264c4
DpadGoTimeFunction:


.endif



.if POW_BLOCK_AR


.org 0x2F04
pbar_start:

	lwz r4, 44(r3)

	lwz r5, 0x518(r4)
	cmpwi r5, 0
	beq pbar_done

	mr r7, r5
	
	#load r8 and walk it back to the beginning of the player list.
	lis r3, 0x8045
	ori r3, r3, 0x3080
	lwz r8, 0xB0(r3)

	#we're assuming the first player is the head of the list

	#ok.  r7 has the player we exclude.  r8 has the first player.
	#make them hurty.
	

pbar_loop:

	cmpw r7, r8
	beq pbar_skip

	lwz r5, 44(r8)
	lis r3, 0x447A
	stw r3, 0x1838(r5)
	
pbar_skip:

	lwz r8, 0x10(r8)
	cmpwi r8, 0
	bne pbar_loop

pbar_done:

	blr

.org 0x3F1c50
.long (pbar_start - StartOfMemory) + 0x80000000

.endif



.if NEW_ITEMS_WOOT


.org 0x1800
niw_pow_randomfactor:
.long 0x00000004

niw_dospecial:
.long ZERO

niw_frame_chain:
	mflr r0
	stw r0, 4(r1)
	stwu r1, -12(r1)

	#now we have a stack frame.  It's go time.

	#grab the sub_item_t and check for NULL
	lwz r4, 44(r3)
	cmpwi r4, 0
	beq niw_frame_done

	#grab the player_t from sub_item and check for NULL.
	#I don't know if either of these NULL checks are necessary or not,
	#but I'm puttingthem in anyway.
	lwz r5, 0x518(r4)
	cmpwi r5, 0
	beq niw_frame_done

	#r7 will hereafter contain the player_t of the one who got the box.
	mr r7, r5
	lwz r5, 44(r5)
	cmpwi r5, 0
	beq niw_frame_done

	#TODO:  Add the 'metal suppression' flag to the player.
	lbz r10, 15(r5)
	ori r10, r10, 0x01
	stb r10, 15(r5)
	
	#load the slot value from the source player.  We'll need this so that
	#scores are applied properly.
	lbz r10, 0xC(r5)

	#load r8 and walk it back to the beginning of the player list.
	mr r8, r7
niw_frame_chain_back_loop:
	lwz r9, 0x14(r8)
	cmpwi r9, 0
	beq niw_frame_chain_back_done
	mr r8, r9
	b niw_frame_chain_back_loop
niw_frame_chain_back_done:

	#ok.  r7 has the player we exclude.  r8 has the first player.
	#make them hurty.
	

niw_hurty_loop:

	cmpw r7, r8
	beq niw_hurty_skip
	
	lwz r5, 44(r8)
	lwz r9, 44(r7)

	#player + 0xE0 is zero when they're on the ground, 1 when in the
	# air.  POW is only supposed to affect people on the ground, so if
	# this is != 0, continue the search.
	lwz r3, 0xE0(r5)
	cmpwi r3, 0
	bne niw_hurty_skip

	#need to compute which way they should fly
	lfs f0, 0xB0(r5)
	lfs f1, 0xB0(r9)
	fsub f0, f0, f1
	stfs f0, 8(r1)
	lwz r3, 8(r1)
	andis. r3, r3, 0x8000
	
	lis r6, 0x3F80
	or r6, r6, r3

	stw r6, 0x1844(r5)

	#lis r6, 0x3C
	li r6, 0x57
	stw r6, 0x1848(r5)

	lis r6, 0
	stw r6, 0x184C(r5)
	stw r6, 0x1854(r5)
	stw r6, 0x1858(r5)
	stw r6, 0x185C(r5)
	stw r6, 0x1860(r5)
	stw r6, 0x1864(r5)
	stw r6, 0x186C(r5)

	#we want r6 to be 175 when damage is zero, and 250 when damage is 100

	#f0 = 175.0
	lis r6, 0x432F
	stw r6, 8(r1)
	lfs f0, 8(r1)

	#f1 = 0.75 (75 / 100, to save us having to load 100 somewhere.)
	lis r6, 0x3F40
	stw r6, 8(r1)
	lfs f1, 8(r1)

	#f2 = health
	lfs f2, 0x1830(r5)

	#f1 = f2 * f1
	fmul f1, f2, f1
	#f0 = f0 + f1
	fadd f0, f0, f1

	stfs f0, 0x1850(r5)

	#this will actually damage them
	lis r6, 0x4248
	stw r6, 0x1838(r5)
	#lis r6, 50
	#stw r6, 0x183C(r5)

	stw r7, 0x1868(r5)

	stw r10, 0x18C4(r5)

niw_hurty_skip:

	lwz r8, 0x10(r8)
	cmpwi r8, 0
	bne niw_hurty_loop





niw_frame_done:

	lwz r0, 16(r1)
	addi r1, r1, 12
	mtlr r0

	blr


#we replace the blr for this function
#8026C888:  4E800020	blr	
niw_ChooseRandomItem_hook:

	#an item is going to be spawned.
	#see if POW is enabled in item swap
	#if so, and if randomness allows, 
	#8046DB80 + 8 is our address.

	lis r4, 0x8046
	ori r4, r4, 0xDB80

	lwz r6, 8(r4)
	andi. r6, r6, 0x8
	beq niw_ChooseRandomItem_done

	#enabled.  Calc a new random number
	lis r4, 0x8000
	lwz r5, 0x2308(r4)
	mulli r5, r5, 16807
	#clear the sign bit.  Conveniently, we can use r4 again
	andc r5, r5, r4
	stw r5, 0x2308(r4)

	#r6 = (r5 >> 8) & 0x7F;
	rlwinm r6, r5, 24, 25, 31

	lwz r5, (niw_pow_randomfactor - StartOfMemory)(r4)
	cmpw r6, r5
	# if the random value is > the flag, do nothing.
	# means that the odds of getting a box can vary from 1/128 to 128/128
	bgt niw_ChooseRandomItem_done

	#ok, change that bitch!
	lis r3, 0xF9
	ori r3, r3, 0x20

niw_ChooseRandomItem_done:
	blr







# SetColorRoutine.  Replaces one of the phys functions.  I'm not convinced
#this won't have to get longer in the future.
niw_set_color_routine:
	lwz r5, 44(r3)
	li r6, 0

	li r0, 20
	mtctr r0

	addi r8, r5, 0x548
	li r6, 0

niw_zero_loop:
	stw r6, 0(r8)
	addi r8, r8, 4
	bdnz niw_zero_loop
	

	lis r6, 0x432F
	stw r6, 0x578(r5)
	lis r6, 0x4348
	stw r6, 0x584(r5)
	lis r6, 0x8000
	stw r6, 0x5c4(r5)

	li r3, 0

	blr


#.org 0x1B10
#
#	lis r3, 0x8000
#	lwz r4, (niw_dospecial - StartOfMemory)(r3)
#	li r5, 1
#	xor r4, r5, r4
#	stw r4, (niw_dospecial - StartOfMemory)(r3)
#
#	blr

.org 0x1D0C
#r3 and r4 and possibly r0 must be preserved
niw_CheckMetalSuppression:

	#so r3 is a player_t
	lwz r6, 44(r3)
	lbz r5, 15(r6)
	andi. r7, r5, 0x01
	beq niw_CheckMetalSuppression_done

	#toggle.  Since we know it's on, turns it off.
	xori r5, r5, 0x01
	stb r5, 15(r6)

	#we're blocking the function from executing, so just return.
	#lr still has the right address in it at this point.
	blr

niw_CheckMetalSuppression_done:

	#do the instruction we replaced
	stw r0,4(r1)
	b niw_ApplyMetal_back

.org 0x1D30
niw_SpawnEntity_Hook:
	lwz r10, 8(r3)
	rlwinm r0, r10, 16, 24, 28
	cmpwi r0, 0xF8
	bne niw_SpawnEntity_done
	
	#ok, so now, in theory, the item code is of the form
	#0x00Fx00xx
	#we want to take x & 0x7 and store it in niw_dospecial, then clear the
	#high bits of the value.

	rlwinm r0, r10, 16, 29, 31
	lis r9, 0x8000
	stw r0, (niw_dospecial - StartOfMemory)(r9)

	rlwinm r10, r10, 0, 16, 31
	stw r10, 8(r3)

niw_SpawnEntity_done:
	mflr r0
	b niw_SpawnEntity_back


.org 0x1D5C
#this is our source address.
#802679BC:  901F00B8	stw	r0,184(r31)
#r3 available, r5, r6, pretty much all but r0
niw_hookbegin:
	lis r3, 0x8000
	lwz r6, (niw_dospecial - StartOfMemory)(r3)
	cmpwi r6, 0
	beq niw_act_normally
#act abnormally
	#first, set the value back to 0
	lis r6, 0
	stw r6, (niw_dospecial - StartOfMemory)(r3)

	#now store the modified action table in the item.
	lis r3, (((niw_hacktable - StartOfMemory) + 0x80000000) >> 16) & 0xFFFF
	ori r3, r3, ((niw_hacktable - StartOfMemory) & 0xFFFF)
	stw r3, 184(r31)

	b niw_hook_return
niw_act_normally:
	#just do the instruction we replaced with a branch and continue.
	stw r0, 184(r31)
	b niw_hook_return



.org 0x1D8C
niw_hacktable:
.long (niw_other_table - StartOfMemory) + 0x80000000
.long 0x802953c8
.long ZERO
.long (niw_frame_chain - StartOfMemory) + 0x80000000  #0x80295524
.long ZERO #0x80295554
.long ZERO
.long ZERO
.long ZERO
.long ZERO #0x80295684
.long ZERO
.long ZERO
.long ZERO
.long ZERO
.long ZERO
.long ZERO #0x802956EC

niw_other_table:
.long 0xFFFFFFFF
.long 0x8029544C
#.long (niw_set_color_routine - StartOfMemory) + 0x80000000
.long 0x80295454
.long 0x80295458
.long 0xFFFFFFFF
#.long 0x802954C0
.long (niw_set_color_routine - StartOfMemory) + 0x80000000
.long 0x802954C8
.long 0x802954F8
.long 0xFFFFFFFF
.long 0x8029554C
.long ZERO
.long ZERO



#replacing blr of SPawnENtity with this, because the flag needs to be
#cleared.  If there are a lot of items, the function may return without
#spawning anything, and then the flag will be left set which is bad.
.org 0x1DF8
niw_SpawnEntity_clear:
	lis r4, 0x8000
	li r5, 0
	stw r5, (niw_dospecial - StartOfMemory)(r4)
	blr

.org 0x1E08
#the end of the allocate and init player function is ours for the hooking!
#we're now making use of the 24 bits located after the byte that specifies
#the player slot.
# 800693A8:  4E800020	blr	
niw_Aaip_hook:
	lwz r4, 44(r3)
	li r5, 0xDD
	stb r5, 13(r4)
	li r5, 0
	sth r5, 14(r4)
	blr
#make sure this code doesn't extend over to 0x1E20, which is already in use
.org 0x1E20


.org 0x2ED0


















.org 0x693A8
	b niw_Aaip_hook


#hooking this instruction:
#8006CA70 7C7E1B78	mr	r30,r3
#.org 0x6CA70
#	bl niw_PlayerFrameChain_hook


#ApplyMetalItem:
#800871AC:  90010004	stw	r0,4(r1)
.org 0x871AC
	b niw_CheckMetalSuppression
niw_ApplyMetal_back:
	
.org 0x2679BC
	b niw_hookbegin
niw_hook_return:

.org 0x268B18
	b niw_SpawnEntity_Hook
niw_SpawnEntity_back:

#80268B58 4E800020	blr	
.org 0x268B58
	b niw_SpawnEntity_clear


.org 0x26C888
	b niw_ChooseRandomItem_hook

.endif






.if INVISIBLE_PLAYERS

#switch this to lmw
#80069390:  83E10044	lwz	r31,68(r1)
#80069394:  83C10040	lwz	r30,64(r1)
#80069398:  83A1003C	lwz	r29,60(r1)
#8006939C:  83810038	lwz	r28,56(r1)

.org 0x2114
invis_more_code:
	andi. r28, r28, 0x08
	beq invis_more_return
	li r28, 0
	stw r28, 0x1C(r3)
invis_more_return:
	b invis_back_code

.org 0x69390
	lis r28, 0x8000
	lwz r28, 0x2054(r28)
	b invis_more_code
invis_back_code:
	lmw r28, 56(r1)
	

.endif


.if INVISIBLE_ITEMS

#replacing 80268B48:  8001001C	lwz	r0,28(r1) with branch
#r31 also open for use.

.org 0x1e20
invitem_go:
	lwz r0, 28(r1)
	lis r31, 0x8000
	lwz r31, 0x2054(r31)
	andi. r31, r31, 0x10
	beq invitem_noact
	li r31, 0

	#oops--item can be NULL if it's set to LikeRain
	cmpwi r3, 0
	beq invitem_noact
	stw r31, 0x1C(r3)
invitem_noact:
	b invitem_back

.org 0x268B48
	b invitem_go
invitem_back:

.endif


.if MUSH_DEADLY

.org 0x2050
	.word 0
	.word 0
	.word 0
	.word 0xF

.org 0x2058
deadly_mush_big:
	li r8, 0x1
	b deadly_mush_go
deadly_mush_small:
	li r8, 0x2
deadly_mush_go:
	lis r9, 0x8000
	lwz r9, 0x2054(r9)
	and. r9, r9, r8
	beq deadly_mush_no_hook
deadly_mush_hook:
	mtlr r0
	b PlayerKillFunction
deadly_mush_no_hook:
	stw r0, 4(r1)
	blr

.org 0xD1710
	bl deadly_mush_big
.org 0xD18D0
	bl deadly_mush_big
.org 0xD2000
	bl deadly_mush_small
.org 0xD21C0
	bl deadly_mush_small

.org 0xD40B8
PlayerKillFunction:


.endif

.if INF_JUMP_TOGGLE

.org 0x2020
inf_jump_hook_r31:
	mr r6, r31
	b inf_jmp_hook
inf_jump_hook_r30:
	mr r6, r30
	b inf_jmp_hook
inf_jump_hook_r29:
	mr r6, r29
	b inf_jmp_hook
inf_jump_hook_r28:
	mr r6, r28
inf_jmp_hook:
	lis r5, 0x8000
	lwz r5, 0x201C(r5)
	cmpwi r5, 0
	bne inf_jump_do_nothing
	stb r0,6504(r6)
inf_jump_do_nothing:
	blr


.org 0xCBB48
	bl inf_jump_hook_r31
.org 0xCBC98
	bl inf_jump_hook_r31
.org 0xCBE00
	bl inf_jump_hook_r29
.org 0xCBF38
	bl inf_jump_hook_r28
.org 0xCC1B0
	bl inf_jump_hook_r30
.org 0xCC300
	bl inf_jump_hook_r30


.endif
	


.if MUSH_STACK_TOGGLE

.org 0x2004
mush_hook_func:
	lis r3, 0x8000
	lwz r3, 0x2000(r3)
	cmpwi r3, 0
	bne mush_do_nothing
	#it's equal to zero, i.e. no stacking, so store the flag
	stb	r0,8736(r31)
mush_do_nothing:
	blr



.org 0xD15FC
	bl mush_hook_func

.org 0xD1F98
	bl mush_hook_func


.endif
	


.if FUN_WITH_PHYS

.org	0x2F04

phys_hook:
	lis r7, 0x8000
	ori r7, r7, 0x2F00
	lwz r7, 0(r7)
	cmpwi r7, 0x99
	beq phys_no_change
	mr r3, r7
phys_no_change:
	mflr r0
	b phys_resume_operation

.org 0x43754
	b phys_hook
.org 0x43758
phys_resume_operation:

.endif
	

.if ONE_HIT_KILL_TWO

.org 0x20D0

ohkt_begin:

	lis r7, 0x8000
	lwz r7, 0x2054(r7)
	andi. r7, r7, 0x04
	beq ohkt_nothing_deadly

	lis r7, 0x8045
	ori r7, r7, 0x3080

	lwz r8, 44(r3)
	lbz r6, 12(r8)
	mulli r6, r6, 0xE90
	add r7, r7, r6
	
	lhz r5, 0x60(r7)
	lhz r6, 0x62(r7)

	cmpw r5, r6
	ble ohkt_nothing_deadly

	b oht_KillBottom

ohkt_nothing_deadly:
	mflr r0
	b ohkt_normal_return




.org 0x6a360
ohkt_start_hook:
	b ohkt_begin
ohkt_normal_return:


.org 0xD3BC8
oht_KillBottom:
	
.endif	



.if ONE_HIT_KILL_NOCRASH

.org 0x2F00

ohk_startofcode:
	cmpwi r4, 4
	beq ohk_do_return
	mr r3, r29
	b ohk_back
ohk_do_return:
	b ohk_do_return_loc


#800732F0:  7FA3EB78	mr	r3,r29

.org 0x732F0
ohk_origloc:
	b ohk_startofcode
ohk_back:

.org 0x73338
ohk_do_return_loc:

.endif

.if CHARACTER_MOVE_SWAP

.org 0x2F04

	lbz r7, 108(r3)
	mulli r7, r7, 68
	lis r6, 0x804C
	ori r6, r6, 0x1FAC
	lwzx r5, r6, r7
	cmpwi r5, 8
	bne cms_back_to_code

	#ok.  This player is pressing d-pad up
	lwz r6, 16(r3)
	cmpwi r6, 0
	beq cms_back_to_code

	lwz r7, 128(r6)
	stw r7, 128(r3)
	lwz r7, 132(r6)
	stw r7, 132(r3)

cms_back_to_code:
	mflr r0
	b cms_original_code

.org 0x6A364
	cms_original_code:
	
.endif	


.if EXPLOIT_DOL_LOAD

.org 0x0000

	lis r23, 0xAAAA
	ori r23, r23, 0xBBBB
	lis r4, 0xCCCC
	ori r4, r4, 0xDDDD
	mtlr r23
	blr

.endif

.if MULTI_CRAZY_SIZE

.org 0x20A4

multi_crazy_fix:
	lwz r3, 28(r31)
	cmpwi r3, 0
	lfs f1, 28(r31)
	bne nothing_to_do
	lis r3, 0x3F80
	ori r3, r3, 0
	stw r3, 28(r31)
	stw r3, 24(r31)
	stw r3, 20(r31)
	lfs f1, 28(r31)
nothing_to_do:
	b back_to_code

.org 0x16A798
	b multi_crazy_fix
back_to_code:

.endif





.if BUFFER_EXPLOIT

.org 0x3130
my_memset:

.org 0x1CBBC  
DoLoadData:

.org 0x1A428C
new_major:

.org 0x1A42A0
new_minor:

.org 0x1A4B60
set_go:



.org 0x239E9C
alls_well:



.org 0x45D974
	lis r3, 0xAAAA
	ori r3, r3, 0xBBBB
	li r4, 0
	lis r5, 0
	ori r5, r5, 0x7EEE
	bl my_memset
	#now the array data is cleared.  Clear the original area
	lis r3, 0xFFFF
	ori r3, r3, 0xEEEE
	li r4, 0
	stw r4, 0(r3)
	stw r4, 4(r3)
	stw r4, 8(r3)
	#ok.  Should be all we need.
	bl DoLoadData
	li r3, 6
	bl new_major
	bl set_go
	b alls_well


.endif

.if CLONE_WARS_3

#this clone wars is the code used by the doppleganger debug menu

.org 0x2f18
	stw	r3,176(r30)

	#see if we're even doppling this player
	lbz r4, 40(r1)
	mulli r4, r4, 4

	lis r5, 0x8000
	ori r5, r5, 0x2F00

	lwzx r27, r5, r4

	#r27 now has the player's dopple count
	#we can use r27, amazingly enough

	cmpwi r27, 0
	beq clone_wars_out

	#mark them as a nana
	li r3, 0x80
	stb r3, 42(r1)

clone_wars_loop:

	addi r3, r1, 36
	bl SpawnNewPlayer

	stw r3, 180(r30) #store this one in the player block as nana.
	#an actual nana will overwrite this value, which is what we want.

	addi r27, r27, -1
	cmpwi r27, 0
	bgt clone_wars_loop #bgt just in case it goes negative

clone_wars_out:
	b back_to_code

.org 0x31BD0
back_to_code:

.org 0x68e98
SpawnNewPlayer:

.endif




.if CLONE_WARS_2

#this clone wars is the code used by the doppleganger debug menu

.org 0x1E48
	stw	r3,176(r30)

	#see if we're even doppling this player
	lbz r4, 40(r1)
	mulli r4, r4, 4

	lis r5, 0x8000
	ori r5, r5, 0x1E8C

	lwzx r27, r5, r4

	#r6 now has the player's dopple count
	#we can use r27, amazingly enough

	cmpwi r27, 0
	beq clone_wars_out

	#mark them as a nana
	li r3, 0x80
	stb r3, 42(r1)

clone_wars_loop:

	addi r3, r1, 36
	bl SpawnNewPlayer

	stw r3, 180(r30) #store this one in the player block as nana.
	#an actual nana will overwrite this value, which is what we want.

	addi r27, r27, -1
	cmpwi r27, 0
	bgt clone_wars_loop #bgt just in case it goes negative

clone_wars_out:
	b back_to_code

.org 0x31BD0
back_to_code:

.org 0x68e98
SpawnNewPlayer:

.endif





.if CLONE_WARS

.org 0x2F00
	stw	r3,176(r30)

	#mark them as a nana
	li r3, 0x80
	stb r3, 42(r1)

	addi r3, r1, 36
	bl SpawnNewPlayer

	stw r3, 180(r30) #store this one in the player block as nana.

#	li r27, 0x4387

	addi r3, r1, 36
	bl SpawnNewPlayer
	addi r3, r1, 36
	bl SpawnNewPlayer
	b back_to_code

.org 0x31BD0
back_to_code:

.org 0x68e98
SpawnNewPlayer:

.endif

######################################################################
# Item duration funcs

.if ITEM_DURATION_FUNCS
.org 0x1eA4

starman:
	lis r4, 0x8000
	ori r4, r4, 0x27F4
	lwz r4, 0(r4)
	blr	

mushroom:
	lis r9, 0x8000
	ori r9, r9, 0x27F8
	lwz r0, 0(r9)
	blr

bunnyhood:
	lis r9, 0x8000
	ori r9, r9, 0x27FC
	lwz r0, 0(r9)
	blr

metalbox:
	lis r4, 0x8000
	ori r4, r4, 0x2800
	lwz r4, 0(r4)
	blr

cloaking:
	lis r4, 0x8000
	ori r4, r4, 0x2804
	lwz r4, 0(r4)
	blr

hammer:
	lis r9, 0x8000
	ori r9, r9, 0x2808
	lwz r0, 0(r9)
	blr



.endif

.if DPAD_CPUSET
.org 0x1b10

	lis r3, 0x8045
	ori r3, r3, 0x3088

	mulli r5, r5, 0xE90

	add r3, r3, r5

	lwz r6, 0(r3)

	cmpwi r6, 1
	bne not_one
	li r6, 0
	b not_zero  #otherwise you can't revert to human.
not_one:
	cmpwi r6, 0
	bne not_zero
	li r6, 1
not_zero:

	stw r6, 0(r3)

	blr

.endif

.if DPAD_TESTBED

.org 0x1b10

	mflr r0
	stw r0, 4(r1)
	stwu r1, -16(r1)
	stw r31, 8(r1)
	stw r30, 12(r1)

	mr r31, r3

	lwz r3, 44(r3)
	li r4, 0x258

	bl ApplyStarman

/* 	
	li r3, 0x1F
	bl QuickSpawnItem
	cmpwi r3, 0
	beq end_of_quickiefunc

	mr r30, r3  #r30 has item, r31 has player

	mr r4, r3
	mr r3, r31
	#bl ApplyInstantItem
	bl GiveItemToPlayer
	#bl ApplyMetalBoxItem

	mr r3, r31
	mr r4, r30
	bl ApplyInstantItem

	#mr r3, r31
	#bl UpdatePlayerFieldsDoodad
*/
end_of_quickiefunc:
	li r3, 1
	lwz r0, 20(r1)
	lwz r30, 12(r1)
	lwz r31, 8(r1)
	addi r1, r1, 16
	mtlr r0
	blr

/*
QuickSpawnItem:
	mflr r0
	stw r0, 4(r1)
	stwu r1, -104(r1)
	stw r31, 8(r1)

	mr r31, r3 #save the param

	# first zero out the range
	addi r3, r1, 16
	li r4, 0
	li r5, 0x54
	bl memset

	addi r3, r1, 16

	stw r31, 8(r3)
	lis r4, 0x3F80
	stw r4, 0x38(r3)

	lis r4, 0x8000
	stw r4, 0x44(r3)

	li r4, 1

	bl SpawnEntity

	lwz r0, 108(r1)
	lwz r31, 8(r1)
	addi r1, r1, 104
	mtlr r0
	blr
*/
	

.org 0x3130
memset:

.org 0x6F238
UpdatePlayerFieldsDoodad:

.org 0x7B7FC
ApplyStarman:

.org 0x7FA58
ApplyBunnyHood:

.org 0x871A8
ApplyMetalBoxItem:

.org 0x9447C
ApplyInstantItem:

.org 0x948A8
GiveItemToPlayer:

.org 0x268B18
SpawnEntity:

.org 0x26A8EC
DestroyItem:


.endif

.if DPAD_MOVES_BLOCK

.org 0x1B10
	blr


.org 0x2A00


###################################################
#    handle_extra_dpad
###################################################
#root function to handle stuff
	mflr r0
	stw r0, 4(r1)

	stwu r1, -60(r1)
	#save some regs
	stmw r26, 8(r1)
#	stw r31, 28(r1)		#the index passed in
#	stw r30, 24(r1)		#address of variable block
#	stw r29, 20(r1)		#heart's timer
#	stw r28, 16(r1)		#function address to call
#	stw r27, 12(r1)		#call flags
#	stw r26, 8(r1)		#result of PlayerFromIndex()
	

	#save parameter
	mr r31, r3

	lis r30, 0x8000
	ori r30, r30, 0x2810


	#first, check the delay.  get heart timer from r6
	lis r6, 0x8047
	ori r6, r6, 0x9D30
	lwz r6, 40(r6)

	#load current timer for the player
	#take player index, multiply by 4, then add to variable block.
	#then load player 0's delay, which will be offset properly
	mulli r7, r31, 4
	add r9, r30, r7
	lwz r7, 40(r9)

	cmpw r6, r7
	blt d_pad_stuff_done

	#ok, we're good.  Save the heart timer for later
	mr r29, r6

	#now, call PlayerFromIndex
	mr r3, r31
	bl PlayerFromIndex
	cmpwi r3, 0  #if null, do nothing
	beq d_pad_stuff_done

	mr r26, r3 #save player for later

	#now see if they are actually pressing a button combo
	mr r3, r26
	bl check_button_combo

	#not pressing a combo; exit
	cmpwi r3, -1
	beq d_pad_stuff_done

	#ok.  They pressed a combo, it's go time.

	#load the function address
	subi r3, r3, 1
	mulli r3, r3, 4

	#load r4 with the function table address (NOTE:  it is NOT r30)
	lis r4, ((func_table - StartOfMemory) >> 16) + 0x8000
	ori r4, r4, (func_table - StartOfMemory) & 0xFFFF

	#load the function to run from the configurables
	lwzx r8, r30, r3

	#r8 now has an index into the r4 table.
	mulli r8, r8, 4
	lwzx r8, r4, r8

	#null check!
	cmpwi r8, 0
	beq d_pad_stuff_done

	#check for nodamage or nodelay flag.  It's stored in the
	#address
	li r27, 0
	rlwimi r27, r8, 4, 29, 31
	lis r9, 0x8FFF
	ori r9, r9, 0xFFFF
	and r28, r8, r9

	#r28 now holds the real function address.


	#damage them the perscribed amount if we're doing that
	andi. r5, r27, 1 #flag 1 means "don't damage"
	bne skip_damage

	lis r6, 0x8000
	lwz r6, 0x2054(r6)
	andi. r6, r6, 0x20
	beq normal_damage

	#they specified coin damage.  This means that if they don't have the
	#coins, we aren't going to let them have what they wanted.
	lis r6, 0x8045
	ori r6, r6, 0x3080
	mulli r7, r31, 0xE90
	add r6, r6, r7

	#r6 now has the static player block for this player.
	#but yay, we have to convert a damn float to get the damage.
	lfs f0, 32(r30)
	fctiwz f1, f0
	stfd f1, 40(r1)
	#bloody hell.
	lwz r7, 44(r1)

	lwz r8, 0x90(r6)
	cmpw r8, r7
	blt d_pad_stuff_done
	subf r8, r7, r8  #who the fuck defined this opcode?
	stw r8, 0x90(r6)

	b skip_damage
	

normal_damage:
	mr r3, r31
	lwz r4, 32(r30)
	bl apply_damage

skip_damage:
	andi. r5, r27, 2 #flag 2 means "don't do the time thing"
	bne skip_delay

	#if they got here, something was done, so increment their timer
	lhz r7, 38(r30)  #get the time interval
	add r8, r7, r29   #add it to the heart counter, saved in r29
	mulli r9, r31, 4
	add r9, r30, r9
	stw r8, 40(r9)  #store it 

skip_delay:

	andi. r5, r27, 4 #flag 4 means "give them this item"
	beq skip_generic_item #note that this is opposite logic from the other flags

	#move the low byte of r8 to r6, then load r8 with the
	#"generic give item" function.
	#andi. r6, r28, 0xFF
	rlwinm r6, r28, 0, 24, 31
	rlwimi r6, r28, 0, 8, 15
	rlwimi r7, r28, 24, 24, 31
	lis r28, ((GenericGiveItem - StartOfMemory) >> 16) + 0x8000
	ori r28, r28, (GenericGiveItem - StartOfMemory) & 0xFFFF
skip_generic_item:

	#note: r6 and r7 MUST BE PRESERVED from generic_item stuff above to the
	#blrl below.  If you insert more flags test for them BEFORE 
	#generic_item

	#make the call.
	mtlr r28
	mr r3, r26
	lhz r4, 36(r30)
	mr r5, r31
	blrl


d_pad_stuff_done:
	#restore regs and return
	#note: restoring the parameter is important, otherwise the function we
	#hooked will get garbage for its parameter
	mr r3, r31

	lmw r26, 8(r1)
#	lwz r26, 8(r1)
#	lwz r27, 12(r1)
#	lwz r28, 16(r1)
#	lwz r29, 20(r1)
#	lwz r30, 24(r1)
#	lwz r31, 28(r1)
	lwz r0, 64(r1)
	addi r1, r1, 60
	mtlr r0
	b BackToGameCode


###################################################
#    check_button_combo
###################################################
#check_button_combo, r3 = player index
#returns an index, or -1 if no combo pressed
check_button_combo:
	lwz r3, 44(r3)
	lwz r4, 0x65C(r3)
	lwz r5, 0x668(r3)

	#mulli r3, r3, 68
	#lis r4, 0x804C
	#ori r4, r4, 0x1FAC
	#add r4, r3, r4

	#r5 holds the instant buttons, r4 holds the constant ones
	#lwz r5, 8(r4)
	#lwz r4, 0(r4)

	# if nothing pressed, 2, if R pressed, 1, if L pressed, 0
	li r8, 2
	#check for r or l
	andi. r6, r4, 0x40  #L button
	bne l_pressed
	andi. r6, r4, 0x20  #R button
	bne r_pressed
	subi r8, r8, 1
r_pressed:
	subi r8, r8, 1
l_pressed:
	#do nothing


	#left = 0, right = 1, down=2	
	li r9, 2
	andi. r6, r5, 1 #left
	bne dleft_pressed
	andi. r6, r5, 2 #right
	bne dright_pressed
	andi. r6, r5, 4 #down
	bne ddown_pressed

	#ok.  Not pressing any d-pad we care about; return -1
	li r3, -1
	b end_of_check_func

dleft_pressed:
	subi r9, r9, 1
dright_pressed:
	subi r9, r9, 1
ddown_pressed:
	#nothing.

	mulli r3, r8, 3
	#now r3 is 0, 3, or 6
	add r3, r3, r9

end_of_check_func:
	blr	

###################################################
#    apply_damage
###################################################
#apply_damage, r3=player index, r4=damage to apply (float)
#uses r6, r7
apply_damage:
	mflr r0
	stw r0, 4(r1)
	stwu r1, -16(r1)

	# how the hell am i /supposed/ to be doing this conversion?
	stw r4, 8(r1)

	bl PlayerFromIndex

	#check and make sure it's not NULL
	cmpwi r3, 0
	beq nothing_to_do

	#load the minor player struct from it
	lwz r3, 44(r3)	
	
	lfs f1, 8(r1)

	bl ApplyDamageToPlayer

nothing_to_do:
	lwz r0, 20(r1)
	addi r1, r1, 16
	mtlr r0
	blr

###################################################
#    clear_all_status
###################################################

#Function to clear all status elements.
#r3 is the player main block
clear_all_status:
	lwz r3, 44(r3)	
	
	#all we do is write 1 to all of the "time left" areas
	#(write 1, not 0; some of the functions decrement before they test)
	li r4, 1

	stw r4, 0x2028(r3)
	stw r4, 0x2004(r3)
	stw r4, 0x2030(r3)
	stw r4, 0x2014(r3)
	stw r4, 0x2008(r3)
	stw r4, 0x2330(r3) #hammer
	stw r4, 0x2000(r3) #lipstick flower

	li r3, 0

	blr

###################################################
#    give_starman
###################################################

give_starman:
	mflr r0
	stw r0, 4(r1)
	stwu r1, -16(r1)

	lwz r3, 44(r3)
	li r4, 0x258
	bl ApplyStarman

	lwz r0, 20(r1)
	addi r1, r1, 16
	mtlr r0
	blr

###################################################
#    give_small_mushroom
###################################################

give_small_mushroom:
	mflr r0
	stw r0, 4(r1)
	stwu r1, -16(r1)

	bl SmallMushroom

	#todo: figure out how to honor the duration parameter

	lwz r0, 20(r1)
	addi r1, r1, 16
	mtlr r0
	blr

###################################################
#    give_big_mushroom
###################################################

give_big_mushroom:
	mflr r0
	stw r0, 4(r1)
	stwu r1, -16(r1)

	bl BigMushroom

	#todo: figure out how to honor the duration parameter

	lwz r0, 20(r1)
	addi r1, r1, 16
	mtlr r0
	blr

.if 0
#don't need this anymore
###################################################
#    GiveGenericInstantItem
###################################################

GenericGiveInstantItem:
	mflr r0
	stw r0, 4(r1)
	stwu r1, -16(r1)
	stw r31, 8(r1)

	mr r31, r3

	mr r3, r6
	bl QuickSpawnItem
	cmpwi r3, 0
	beq end_of_GiveInstItem

	mr r4, r3
	mr r3, r31
	bl ApplyInstantItem

end_of_GiveInstItem:
	li r3, 1
	lwz r0, 20(r1)
	lwz r31, 8(r1)
	addi r1, r1, 16
	mtlr r0
	blr


give_metal_box:
	li r6, 0x20
	b GenericGiveInstantItem

give_bunny_hood:
	li r6, 0x1F
	b GenericGiveInstantItem

give_cloaking:
	li r6, 0x21
	b GenericGiveInstantItem
.endif

###################################################
#    GenericGiveItem
###################################################

GenericGiveItem:
	mflr r0
	stw r0, 4(r1)
	stwu r1, -20(r1)
	stw r31, 8(r1)
	stw r30, 12(r1)
	stw r29, 16(r1)

	mr r31, r3
	mr r30, r7

	#check to make sure they don't already have an item in hand.
	#ODD things happen if you double give an item.
	lwz r3, 44(r3)
	lwz r3, 0x1974(r3)
	cmpwi r3, 0
	bne end_of_GenericGiveItem

	#r6 has the item code
	mr r3, r6
	bl QuickSpawnItem
	cmpwi r3, 0
	beq end_of_GenericGiveItem

	mr r29, r3

	mr r4, r3
	mr r3, r31
	bl GiveItemToPlayer

	#if r7 was zero, we're done
	cmpwi r30, 0
	beq end_of_GenericGiveItem

	#if it wasn't, call ApplyInstantItem to activate the item they got
	mr r3, r31
	mr r4, r29
	bl ApplyInstantItem

end_of_GenericGiveItem:
	lwz r0, 24(r1)
	lwz r31, 8(r1)
	lwz r30, 12(r1)
	lwz r29, 16(r1)
	addi r1, r1, 20
	mtlr r0
	blr

###################################################
#    QuickSpawnItem
###################################################

QuickSpawnItem:
	mflr r0
	stw r0, 4(r1)
	stwu r1, -104(r1)
	stw r31, 8(r1)

	mr r31, r3 #save the param

	# first zero out the range
	addi r3, r1, 16
	li r4, 0
	li r5, 0x54
	bl memset

	addi r3, r1, 16

	stw r31, 8(r3)
	lis r4, 0x3F80
	stw r4, 0x38(r3)

	lis r4, 0x8000
	stw r4, 0x44(r3)

	li r4, 1

	bl SpawnEntity

	lwz r0, 108(r1)
	lwz r31, 8(r1)
	addi r1, r1, 104
	mtlr r0
	blr

	
###################################################
#    ToggleComputer
###################################################
ToggleComputer:
	lis r3, 0x8045
	ori r3, r3, 0x3088

	mulli r5, r5, 0xE90

	add r3, r3, r5

	lwz r6, 0(r3)

	cmpwi r6, 1
	bne not_one
	li r6, 0
	b not_zero  #otherwise you can't revert to human.
not_one:
	cmpwi r6, 0
	bne not_zero
	li r6, 1
not_zero:

	stw r6, 0(r3)

	blr

ToggleComputer0:
	li r5, 0
	b ToggleComputer

ToggleComputer1:
	li r5, 1
	b ToggleComputer

ToggleComputer2:
	li r5, 2
	b ToggleComputer

ToggleComputer3:
	li r5, 3
	b ToggleComputer

#do nothing function

###################################################
#    DpadFuncDoNothing
###################################################
DpadFuncDoNothing:
	blr

DpadBecomeInvisible:
	li r6, 0
	stw r6, 0x1C(r3)
	blr

DpadBecomeVisible:
	lis r6, 0x8008
	ori r6, r6, 0x0E18
	stw r6, 0x1C(r3)
	blr


#these functions receive:
# r3: player block
# r4: desired duration of effect
# r5: player index
# r6: item code (GenericGiveItem only)
# r7: whether to call ApplyInstantItem (GenericGiveItem only)

func_table:
#0-3
.long ZERO
.long DpadFuncDoNothing - StartOfMemory + 0x90000000
.long 0x80001B10
.long ToggleComputer - StartOfMemory + 0xB0000000
#4-7
.long DpadBecomeVisible - StartOfMemory + 0x80000000
.long DpadBecomeInvisible - StartOfMemory + 0x80000000
.long 0x40000006
.long 0x40000007
#8-11
.long 0x4000001A #normally heart, now "big mush in hand"
.long 0x4000001B #normally tomato(?), now "small mush in hand"
.long give_starman - StartOfMemory + 0x80000000
.long 0x4000000B
#12-15
.long 0x4000000C
.long 0x4000000D
.long 0x4000000E
.long 0x4000000F
#16-19
.long 0x40000010
.long 0x40000011
.long 0x40F90020 #was food, now POW block
.long 0x40000013
#20-23
.long 0x40000014
.long 0x40000015
.long 0x40000016
.long 0x40000017
#24-27
.long 0x40000018
.long 0x40000019
.long give_big_mushroom - StartOfMemory + 0x80000000
.long give_small_mushroom - StartOfMemory + 0x80000000
#28-31
.long 0x4000011C
.long 0x4000011D
.long 0x4000001E
.long 0x4000011F
#32-35
.long 0x40000120
.long 0x40000121
.long 0x40000022
.long clear_all_status - StartOfMemory + 0x80000000
#36-39
.long ToggleComputer0 - StartOfMemory + 0xB0000000
.long ToggleComputer1 - StartOfMemory + 0xB0000000
.long ToggleComputer2 - StartOfMemory + 0xB0000000
.long ToggleComputer3 - StartOfMemory + 0xB0000000
#40-43
.long 0x40000028 #hammer head
.long ZERO
.long ZERO
.long ZERO
#end
.long -1


.org 0x3130
memset:

.org 0x34110
PlayerFromIndex:

.org 0x6CC7C
ApplyDamageToPlayer:

.org 0x7B7FC
ApplyStarman:

.org 0x9447C
ApplyInstantItem:

.org 0x948A8
GiveItemToPlayer:

.org 0xC8348
ApplyMetal:

.org 0xD170C
BigMushroom:

.org 0xD1FFC
SmallMushroom:
	
.org 0x2264C8
BackToGameCode:

.org 0x268B18
SpawnEntity:


#not using, as this only affects the score
#	lis r6, 0x8045
#	ori r6, r6, 0x3080
#	mulli r3, r3, 0xE90
#	add r6, r3, r6
#	lhz r7, 96(r6)
#	add r7, r4, r7
#	sth r7, 96(r6)
#	blr

.endif

.if EVERYTHING_ELSE


	li r4, 0
	lis r3, 0x8000
	ori r3, r3, 0x2838
	stw r4, 0(r3)
	stw r4, 4(r3)
	stw r4, 8(r3)
	stw r4, 12(r3)
	nop

	mflr r0
	stw r0, 4(r1)
	stwu r1, -108(r1)

	#can use up to 24(r1) for stuff
	#but DON'T USE 4(r1)!!

	lis r4, 0x8047
	ori r4, r4, 0x9D30

	#memcpy the heart to the stack
	addi r3, r1, 8

	li r5, 0x60

	nop


	li r3, 6

	b do_useful_stuff
done_useful_stuff:

	lis r3, 0x8047
	ori r3, r3, 0x9D30

	addi r4, r1, 8

	li r5, 0x60

	nop

	lwz r0, 112(r1)
	addi r1, r1, 108
	mtlr r0
	blr

do_useful_stuff:
	lis r3, 0x803D
	ori r3, r3, 0xAD08
	lis r4, 0x8047
	ori r4, r4, 0x9D30
	li r5, 0
	stb r5, 3(r4)

	nop
	b done_useful_stuff
	

sync
sync
sync

	lis r3, 0x8000
	ori r3, r3, 0x2848
	lfs f0, 0(r3)
	blr


mr r3, r30
#disable interrupts!
	mfmsr    3
	rlwinm   4,3,0,17,15
	mtmsr    4
	lis r3, 0x8000
	ori r3, r3, 0x522C
	mtlr r3
	li r3, 0
	blrl  #       main # Branch to the user code!
eloop:
	b eloop


#802255A4
	lis	r4, 0x8000
	ori 	r4, r4, 0x19FC
	lwz	r4, 0(r4)
	cmpwi	r4, 0
	bne	pastbranch
	lis	r3, 0  #return 0 if drops not enabled
	blr
pastbranch:
	#first, load the item for this player and stick it in the spot
	lis r4, 0x8000
	ori r4, r4, 0x19F8
	add r4, r3, r4 #add the player index
	lbz r4, 0(r4)
	lis r5, 0x8047 #load one of the heart's timers for randomness
	ori r5, r5, 0x9D58
	lwz r5, 0(r5)

	#move the mask bits to r6 in the low bits
	lis r6, 0  #do we need to do this?
	rlwimi r6, r4, 26, 30, 31
	and r5, r6, r5 #r5 should now have two lowest bits of heart timer

	add r4, r5, r4 #r4 has been increased by a random amount
	andi r4, r4, 0x3F  #mask off the upper bits
	
	lis r5, 0x8049
	ori r5, r5, 0xFAB0
	stw r4, 0(r5)

#ok, now for the item shits test
#see if it's enabled
	lis r4, 0x8000
	ori r4, r4, 0x2850
	lwz r6, 0(r4)
	cmpwi r6, 0
	beq no_auto_drop

#it's enabled, see if they crap
	lis r4, 0x8000
	ori r4, r4, 0x2854
	add r4, r3, r4
	lbz r5, 0(r4)
	subi r5, r5, 1
	stb r5, 0(r4)
	cmpwi r5, 0
	bne do_no_auto_drop  #if it's not zero, do nothing unusual

#if it is zero, return "dpad down" (i.e. they crap)
	stb r6, 0(r4)
	li r3, 0x04 
	blr	

do_no_auto_drop:
	li r3, 0
	blr

no_auto_drop:
	mulli	r0,r3,68
	lis	r3,0x804C
	ori	r3,r3,0x1FAC
	add	r3,r3,r0
	lwz	r3,8(r3)
	blr	

sync
nop
nop
	
#8022558C
	mulli	r4,r3,68
	lis	r3,0x804C
	ori	r0,r3,0x1FAC
	add	r3,r0,r4
	lwz	r3,0(r3)
	blr	

sync



	lbz r3, 241(r30)
	cmpwi r3, 3  #3 is "none" char type
	bne enable_six
	lbz r3, 277(r30)
	cmpwi r3, 3
	bne enable_six
	b six_test_done
enable_six:
	lis r3, 0x8000
	ori r3, r3, 0x2858
	li r4, 1
	stw r4, 0(r3)
six_test_done:
	nop

sync
nop
sync


	lis r3, 0x8000
	ori r3, r3, 0x2858
	lwz r3, 0(r3)
	cmpwi r3, 0
	beq six_scores_off
six_scores_on:
	li r3, 6
	blr
six_scores_off:
	li r3, 4
	blr

#luckily, we can use r4 here, otherwise we'd be screwed
	lis r4, 0x8000
	ori r4, r4, 0x2858
	lwz r4, 0(r4)
	cmpwi r4, 0
	beq no_contest_off
no_contest_on:
	li r0, 7
	blr
no_contest_off:
	lbz r0, 8(r31)
	blr


	lis r3, 0x8000
	ori r3, r3, 0x1FFC
	lwz r3, 0(r3)
	lbz r4, 247(r30)
	add r4, r3, r4
	stb r4, 247(r30)
	lbz r4, 283(r30)
	add r4, r3, r4
	stb r4, 283(r30)
	nop

sync
nop
nop

	
	lwz r0,-27800(r13)
	cmpwi r0, 0
	beq go_time
	nop
go_time:
	stw r13, 24(r1)
	li	r30,0

go_time_loop:
	mr	r3,r30
	bl	0x802264c4
	addi	r30,r30,1
	cmpwi	r30,4
	blt go_time_loop
	lwz r30, 32(r1)
	lwz r13, 24(r1)
	lwz r0, -27800(r13)
	nop




	nop
	sync


	mflr	r0
	stw	r0,4(r1)
	stwu	r1,-8(r1)

	lis r3, 0x8000
	ori r3, r3, 0x285C
	lwz r4, 0(r3)
	cmpwi r4, 1
	bne	skip_doodad
	li	r4, 0
	stw r4, 0(r3)

	lis r3, 0x8048
	ori r3, r3, 0x0820
	lis r4, 0x803F
	ori r4, r4, 0xA268

	lbz r5, -409(r3)
	stw r5, -8(r4)

	li r0, 4
	mtctr r0

skip_loop:

	lbz r5, 0(r3)
	stw r5, 0(r4)
	lbz r5, 1(r3)
	stw r5, 20(r4)
	lbz r5, 15(r3)
	stw r5, 168(r4)

	addi r3, r3, 36
	addi r4, r4, 4

	bdnz skip_loop


skip_doodad:
	li	r3,0
	lwz	r0,12(r1)
	addi	r1,r1,8
	mtlr	r0
	blr	

	sync
	nop



	lis r4, 0x8047
	ori r4, r4, 0x9D30
	li r0, 6
	stb r0, 1(r4)
	li r0, 1
	stb r0, 12(r4)
	stw r0, 52(r4)
	lis r4, 0x8000
	ori r4, r4, 0x285C
	stw r0, 0(r4)
	mflr r0
	nop

	sync
	nop




	lis r4, 0x8047
	ori r4, r4, 0x9D30
	li r0, 6
	stb r0, 1(r4)
	li r0, 1
	stb r0, 12(r4)
	stw r0, 52(r4)
	lis r4, 0x8000
	ori r4, r4, 0x2970
	stw r0, 0(r4)
	lis r4, 0x8000
	ori r4, r4, 0x285C
	stw r0, 0(r4)
	mflr r0
	nop

	sync
	nop





	mflr	r0
	cmpwi	r3,1
	stw	r0,4(r1)
	stwu	r1,-8(r1)
	bne	exit_msc
	li	r3,1
	nop
#	bl	0x80024030
	li	r3,0x2C
	nop
	nop
#	bl	0x801a42f8
#	bl	0x801a4b60
	li r0, 1
	lis r3, 0x8000
	ori r3, r3, 0x285C
	stw r0, 0(r3)
exit_msc:
	li	r3,0
	lwz	r0,12(r1)
	addi	r1,r1,8
	mtlr	r0
	blr	

	nop
	sync


	mflr	r0
	stw	r0,4(r1)
	stwu	r1,-8(r1)
	li	r3,6
	nop #bl	0x801a42e8
	nop #bl	0x801a42d4
	nop #bl	0x801a4b60
	li	r3,0
	lwz	r0,12(r1)
	addi	r1,r1,8
	mtlr	r0
	blr

	nop
	nop
	sync





	


save_sets:
	mflr r6
	lis r0, 0
	cmpwi r3, 1
	bne save_sets_end

	#load r8 with the arrray addy (80001840)
	lis r8, 0x8000
	ori r8, r8, 0x1840

	#load our value into r5
	lis r5, 0x8000
	ori r5, r5, 0x2738
	lwz r5, 0(r5)

	#multiply it by the length of the table, which is 0x48
	mulli r5, r5, -0x48

	lis r7, 0x8000
	ori r7, r7, 0x2EC0

	add r7, r7, r5

	#the branch link goes here
	nop
save_sets_end:
	mtlr r6
	li r3, 0
	blr

	nop
	nop

	lis r5, 0x8000
	ori r5, r5, 0x2080
	lwz r5, 0(r5)
	cmpwi r5, 0
	beq m_stack_off
#m_stack_on:
	lis r7, 0x8000
	ori r7, r7, 0x2084
	lis r8, 0x8000
	ori r8, r8, 0x20A0
	bl m_start
	b mush_stack_end
#m_stack_off:
	lis r7, 0x8000
	ori r7, r7, 0x20B8
	lis r8, 0x8000
	ori r8, r8, 0x20D4
	bl m_start
#mush_stack_end:
	mtlr r0
	blr



# push to patcher
# r7: address of storage block
# r8: address of locations to read from, zero terminated

	subi r7, r7, 4
	subi r8, r8, 4
	lwzu r3, 4(r8) #r3 has address of data to read
push_settings_repeat:
	cmpwi r3, 0
	beq push_settings_out
	lwz r4, 0(r3) #r4 now has data
	stwu r4, 4(r7) #*r7 gets r4
	mr r3, r7

	rlwinm r3,r3,0,0,26 #update the cache... do we need this?
	dcbf r0, r3
	icbi r0, r3
	sync
	isync

	lwzu r3, 4(r8) # reload r3 with next addy
	b push_settings_repeat
push_settings_out:
	blr


# pop data from a store to live
# r7: address of storage block
# r8: address of locations to store to, zero terminated

	subi r7, r7, 4
	subi r8, r8, 4
	lwzu r3, 4(r8) #r3 has address of data to read
pop_settings_repeat:
	cmpwi r3, 0
	beq pop_settings_out
	lwzu r4, 4(r7) #r4 has data from store
	stw r4, 0(r3) #store it at the addy

	rlwinm r3,r3,0,0,26 #update the cache... do we need this?
	dcbf r0, r3
	icbi r0, r3
	sync
	isync

	lwzu r3, 4(r8) # reload r3 with next addy
	b pop_settings_repeat
pop_settings_out:
	blr




file_begin:

	lis r3, 0x8000
	ori r3, r3, 0x269C
	lwz r4, 0(r3)
	lbz r0, 3(r30)
	rlwimi r0, r4, 7, 24, 24
	stb r0, 3(r30)
	b file_begin


start:
	mfctr r0
	lwz r3, 44(r31)
	add r0, r3, r0
	cmpwi r0, 3
	beq skipper
	cmpwi r0, 2
	bne done
fixup:
	lwz r0, 356(r31)
	stb r0, 97(r6)
	stb r0, 133(r6)

	lwz r0, 336(r31)
	stb r0, 96(r6)
	lwz r0, 308(r31)
	stb r0, 132(r6)

	lwz r0, 628(r31)
	stb r0, 105(r6)
	lwz r0, 632(r31)
	stb r0, 141(r6)

done:
	addi r5, r5, 8
skipper:
	b start


nop
nop


	lis r4, 0x8000
	ori r4, r4, 0x24A4
	li r0, 6
	mtctr r0
	mr r5, r30
sdelta_loop:
	lwzu r0, 4(r4)
	lbz r3, 98(r5)
	add r3, r3, r0
	stb r3, 98(r5)
	addi r5, 36
	bdnz sdelta_loop
	b file_begin

nop
nop





	lis r4, 0x8000
	ori r4, r4, 0x2308
	li r3, 6
	mtctr r3
	mr r5, r30
randplayer_loop:
	lbz r3, 96(r5)
	cmpwi r3, 0x21
	bne do_nothing
	
repeat_rand:
	lwz r3, 0(r4)
	mulli r3, r3, 16807
	oris r3, r3, 0x8000
	xoris r3, r3, 0x8000
	stw r3, 0(r4)
	rlwimi r3, r3, 24, 0, 31
	andi r3, r3, 0x1F
	cmpwi r3, 0x13
	beq repeat_rand
	cmpwi r3, 0x1A
	bge repeat_rand



	stb r3, 96(r5)
do_nothing:
	addi r5, 36
	bdnz randplayer_loop
	b file_begin

nop
nop

andi r3, r3, 0xF
nop


	mflr r0
	li r3, 6
	mtctr r3
	mr r5, r30
randplayer_loop:
	lbz r3, 96(r5)
	cmpwi r3, 0x21
	bne do_nothing
	bl file_begin
	stb r3, 96(r5)
do_nothing:
	addi r5, 36
	bdnz randplayer_loop
	mtlr r0
	b file_begin

nop
nop	

	lis r4, 0x8000
	ori r4, r4, 0x2308
repeat_rand:
	lwz r3, 0(r4)
	mulli r3, r3, 16807
	rlwimi r3, r3, 0, 1, 31
	stw r3, 0(r4)
	rlwimi r3, r3, 24, 27, 31
	cmpwi r3, 0x13
	beq repeat_rand
	cmpwi r3, 0x1A
	bge repeat_rand
	blr

nop
nop





	lis r4, 0x8000
	ori r4, r4, 0x22BC
	li r0, 6
	mtctr r0
	mr r5, r30
controller_loop:
	lwzu r0, 4(r4)
	stb r0, 100(r5)
	addi r5, 36
	bdnz controller_loop
	lwz	r0,28(r1)
	b file_begin
nop
nop


lwz	r0,28(r1)

mflr	r0
lis	r4,0x8000
stw	r0,4(r1)
lis	r5,-32720
ori	r4, r4, 0x21A8
stwu	r1,-8(r1)
subi	r5,r5,404
bl	file_begin
li	r3,0
lwz	r0,12(r1)
addi	r1,r1,8
mtlr	r0
blr

nop
nop

m_start:
	mflr r0
	cmpwi r3, 0
	bne mush_stack_end
	lis r5, 0x8000
	ori r5, r5, 0x2080
	lwz r5, 0(r5)
	cmpwi r5, 0
	beq m_stack_off
m_stack_on:
	lis r7, 0x8000
	ori r7, r7, 0x2084
	lis r8, 0x8000
	ori r8, r8, 0x20A0
	bl m_start
	b mush_stack_end
m_stack_off:
	lis r7, 0x8000
	ori r7, r7, 0x20B8
	lis r8, 0x8000
	ori r8, r8, 0x20D4
	bl m_start
mush_stack_end:
	mtlr r0
	blr

nop
nop

li r6, 0x803FA15C
stw r3, 0(r6)
stw r4, 4(r6)
blr
nop
nop


lis r7, 0xaaaa
ori r7, r7, 0xbbbb
lis r8, 0xcccc
ori r8, r8, 0xdddd

patcher_loop:
lwz r3, 0(r7)
lwz r4, 0(r8)
cmpwi r3, 0
beq fin
stw r4, 0(r3)
rlwinm r3,r3,0,0,26
dcbf r0, r3
icbi r0, r3
sync
isync
addi r7, r7, 4
addi r8, r8, 4
b patcher_loop
fin:
blr

nop
nop
lis r3, 0x8022
ori r3, r3, 0xD61C
li r3, 0x8022D61C
lis r4, 0x3800
addi r4, r4, 0x8006
stw r4, 0(r3)
rlwinm r3,r3,0,0,26
dcbf r0, r3
icbi r0, r3
sync
isync
blr
nop
li r3,0
nop

lbz r7, 56(r31)
stb r7, 5(r30)
lbz r7, 57(r31)
stb r7, 6(r30)
nop
nop


li r7, 0xFD
lwz r4, 544(r31)
stw r4, 52(r30)
lwz r4, 552(r31)
stb r4, 1(r30)
nop
nop

lwz	r4, 56(r31)
stw	r4, 36(r30)
lwz	r3, 52(r31)
stw	r3, 32(r30)
nop
nop

	lis r3, 0x8022
	addi r3, r3, 0xD61C
	lwz r4, 0(r3)
	lis r4, 0x3800
	addi r4, r4, 0x0006
	stw r4, 0(r3)
	lwz r4, 0(r3)
	sync
	isync
	icbi r0, r3
	dcbi r0, r3
	dcbf r0, r3
	sync
	isync
	blrl
	nop
	nop


# POKE 8022D61C 38000006







	nop
	nop

jkstart:
	mfctr r0
	cmpwi r0,2
	beq skipper
	cmpwi r0,3
	beq done
	lwz r0, 44(r5)
	stb r0, 97(r6)
	stb r0, 133(r6)
	lwz r0, 24(r5)
	stb r0, 96(r6)
	lwz r0, -4(r5)
	stb r0, 132(r6)
	lbz r0, 105(r6)
	andi r0, r0, 0xFD
	stb r0, 105(r6)
	lbz r0, 141(r6)
	andi r0, r0, 0xFD
	stb r0, 141(r6)
okdone:
	addi r5, r5, 8
okskipper:
	b start

nop
nop
	

rfi
nop
lwz r0, 544(r31)
stw r0, 52(r30)
lwz r0, 552(r31)
stb r0, 1(r30)


mulli r0, r0, 2
stb r4, 144(r6)
stb r4, 108(r6)
rlwimi r0, r4, 0, 24, 31

#.end

#.org 0x0400F81C
mr r23, r3
mr r24, r4
b do_icbi
mr r3, r23
mr r4, r24
nop 
mtlr r23
blr

#.org 0x8001E1E8
do_icbi:
nop


.endif
