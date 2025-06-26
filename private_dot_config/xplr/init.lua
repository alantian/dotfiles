version = '1.0.0'


local home = os.getenv("HOME")
package.path = home
.. "/.config/xplr/plugins/?/init.lua;"
.. home
.. "/.config/xplr/plugins/?.lua;"
.. package.path


require("zoxide").setup{
  bin = "zoxide",
  mode = "default",
  key = "Z",
}

