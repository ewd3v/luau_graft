-- Tests go here
assert(require("./src").value == "Hi from " .. _G.RUNTIME, "Incorrect welcome message")
