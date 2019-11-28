local _M={}
local utility = require("utility")

-----------------------------------------------------------------------------------
--特殊uri处理
local uriRegular = {
       {
            regular="^/mvplay/%d+",
            url="index.php?action=videoPlay"
       },
       {
            regular="^/pk/%d+",
            url="index.php?action=pkRoom"
        },
        {
            regular="^/e/pk/%d+",
            url="index.php?action=pkRoom"
        },
        {
            regular="^/VServices/(%w+.%w+.%w+)/?",
            url="/VServices/{replacestr}/"
        }
}
local function process_msg_uri(url,uri) 
    --特殊转换URL,PK房和MV的URI处理
    for k, str in pairs(uriRegular) do
      local regularResult = string.match(uri, str["regular"])
      if regularResult ~= nil then
          uri = string.gsub(str["url"], "{replacestr}", regularResult)
          break
      end
    end
 
    local urlArgsTable = {}
    --rpc.php特殊处理
    local findResult,e = string.find(uri, "[rpc.php|Services.php|index.php]")
    if findResult then
        local uriTable = parseUrlString(uri)
        if uriTable["api"] then
            table.insert(urlArgsTable, "api="..uriTable["api"])
        end
        if uriTable["act"] then
            table.insert(urlArgsTable, "act="..uriTable["act"])
        end
        if uriTable["mtd"] then
            table.insert(urlArgsTable, "mtd="..uriTable["mtd"])
        end
        if uriTable["action"] then
            table.insert(urlArgsTable, "action="..uriTable["action"])
        end
    end

    --get uri
    local s,e = string.find(uri, "?")
    if s then
        uri = string.sub(uri, 1, s-1)
    end
    
    if url == "/live.php" or url == "/embedLive.php" or url == "/clanLive.php" then
        url = url
    elseif #urlArgsTable > 0 then
        local urlArgsStr = table.concat(urlArgsTable, "&")
        url = uri.."?"..urlArgsStr
    else
        url = uri
    end

    return url,uri
end
-----------------------------------------------------------------------------------
--URI状态处理
local function request_end_status(url,code)
    if code >= 400 and utility.IsContain({"/postEvent.php","/postActivityLog.php","/postClientData.php"}, url) ~= true then
        return "1"
    end
    return "0"
end

-----------------------------------------------------------------------------------
--export
_M.process_msg_uri            = process_msg_uri
_M.request_end_status         = request_end_status

-----------------------------------------------------------------------------------
local function init()
    return true
end
-----------------------------------------------------------------------------------

return _M