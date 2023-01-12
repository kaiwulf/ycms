type
    Article* = object
        id*: string
        publicationDate*: string
        title*: string
        summary*: string
        content*: string
# To implement later. Will need hash tags for blog posts.
var hash_tags*: seq[string]

# Application state
type
    State* = object
        nextId*: int64
        articleItems*: seq[Article]
        stateSeq*: seq[string]