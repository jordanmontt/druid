Class {
	#name : #DRClosureCreation,
	#superclass : #DRInstruction,
	#category : #'Druid-IR'
}

{ #category : #visiting }
DRClosureCreation >> acceptVisitor: aVisitor [

	^ aVisitor visitClosureCreation: self
]

{ #category : #testing }
DRClosureCreation >> isMandatoryInstruction [

	^ true
]

{ #category : #SCCP }
DRClosureCreation >> sccpLatticeValueFor: sccp [ 
	
	"This instruction has no value"
	^ sccp bottom
]