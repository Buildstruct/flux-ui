Flux.Config = {
    -- Fonts: I would recommend, unless you are wanting to use a custom font, to 
    -- set these values to fonts that come preinstalled with said OS. Linux
    -- is a bit funky, since each distro has their own set fonts that come
    -- preinstalled. You can set Config.Fonts to either a table or a string.
    -- e.g. Fonts = {Linux = <font name>, Windows = <font name>} or Fonts = <font name>
    Fonts = {
        Linux = "DejaVu Sans Mono",
        Windows = "Consolas"
    },

    MemoryClearInterval = 0.25, -- How many seconds to run the memory checker (1s default)
    MemoryDeleteTime = 0.333, -- How many seconds before a cached value is deleted without being touched?
    MemoryModificationDelay = 0.333, -- How many seconds before we can look to see if a value is modified?
}
