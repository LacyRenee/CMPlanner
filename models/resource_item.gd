## The information to be stored for a Resource Item
class_name ResourceItem
extends Resource

## Name of the Resource Item
@export var title : String

## International Standard Book Number
@export var isbn : String 

## Accepts the resource type from the ResourceLists: Book, Magazine, etc...
@export var resource_type : ResourceData.ResourceType

## Accepts the resources contributor from the ResourceLists: Author, Illustrator, etc...
@export var contributor : ResourceData.Contributors

## Identifies the contributor
@export var contributor_name : String

@export var subject : ResourceData.Subjects

## Additional Details
#region 
## Specifies the resource's website
@export var web_url : String

## Name of the publishing company
@export var publisher : String

## Publication year
@export var copyright_date : String

## Year the resource was written
@export var year_written : String

## Total number of pages
@export var number_of_pages : int

## First, Second, etc... edition
@export var edition : String

## Not sure how to implement
@export var cover_image : Texture2D

## User's description of the resource
@export var description : String
#endregion 

@export var tags : Array[String]

## Accepts the resources division from the ResourceLists: Chapter, Lesson, etc...
@export var division_type : ResourceData.DivisionType

## A list of all the divisions for the resource
@export var division_list : Array[String]
