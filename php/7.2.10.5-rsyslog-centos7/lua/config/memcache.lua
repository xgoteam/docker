local _M = {}

_M.conn_time = {1000}
_M.response_time = {1000}
_M.slow_query_max = 10
_M.slow_query_us = 10
_M.err_query_max = 10
_M.method_list = {
    memcache_connect = "connect",
    memcache_pconnect = "pconnect",
    memcache_add = "add",
    memcache_set = "set",
    memcache_replace = "replace",
    memcache_get = "get",
    memcache_delete = "delete",
    memcache_increment = "increment",
    memcache_decrement = "decrement",
    connect = "connect",
    pconnect = "pconnect",
    add = "add",
    set = "set",
    replace = "replace",
    get = "get",
    delete = "delete",
    increment = "increment",
    decrement = "decrement",
}
return _M
