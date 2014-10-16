
-- This contaminants the file that requires...
-- require('strict')


local function newlocalfuncint()
    return 48
end

function newglobalfunint()
    return 42
end

return {
    l=newlocalfuncint,
    g=newglobalfunint
}