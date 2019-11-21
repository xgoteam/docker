local _M = {}
_M.conn_time = {1000}
_M.response_time = {1000}
_M.slow_query_us = 1000
_M.slow_query_max = 10
_M.err_query_max = 10
_M.method_list = {
    set = "set",
    get = "get",
    mget = "mget", 
    mset = "mset", 
    hmet = "hmget", 
    hmget = "hmset",
    setex = "setex",
    zAdd = "zAdd",
    zRange = "zRange",
    sAdd = "sAdd",
    sPop = "sPop",
    lRange =  "lRange",
    lPush = "lPush",
    zrevrangebyscore =  "zrevrangebyscore",
    smembers  = "smembers",
    del = "del",
    zCount = "zCount",
    keys = "keys",
    lpush = "lpush",
    lLen = "lLen",
    zCard = "zCard",
    delete = "delete", 
    hLen = "hLen",
    incr = "incr",
    decr = "decr",
    discard = "discard",
    zrem = "zrem",
    zDelete = "zDelete",
}
return _M
