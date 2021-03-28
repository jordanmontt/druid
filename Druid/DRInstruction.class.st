Class {
	#name : #DRInstruction,
	#superclass : #DRValue,
	#instVars : [
		'operands',
		'result',
		'order'
	],
	#category : #'Druid-IR'
}

{ #category : #'instance creation' }
DRInstruction class >> operands: aCollection result: aResultRegister [
	
	^ self new
		operands: aCollection;
		result: aResultRegister;
		yourself
]

{ #category : #testing }
DRInstruction >> isPhiFunction [

	^ false
]

{ #category : #accessing }
DRInstruction >> operand1 [
	
	^ operands at: 1
]

{ #category : #accessing }
DRInstruction >> operand2 [

	^ operands at: 2
]

{ #category : #accessing }
DRInstruction >> operands [
	^ operands
]

{ #category : #accessing }
DRInstruction >> operands: aCollection [ 
	operands := aCollection
]

{ #category : #accessing }
DRInstruction >> order [
	
	^ order
]

{ #category : #accessing }
DRInstruction >> order: anInteger [ 
	order := anInteger
]

{ #category : #accessing }
DRInstruction >> result [

	^ result
]

{ #category : #accessing }
DRInstruction >> result: anObject [

	result := anObject
]