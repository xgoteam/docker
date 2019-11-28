local _M = {}

_M.conn_time = {1000}
_M.response_time = {1000}
_M.slow_query_max = 10
_M.slow_query_us = 10
_M.err_query_max = 10
_M.method_list = {
    addServer = "connect",
    addServers = "pconnect",
    get = "get",
    getByKey = "getByKey",
    getMulti = "getMulti",
    getMultiByKey = "getMultiByKey",
    getDelayed = "getDelayed",
    set = "set",
    setByKey = "setByKey",
    touch = "touch",
    touchByKey = "touchByKey",
    setMulti = "setMulti",
    setMultiByKey = "setMultiByKey",
    cas = "cas",
    add = "add",
    addByKey = "addByKey",
    append = "append",
    appendByKey = "appendByKey",
    prepend = "prepend",
    prependByKey = "prependByKey",
    replace = "replace",
    replaceByKey = "replaceByKey",
    delete = "delete",
    deleteByKey = "deleteByKey",
    deleteMultiByKey = "deleteMultiByKey",
}
return _M
