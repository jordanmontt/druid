Class {
	#name : #DRVMState,
	#superclass : #Object,
	#instVars : [
		'operandStack',
		'primitiveFailureCode',
		'builder'
	],
	#category : #'Druid-CompilerCompiler'
}

{ #category : #accumulating }
DRVMState >> addPrimitiveFailureCode: aValue [
	
	"If the operand did not change, do nothing"
	primitiveFailureCode == aValue ifTrue: [ ^ self ].
	"Otherwise, accumulate it"
	primitiveFailureCode addValue: aValue
]

{ #category : #accumulating }
DRVMState >> addStackOperand: operand at: stackPosition [

	| stackOperandPhi |
	"Fill with empty phis if necessary"
	[ stackPosition > operandStack size ] whileTrue: [ 
		operandStack push:
			(builder instructionFactory
				phiWithVariables: OrderedCollection new) ].

	stackOperandPhi := operandStack at: stackPosition.
	"If the operand did not change, do nothing"
	stackOperandPhi == operand ifTrue: [ ^ self ].
	
	"Block closures are special and we do not handle polymorphic blocks.
	If the temporary is a block closure, override the phi function.
	Avoid overriding block closures too"
	stackOperandPhi isDRBlockClosure ifTrue: [ 
		self error: 'cannot override block closures in the stack' ].
	
	operand isDRBlockClosure ifTrue: [
		^ operandStack at: stackPosition put: operand ].
	
	"Otherwise, accumulate it"
	stackOperandPhi addValue: operand
]

{ #category : #accumulating }
DRVMState >> addTo: aDRVMState [ 
	
	"Add my own state to the execution state in parameter"
	aDRVMState completeOperandStackUpTo: operandStack size.
	self operandStackWithIndexDo: [ :operand :stackPosition |
		aDRVMState addStackOperand: operand at: stackPosition ].
	aDRVMState addPrimitiveFailureCode: primitiveFailureCode.
]

{ #category : #merging }
DRVMState >> completeOperandStackUpTo: anInteger [ 
	
	| predecessorsUntilNow |
	predecessorsUntilNow := self maxNumberOfPredecessors.
	operandStack size + 1 to: anInteger do: [ :i | 
		operandStack push: (builder instructionFactory
				phiWithVariables: (OrderedCollection
					new: predecessorsUntilNow
					withAll: DRNullValue new)) ]
]

{ #category : #initialization }
DRVMState >> initialize [
	super initialize.
	
	operandStack := Stack new
]

{ #category : #initialization }
DRVMState >> initializeOnBuilder: aBuilder [ 
	
	builder := aBuilder.
	primitiveFailureCode := aBuilder instructionFactory phiWithVariables: OrderedCollection new.
	
]

{ #category : #testing }
DRVMState >> isNotSimplified [
	
	"All should be phi functions"
	^ (operandStack allSatisfy: [ :e | 
			e isPhiFunction or: [ e isDRBlockClosure ] ])
				and: [ primitiveFailureCode isPhiFunction  or: [ primitiveFailureCode isDRBlockClosure ] ]
]

{ #category : #accessing }
DRVMState >> maxNumberOfPredecessors [
	
	"Select the max number of operands in the phis"
	| max |
	max := primitiveFailureCode operands size.
	operandStack ifEmpty: [ ^ max ].
	
	^ (operandStack max: [ :e | e operands size ]) max: max
]

{ #category : #accessing }
DRVMState >> operandStack [

	^ operandStack
]

{ #category : #accessing }
DRVMState >> operandStack: anObject [

	operandStack := anObject
]

{ #category : #iterating }
DRVMState >> operandStackWithIndexDo: aFullBlockClosure [ 
	
	operandStack withIndexDo: aFullBlockClosure
]

{ #category : #copying }
DRVMState >> postCopy [
	super postCopy.
	operandStack := operandStack copy
]

{ #category : #accessing }
DRVMState >> primitiveFailureCode [

	^ primitiveFailureCode
]

{ #category : #accessing }
DRVMState >> primitiveFailureCode: anObject [

	primitiveFailureCode := anObject
]

{ #category : #simplification }
DRVMState >> simplify [
	
	| newOperand newPrimitiveFailureCode |
	operandStack withIndexDo: [ :operand :index |
		newOperand := operand simplify.
		newOperand ~~ operand ifTrue: [
			operandStack at: index put: newOperand.
			operand replaceUsesBy: newOperand ] ].

	newPrimitiveFailureCode := primitiveFailureCode simplify.
	newPrimitiveFailureCode ~~ primitiveFailureCode ifTrue: [
		primitiveFailureCode := newPrimitiveFailureCode.
		primitiveFailureCode replaceUsesBy: newPrimitiveFailureCode ].
]