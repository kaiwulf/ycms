type
    Article* = object
        id*: string
        publicationDate*: string
        title*: string
        summary*: string
        content*: string

# Application state
type
    State* = object
        nextId*: int64
        articleItems*: seq[Article]
        stateSeq*: seq[string]