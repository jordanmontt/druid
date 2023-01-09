Class {
	#name : #DRLoadArgument,
	#superclass : #DRInstruction,
	#instVars : [
		'size',
		'argNum'
	],
	#category : #'Druid-IR'
}

{ #category : #visiting }
DRLoadArgument >> acceptVisitor: aVisitor [
	
	^ aVisitor visitLoadArgument: self
]

{ #category : #accessing }
DRLoadArgument >> classType: aType [
	
	classType := aType
]

{ #category : #visiting }
DRLoadArgument >> isLoadArgument [

	^ true
]

{ #category : #printing }
DRLoadArgument >> opcode [
	
	^ 'LoadArgument', argNum asString
]

{ #category : #accessing }
DRLoadArgument >> operands: operandList [

	argNum := operandList first value.
	super operands: operandList allButFirst
]

{ #category : #accessing }
DRLoadArgument >> type [
	
	^ classType ifNil: [DRUndefinedType new]
]