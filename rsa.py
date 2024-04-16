import hashlib
import time
def getSHA256Str(string,num):
    start_time = time.time()
    nonce1 = 0
    while True:
        nonce1 = nonce1 + 1
        str2 = string + str(nonce1)
        hash_value = hashlib.sha256(str2.encode("utf-8")).hexdigest()
        print(hash_value)
        if hash_value.startswith('0' * num):
           print(f"达到目标 {num} 个 0 开头的哈希值，花费时间: {time.time() - start_time} 秒")
           return hash_value
getSHA256Str("junge", 4)
getSHA256Str("junge", 5)