import ctypes
drive = ctypes.WinDLL(r'drive/x64/DD.dll')
print(drive)
for i in 'DD.dll(x64) enabled':
    drive.DD_str(i)

# 64位的 Python 只能测 64位的驱动
# 32位的驱动引入即报错 OSError: [WinError 193] %1 不是有效的 Win32 应用程序。
