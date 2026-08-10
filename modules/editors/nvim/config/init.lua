-- Entry point. Order matters: options + keymaps (which set <leader>) load before
-- lazy so plugins map their keys against the right leader.
require("core.options")
require("core.keymaps")
require("core.lazy")
