Class {
	#name : #DRNonConditionalSCCPConstantFoldingTest,
	#superclass : #TestCase,
	#category : #'Druid-Tests'
}

{ #category : #tests }
DRNonConditionalSCCPConstantFoldingTest >> testConstantFoldingAddInSingleBasicBlock [

	| optimisation bb cfg copy1 copy2 operandList|
	optimisation := DRNonConditionalSCCP new.
	bb := DRBasicBlock new.
		
	cfg := DRControlFlowGraph new.
	cfg initialBasicBlock: bb.

	bb addInstruction: (copy1 := DRCopy operands: { DRConstantValue value: 3 } result:  (DRTemporaryRegister id: 1)).
	bb addInstruction: (copy2 := DRCopy operands: { DRConstantValue value: 4 } result:  (DRTemporaryRegister id: 2)).
	
	operandList := OrderedCollection new. 
	operandList add: copy1. 
	operandList add: copy2.

	bb addInstruction: (DRAdd  operands: operandList result:  (DRTemporaryRegister id: 3)).
	optimisation applyTo: cfg.
	

	self assert: cfg instructions last operands equals: (DRConstantValue value: 7).
	self assert: cfg instructions last isCopy. 
]

{ #category : #tests }
DRNonConditionalSCCPConstantFoldingTest >> testConstantFoldingBitAndInSingleBasicBlock [

	| optimisation bb cfg copy1 copy2 operandList|
	optimisation := DRNonConditionalSCCP new.
	bb := DRBasicBlock new.
		
	cfg := DRControlFlowGraph new.
	cfg initialBasicBlock: bb.

	bb addInstruction: (copy1 := DRCopy operands: { DRConstantValue value: 2r0101010110 } result:  (DRTemporaryRegister id: 1)).
	bb addInstruction: (copy2 := DRCopy operands: { DRConstantValue value: 2r0101011111 } result:  (DRTemporaryRegister id: 2)).
	
	operandList := OrderedCollection new. 
	operandList add: copy1. 
	operandList add: copy2.

	bb addInstruction: (DRBitAnd  operands: operandList result:  (DRTemporaryRegister id: 3)).
	optimisation applyTo: cfg.
	

	self assert: (cfg instructions last operands) equals: (DRConstantValue value: 2r0101010110)
]

{ #category : #tests }
DRNonConditionalSCCPConstantFoldingTest >> testConstantFoldingMultiplyByZeroLeft [

	| optimisation bb cfg copy1 copy2 operandList|
	optimisation := DRNonConditionalSCCP new.
	bb := DRBasicBlock new.
		
	cfg := DRControlFlowGraph new.
	cfg initialBasicBlock: bb.

	bb addInstruction: (copy1 := DRCopy operands: { DRConstantValue value: 0 } result:  (DRTemporaryRegister id: 1)).
	bb addInstruction: (copy2 := DRCopy operands: { DRConstantValue value: 4} result:  (DRTemporaryRegister id: 2)).
	
	operandList := OrderedCollection new. 
	operandList add: copy1. 
	operandList add: copy2.

	bb addInstruction: (DRMultiply operands: operandList result:  (DRTemporaryRegister id: 3)).
	optimisation applyTo: cfg.
	

	self assert: (cfg instructions last operands) equals: (DRConstantValue value: 0)
]

{ #category : #tests }
DRNonConditionalSCCPConstantFoldingTest >> testConstantFoldingMultiplyInSingleBasicBlock [

	| optimisation bb cfg copy1 copy2 operandList|
	optimisation := DRNonConditionalSCCP new.
	bb := DRBasicBlock new.
		
	cfg := DRControlFlowGraph new.
	cfg initialBasicBlock: bb.

	bb addInstruction: (copy1 := DRCopy operands: { DRConstantValue value: 3 } result:  (DRTemporaryRegister id: 1)).
	bb addInstruction: (copy2 := DRCopy operands: { DRConstantValue value: 4 } result:  (DRTemporaryRegister id: 2)).
	
	operandList := OrderedCollection new. 
	operandList add: copy1. 
	operandList add: copy2.

	bb addInstruction: (DRMultiply operands: operandList result:  (DRTemporaryRegister id: 3)).
	optimisation applyTo: cfg.
	

	self assert: (cfg instructions last operands) equals: (DRConstantValue value: 12)
]

{ #category : #tests }
DRNonConditionalSCCPConstantFoldingTest >> testConstantFoldingSubstractInSingleBasicBlock [

	| optimisation bb cfg copy1 copy2 operandList|
	optimisation := DRNonConditionalSCCP new.
	bb := DRBasicBlock new.
		
	cfg := DRControlFlowGraph new.
	cfg initialBasicBlock: bb.

	bb addInstruction: (copy1 := DRCopy operands: { DRConstantValue value: 3 } result:  (DRTemporaryRegister id: 1)).
	bb addInstruction: (copy2 := DRCopy operands: { DRConstantValue value: 4 } result:  (DRTemporaryRegister id: 2)).
	
	operandList := OrderedCollection new. 
	operandList add: copy1. 
	operandList add: copy2.

	bb addInstruction: (DRSubtract operands: operandList result:  (DRTemporaryRegister id: 3)).
	optimisation applyTo: cfg.
	

	self assert: (cfg instructions last operands) equals: (DRConstantValue value: -1)
]

{ #category : #tests }
DRNonConditionalSCCPConstantFoldingTest >> testFoldBitShiftWithConstants [

	| optimisation bb cfg copy1 copy2 operandList|
	optimisation := DRNonConditionalSCCP new.
	bb := DRBasicBlock new.
		
	cfg := DRControlFlowGraph new.
	cfg initialBasicBlock: bb.

	bb addInstruction: (copy1 := DRCopy operands: { DRConstantValue value: 2r1000 } result:  (DRTemporaryRegister id: 1)).
	bb addInstruction: (copy2 := DRCopy operands: { DRConstantValue value: 1} result:  (DRTemporaryRegister id: 2)).
	
	operandList := OrderedCollection new. 
	operandList add: copy1. 
	operandList add: copy2.

	bb addInstruction: (DRBitShift  operands: operandList result:  (DRTemporaryRegister id: 3)).
	optimisation applyTo: cfg.
	

	self assert: (cfg instructions last operands) equals: (DRConstantValue value: 2r100)
]