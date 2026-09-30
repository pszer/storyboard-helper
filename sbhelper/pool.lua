--
--
-- Figures out how sprites can be pooled to minimise sprite declaration count.
-- Can also be configured to preserve depth, but Not occlusion culling.
--
local pool = {}
pool.__index = pool

return pool
