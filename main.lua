function read_code(filename)
    local file = io.open(filename, "r")
    local code = file:read("*all")
    file:close()
    return code
end


function execute(code)
    local tape = setmetatable({}, {
        __index = function() return 0 end
    })
    local ptr = 0
    local pc = 1
    local loop_stack = {}

    while pc <= #code do
        local c = code:sub(pc, pc)
        if c == ">" then
            ptr = ptr + 1
        elseif c == "<" then
            ptr = ptr - 1
        elseif c == "+" then
            tape[ptr] = tape[ptr] + 1
        elseif c == "-" then
            tape[ptr] = tape[ptr] - 1
        elseif c == "." then
            io.write(string.char(tape[ptr]))
        elseif c == "," then
            tape[ptr] = io.read(1):byte()
        elseif c == "[" then
            if tape[ptr] == 0 then
                local depth = 1
                while depth > 0 do
                    pc = pc + 1
                    if code:sub(pc, pc) == "[" then
                        depth = depth + 1
                    elseif code:sub(pc, pc) == "]" then
                        depth = depth - 1
                    end
                end
            else
                table.insert(loop_stack, pc)
            end
        elseif c == "]" then
            if tape[ptr] ~= 0 then
                pc = loop_stack[#loop_stack]
            else
                table.remove(loop_stack)
            end
        end
        pc = pc + 1
    end
end


local filename = arg[1]
if not filename then
    print("Usage: lua main.lua <filename>")
    os.exit(1)
end

local code = read_code(filename)
execute(code)
