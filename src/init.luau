local hello = require("@pkg/hello")
hello()

return {
	value = "Hi from " .. _G.RUNTIME,
}
