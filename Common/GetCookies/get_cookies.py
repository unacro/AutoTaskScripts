import os
import json
import base64
import sqlite3
import time
from win32.win32crypt import CryptUnprotectData
from cryptography.hazmat.primitives.ciphers.aead import AESGCM
import requests

UPLOAD_API = ""
UPLOAD_KEY = ""


def mkdir(path):
    path = path.strip()  # 去除首尾空格
    path = path.rstrip("/")  # 去除尾部 / 符号
    path = path.rstrip("\\")  # 去除尾部 \ 符号
    existed = os.path.exists(path)
    if not existed:
        os.makedirs(path)
        return True
    else:
        return False


def print_result(msg):
    print(f"[{time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(time.time()))}] [INFO] {msg}")


def read_config(config_path="./config.json"):
    try:
        with open(config_path, 'r', -1, 'utf-8') as f:
            config = json.load(f)
        print_result(f"读取 {config_path} 成功!")
        return config
    except json.decoder.JSONDecodeError:
        print_result("校验 json 文件格式失败")
    except UnicodeDecodeError:
        print_result("校验配置文件编码格式失败")
    except IOError:
        print_result("读取配置文件失败")
    return None


def get_cookie_from_chrome(host, plain=True):
    """
    从本地 Chrome 加密的 cookie 文件中读取明文 cookie 数据
    注意: 如果输出字典格式(plain=False) 某些字段可能自带双引号(可能会导致转 json 出错)
        后续注意相应处理 原因详情自行查询 "cookie 多出双引号"
    :param host: 指定某个网站
    :param plain: (optional) 获取的 cookie 明文是否以 plain 格式输出 True=输出字符串 False=输出字典
    :return cookies: <class 'dict'> or <class 'str'> 返回的明文 cookie
    """
    local_state_path = os.environ['LOCALAPPDATA'] + r'\Google\Chrome\User Data\Local State'
    cookie_path = os.environ['LOCALAPPDATA'] + r"\Google\Chrome\User Data\Default\Cookies"

    def pull_the_key(base64_encrypted_key):
        encrypted_key_with_header = base64.b64decode(base64_encrypted_key)
        encrypted_key = encrypted_key_with_header[5:]
        real_key = CryptUnprotectData(encrypted_key, None, None, None, 0)[1]
        return real_key

    def decrypt_string(origin_key, data):
        nonce, cipher_bytes = data[3:15], data[15:]
        aesgcm_key = AESGCM(origin_key)
        plain_bytes = aesgcm_key.decrypt(nonce, cipher_bytes, None)
        plain_text = plain_bytes.decode('utf-8')
        return plain_text

    with sqlite3.connect(cookie_path) as conn:
        cu = conn.cursor()
        sql = f"select host_key,name,encrypted_value from cookies where host_key='{host}'"
        origin_cookies = cu.execute(sql).fetchall()
        cu.close()
        cookies = {}
        with open(local_state_path, 'r', encoding='utf-8') as f:
            local_state = json.load(f)['os_crypt']['encrypted_key']
        key = pull_the_key(local_state)
        for host_key, name, encrypted_value in origin_cookies:
            if encrypted_value[0:3] == b'v10':
                cookies[name] = decrypt_string(key, encrypted_value)
            else:
                cookies[name] = CryptUnprotectData(encrypted_value)[1].decode()
        if plain:
            temp = ""
            for k, v in cookies.items():
                temp += f"{k}={v}; "
            cookies = temp.strip('; ')
        return cookies


def pre_handle(url):
    if url[:8] == 'https://':
        url = url[8:].strip('/')
    elif url[:7] == 'http://':
        url = url[7:].strip('/')
    if url.count('.') < 2:
        url = f".{url}"
    return url


def upload_cookie(site):
    def post_data(post_url, data):
        resp_temp = None
        try:
            r = requests.post(post_url, data, timeout=10)
            resp_temp = r.text
            r.raise_for_status()
            r.encoding = r.apparent_encoding
        except requests.exceptions.HTTPError as e:
            print("<Warn>  ", e)
        except Exception as e:
            print("<Error> ", e)
        return resp_temp

    url = pre_handle(site)
    # TODO 如需上传 cookie 至服务器 自行构造相关数据结构
    resp_text = post_data(UPLOAD_API, {
        'site': url,
        'cookies': get_cookie_from_chrome(url),
        'password': UPLOAD_KEY
    })
    resp = json.loads(resp_text)
    # TODO 当然 拿回响应结果如何解析也要自己写
    if int(resp['code']) == 0:
        print_result(f"<{url}> upload success")
        return True
    else:
        print_result(f"<{url}> {resp['data']['info']}: {resp['msg']}")
        return False


def download_cookie(site):
    url = pre_handle(site)
    mkdir("./cookies")
    save_path = f"./cookies/{url}.txt"
    try:
        with open(save_path, "w", encoding='utf-8') as f:
            f.write(get_cookie_from_chrome(url))
        print_result(f"成功将 {url} 的 cookie 保存到本地")
    except IOError:
        print_result(f"保存 {url} 的 cookie 到本地失败")


if __name__ == '__main__':
    config = read_config()
    UPLOAD_API = config['UPLOAD_API']
    UPLOAD_KEY = config['UPLOAD_KEY']
    upload_cookie("www.v2ex.com")
    upload_cookie("www.douyu.com")
    download_cookie("https://www.baidu.com")
    download_cookie("http://baidu.com")
