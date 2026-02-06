include "root" {
  path = find_in_parent_folders("root.hcl")
   expose = true
}

include "envcommon" {
  path   = find_in_parent_folders("_envcommon/network.hcl")
  expose = true
}

