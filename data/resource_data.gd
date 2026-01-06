################################################################################
## Global lists for a ResourceItem
################################################################################
extends Node

## ALl available types of Contributors
enum Contributors {
	Author,
	Creator,
	Editor,
	Illustrator,
	Narrator,
	Translator,
	Other
}

## All available types of resouces
enum ResourceType {
	Book,
	Audio,
	Magazine,
	Video,
	Other
}

## All available types of divisions
enum DivisionType {
	None,
	Assignment,
	Chapter,
	Lesson,
	Poem
}

## All SCM Subjects
enum Subjects {
	Art,
	Bible,
	ForeignLanguage,
	Geography,
	Grammar,
	Handicrafts,
	Handwriting,
	History,
	LanguageArts,
	Literature,
	Math,
	Music,
	NatureStudy, 
	PersonalDevelopment,
	Poetry,
	Reading,
	Science,
	Shakespeare,
	Spelling,
	Other
}

enum ViewingOptions{
	New,
	Edit,
	View
}

enum study_method {
	Complete,
	Do_a_hands_activity,
	Do_a_picture_study,
	Do_a_nature_study,
	Listen_together,
	Read_and_narrate,
	Read_independently,
	Read_Together,
	Recite_aloud,
	Sing_together,
	Watch_together
}

enum week_day {
	Sunday,
	Monday,
	Tuesday,
	Wednesday,
	Thursday,
	Friday,
	Saturday
}
