Class {
	#name : #DRCogitGeneratorTest,
	#superclass : #TestCase,
	#category : #'Druid-Tests'
}

{ #category : #helpers }
DRCogitGeneratorTest >> generateCogitForInstruction: aDRInstruction [
	
	| generator |
	generator := DRCogitCodeGenerator new.
	aDRInstruction acceptVisitor: generator.
	^ generator
]

{ #category : #helpers }
DRCogitGeneratorTest >> generateCogitPreambleFor: aDRControlFlowGraph [ 
	
	| generator |
	generator := DRCogitCodeGenerator new.
	generator generatePreambleForCFG: aDRControlFlowGraph.
	^ generator
]

{ #category : #tests }
DRCogitGeneratorTest >> testConstantsBiggerThan5000AreInHexa [

	| cfg basicBlock r0 cogitAST move2ACASTInstruction |
	cfg := DRControlFlowGraph new.
	basicBlock := cfg newBasicBlockWith: [ :block |
		"R0 := 2"
		r0 := block copy: 8000.].
	cfg initialBasicBlock jumpTo: basicBlock.
	
	"Transform 3AC to 2AC =>
	R0 := 16r1F40.
	"
	cogitAST := self generateCogitForInstruction: r0.
	
	move2ACASTInstruction := cogitAST generatorMethodBuilder statements first.
	self assert: move2ACASTInstruction selector equals: #MoveCq:R:.
	self assert: move2ACASTInstruction arguments first value equals: 8000.
	self assert: move2ACASTInstruction arguments first sourceText equals: '16r1F40'.
	self assert: move2ACASTInstruction arguments second name equals: 'R0'
]

{ #category : #tests }
DRCogitGeneratorTest >> testGenerateAndBetweenRegistersAndNoResult [

	| cfg basicBlock r0 r1 cogitAST orASTInstruction r2 |
	cfg := DRControlFlowGraph new.
	basicBlock := cfg newBasicBlockWith: [ :block |
		"R0 := 2"
		r0 := block copy: 2.
		r1 := block copy: 3.
		"R2 := R0 AND R1"
		r2 := block and: r0 with: r1 ].
	cfg initialBasicBlock jumpTo: basicBlock.

	"Guarantee we are in two address code, and we need no result value"	
	r2 result: DRNoRegister new.
	
	cogitAST := self generateCogitForInstruction: r2.	
	orASTInstruction := cogitAST generatorMethodBuilder statements first.

	"Should generate: cogit AndR: R1 R: R0.
	In Druid 2AC, the destination is bound to the first operand.
	In Cogit, to the second operand"
	self assert: orASTInstruction selector equals: #AndR:R:.
	self assert: orASTInstruction arguments first name equals: 'R1'.
	self assert: orASTInstruction arguments second name equals: 'R0'
]

{ #category : #tests }
DRCogitGeneratorTest >> testGenerateDivision [

	| cfg basicBlock r1 cogitAST divideASTInstruction r2 |
	cfg := DRControlFlowGraph new.
	basicBlock := cfg newBasicBlockWith: [ :block | | r0 |
		"R0 := 2"
		r0 := block copy: 2.
		r1 := block copy: 1.
		"R2 := R0 / R1"
		r2 := block divide: r0 by: r1 ].
	cfg initialBasicBlock jumpTo: basicBlock.
		
	"The Cogit specific register allocator should allocate a free register for the remainder.
	Simulate this in the test for now"
	r2 addOperand: cfg instructionFactory allocateTemporaryRegister.
	
	"Cogit division is not in 2AC but in 4AC.
	Inserts REM Destination implicitly yet unused, and puts all operands in registers.
	
	R0 := 2. (Dividend)
	R1 := 1. (Divisor)
	DIVIDE R1 R0 R2 (quotient) R3 (remainder)
	"

	cogitAST := self generateCogitForInstruction: r2.	
	divideASTInstruction := cogitAST generatorMethodBuilder statements first.
	self assert: divideASTInstruction selector equals: #DivR:R:Quo:Rem:.
	self assert: divideASTInstruction arguments first name equals: 'R1'.
	self assert: divideASTInstruction arguments second name equals: 'R0'.
	self assert: divideASTInstruction arguments third name equals: 'R2'.
	self assert: divideASTInstruction arguments fourth name equals: 'R3'.
]

{ #category : #tests }
DRCogitGeneratorTest >> testGenerateLoadSpilledMemoryAddress [

	| cfg basicBlock cogitAST loadInstruction r0 |

	cfg := DRControlFlowGraph new.
	basicBlock := cfg newBasicBlockWith: [ :block |
		"R0 := LOAD STACK-1"
		r0 := block load: (DRSpilledMemoryAddress stackOffset: 1) ].
	cfg initialBasicBlock jumpTo: basicBlock.
			
	"Should generate
	
	self MoveM64: 8 r: SPReg R: R0
	"

	cogitAST := self generateCogitForInstruction: r0.	
	loadInstruction := cogitAST generatorMethodBuilder statements first.
	self assert: loadInstruction selector equals: #MoveMw:r:R:.
	self assert: loadInstruction arguments first value equals: 8.
	self assert: loadInstruction arguments second name equals: 'SPReg'.
	self assert: loadInstruction arguments third name equals: 'R0'
]

{ #category : #tests }
DRCogitGeneratorTest >> testGenerateMethodWithSpillingAllocatesStackSpace [

	| cfg basicBlock cogitAST spillRegister1 stackAllocationInstruction |
	cfg := DRControlFlowGraph new.
	basicBlock := cfg newBasicBlockWith: [ :block |
		block copy: 2 ].
	cfg initialBasicBlock jumpTo: basicBlock.

	spillRegister1 := DRPhysicalRegister name: 'SPR1'.
	DRCogitLinearScanRegisterAllocator new
		registers: #();
		spillRegisters: { spillRegister1 };
		allocateRegistersIn: cfg.

	cogitAST := self generateCogitPreambleFor: cfg.
	stackAllocationInstruction := cogitAST generatorMethodBuilder statements first.
	self assert: stackAllocationInstruction selector equals: #AddCq:R:.
	self assert: stackAllocationInstruction arguments second name equals: 'SPReg'.
	self assert: stackAllocationInstruction arguments first value equals: cfg numberOfSpillSlots * 8 "bytes".
]

{ #category : #tests }
DRCogitGeneratorTest >> testGenerateModulo [

	| cfg basicBlock r1 cogitAST divideASTInstruction r2 |
	cfg := DRControlFlowGraph new.
	basicBlock := cfg newBasicBlockWith: [ :block | | r0 |
		"R0 := 2"
		r0 := block copy: 2.
		r1 := block copy: 1.
		"R2 := R0 % R1"
		r2 := block modulo: r0 by: r1 ].
	cfg initialBasicBlock jumpTo: basicBlock.
		
	"The Cogit specific register allocator should allocate a free register for the quotient.
	Simulate this in the test for now"
	r2 addOperand: cfg instructionFactory allocateTemporaryRegister.
	
	"Cogit division is not in 2AC but in 4AC.
	Inserts Quotient Destination implicitly yet unused, and puts all operands in registers.
	
	R0 := 2. (Dividend)
	R1 := 1. (Divisor)
	DIVIDE R1 R0 R3 (quotient) R2 (remainder)
	"

	cogitAST := self generateCogitForInstruction: r2.	
	divideASTInstruction := cogitAST generatorMethodBuilder statements first.
	self assert: divideASTInstruction selector equals: #DivR:R:Quo:Rem:.
	self assert: divideASTInstruction arguments first name equals: 'R1'.
	self assert: divideASTInstruction arguments second name equals: 'R0'.
	self assert: divideASTInstruction arguments third name equals: 'R3'.
	self assert: divideASTInstruction arguments fourth name equals: 'R2'.
]

{ #category : #tests }
DRCogitGeneratorTest >> testGenerateNilAsZero [

	| cfg basicBlock cogitAST r0 r1 compare |
	cfg := DRControlFlowGraph new.
	basicBlock := cfg newBasicBlockWith: [ :block |
		"Compare nil 0"
		r0 := block copy: 0.
		r1 := block equals: nil to: r0 ].
	cfg initialBasicBlock jumpTo: basicBlock.
		
	
	cogitAST := self generateCogitForInstruction: r1.	
	compare := cogitAST generatorMethodBuilder statements first.
	self assert: compare selector equals: #CmpCq:R:.
	self assert: compare arguments first value equals: 0
]

{ #category : #tests }
DRCogitGeneratorTest >> testGenerateOrConstant [

	| cfg basicBlock r0 r1 cogitAST orASTInstruction |
	cfg := DRControlFlowGraph new.
	basicBlock := cfg newBasicBlockWith: [ :block |
		"R0 := 2"
		r0 := block copy: 2.
		"R1 := R0 OR false"
		r1 := block or: r0 with: false asDRValue ].
	cfg initialBasicBlock jumpTo: basicBlock.

	"Guarantee we are in two address code, not in SSA anymore"	
	r1 result: r0 result.
	
	cogitAST := self generateCogitForInstruction: r1.	
	orASTInstruction := cogitAST generatorMethodBuilder statements first.

	self assert: orASTInstruction selector equals: #OrCq:R:.
	self assert: orASTInstruction arguments first value equals: 0.
	self assert: orASTInstruction arguments second name equals: 'R0'
]

{ #category : #tests }
DRCogitGeneratorTest >> testGenerateOrConstantWithNoResult [

	| cfg basicBlock r0 r1 cogitAST orASTInstruction |
	cfg := DRControlFlowGraph new.
	basicBlock := cfg newBasicBlockWith: [ :block |
		"R0 := 2"
		r0 := block copy: 2.
		"R1 := R0 OR false"
		r1 := block or: r0 with: false asDRValue ].
	cfg initialBasicBlock jumpTo: basicBlock.

	"Guarantee we are in two address code, not in SSA anymore"	
	r1 result: DRNoRegister new.
	
	cogitAST := self generateCogitForInstruction: r1.	
	orASTInstruction := cogitAST generatorMethodBuilder statements first.

	self assert: orASTInstruction selector equals: #OrCq:R:.
	self assert: orASTInstruction arguments first value equals: 0.
	self assert: orASTInstruction arguments second name equals: 'R0'
]

{ #category : #tests }
DRCogitGeneratorTest >> testGenerateSpillLoadInstruction [

	| cfg basicBlock cogitAST spillRegister1 spillStoreInstruction storeInstruction |
	cfg := DRControlFlowGraph new.
	basicBlock := cfg newBasicBlockWith: [ :block |
		block copy: 2 ].
	cfg initialBasicBlock jumpTo: basicBlock.

	spillRegister1 := DRPhysicalRegister name: 'SPR1'.
	DRCogitLinearScanRegisterAllocator new
		registers: #();
		spillRegisters: { spillRegister1 };
		allocateRegistersIn: cfg.

	storeInstruction := basicBlock instructions second.
	cogitAST := self generateCogitForInstruction: storeInstruction.
	spillStoreInstruction := cogitAST generatorMethodBuilder statements first.
	self assert: spillStoreInstruction selector equals: #MoveR:Mw:r:.
	self assert: spillStoreInstruction arguments first name equals: spillRegister1 name.
	self assert: spillStoreInstruction arguments second value equals: storeInstruction operand2 stackOffset * 8 "bytes".
	self assert: spillStoreInstruction arguments third name equals: 'SPReg'.
]