local _M={}
-----------------------------------------------------------------------------------
local function IsContain(table, value)
    for i, v in pairs(table) do
        if v == value then
            return true
        end
    end

    return false
end
-----------------------------------------------------------------------------------
local function _IsPredictOK(vPredict)
    local Type = type(vPredict)
    if "function" == Type then
        return pcall(vPredict)
    elseif "table" ~= Type then
        return not not vPredict
    end

    --table    
    for i,v in pairs(vPredict) do
        if false == _IsPredictOK(v) then
            return false
        end  
    end
    return true
end
-----------------------------------------------------------------------------------
local function InsertWithPredict(vTable, vValue, vPredict)
	local predict = _IsPredictOK(vPredict)
    if not predict then
        return
    end

	vTable[#vTable+1]=vValue
end
-----------------------------------------------------------------------------------
local function GetURI(url)
    local ret = url 
    local s,e = string.find(url, "?")
    if s then
        ret = string.sub(t.REQUEST_URI, 1, s-1)
    end

    return ret
end
-----------------------------------------------------------------------------------
--export
_M.IsContain            = IsContain
_M.GetURI               = GetURI
_M.InsertWithPredict    = InsertWithPredict


-----------------------------------------------------------------------------------
local function init()
    return true
end
-----------------------------------------------------------------------------------
init()
return _M
