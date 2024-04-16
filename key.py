
import hashlib

import rsa

def getSHA256Str(string, num):
    nonce1 = 0
    while True:
        nonce1 += 1
        str2 = string + str(nonce1)
        hash_value = hashlib.sha256(str2.encode("utf-8")).hexdigest()
        if hash_value.startswith('0' * num):
            return nonce1
def main():
    num = getSHA256Str('junge', 4)
    # 生成密钥对
    (public_key, private_key) = rsa.newkeys(1024)

    # 加密
    message = 'junge' + str(num)
    encrypted_message = rsa.encrypt(message.encode(), public_key)

    # 解密
    decrypted_message = rsa.decrypt(encrypted_message, private_key).decode()

    print(decrypted_message)  # 输出 message = 'junge' + str(num)

if __name__ == "__main__":
    # execute only if run as a script
    main()


