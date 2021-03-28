Class {
	#name : #DRValue,
	#superclass : #Object,
	#category : #'Druid-IR'
}

{ #category : #visiting }
DRValue >> acceptVisitor: aVisitor [

	self subclassResponsibility
]

{ #category : #building }
DRValue >> addToBlock: aDRBasicBlock [ 
	
	aDRBasicBlock addInstruction: self
]

{ #category : #converting }
DRValue >> asDRInterpreterValue [

	^ self
]

{ #category : #testing }
DRValue >> isConstant [
	
	^ false
]

{ #category : #testing }
DRValue >> isPhiFunction [

	^ false
]

{ #category : #testing }
DRValue >> isRegister [

	^ false
]

{ #category : #testing }
DRValue >> isVirtualRegister [
	
	^ false
]

{ #category : #joining }
DRValue >> joinValue: anotherValue onIRGenerator: anIRGenerator from: originBlocks [

	self == anotherValue ifTrue: [ ^ self ].

	^ (DRPhiFunction joinedVariables: { self . anotherValue })
		result: anIRGenerator allocateTemporaryRegister;
		originBlocks: originBlocks;
		addToBlock: anIRGenerator currentBasicBlock;
		yourself
]

{ #category : #interpretation }
DRValue >> lookupClass [
	
	self subclassResponsibility
]

{ #category : #accessing }
DRValue >> result [

	^ self
]

{ #category : #accessing }
DRValue >> targets [

	^ #()
]