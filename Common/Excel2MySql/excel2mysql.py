#!/usr/bin/env python
# -*- coding: utf-8 -*-

import xlrd
import pymysql
import json
import re
import time

CONFIG = {}
DB = None


def init():
    global CONFIG
    CONFIG = get_config()


def get_config(local_config="config"):
    try:
        with open('./' + local_config + '.json', 'r', -1, 'utf-8') as f:
            config_data = json.load(f)
        return config_data
    except json.decoder.JSONDecodeError:
        print("<Error>: 校验配置文件<%s.json>格式失败!" % local_config)
        print("[ tips ] 请确认<%s.json>为合法json格式!" % local_config)
    except UnicodeDecodeError:
        print("<Error>: 校验配置文件<%s.json>编码格式失败!" % local_config)
        print("[ tips ] 请确认<%s.json>编码格式为utf-8!" % local_config)
    except IOError:
        print("<Error>: 读取配置文件<%s.json>失败!" % local_config)
        print("[ tips ] 请重新尝试读取<%s.json>!" % local_config)
    return None


def get_mysql(db_set=None):
    if db_set is None:
        db_set = CONFIG['mysql']
    try:
        conn = pymysql.connect(host=db_set['host'], port=db_set['port'],
                               user=db_set['username'], passwd=db_set['password'],
                               db=db_set['database'], charset=db_set['charset'])
        return conn
    except:
        print("<Error>: 尝试连接到mysql服务器<%s:%d>失败!" % (db_set['host'], db_set['port']))
        return None


def get_sheet_data(sheet_name=''):
    if sheet_name == '':
        sheet_name = CONFIG['default_sheet_name']
    try:
        book = xlrd.open_workbook(CONFIG['excel_file'])
        try:
            sheet = book.sheet_by_name(sheet_name)
            return sheet
        except:
            print("<Error>: 加载工作簿<%s>失败!" % CONFIG['default_sheet_name'])
    except:
        print("<Error>: 打开Excel文件<%s>失败!" % CONFIG['excel_file'])
    return None


def mysql_query(query_str):
    if DB is not None:
        cursor = DB.cursor()
        cursor.execute(query_str)
        rows = cursor.fetchall()
        cursor.close()
    else:
        return None
    return rows


def copy_sheet_to_table(sheet_name=''):
    if sheet_name == '':
        sheet_name = CONFIG['default_sheet_name']
    # 建表
    ret_msg = "尝试从本地文件 <%s> 的 <%s> 工作簿中读取数据失败! 进程已终止" % (CONFIG['excel_file'], sheet_name)
    sheet = get_sheet_data(sheet_name)
    table_name = sheet_name.lower() + time.strftime("_%y%m%d_%H%M%S", time.localtime())
    create_table_str = "CREATE TABLE %s (" % table_name
    create_table_str += "`%s_pk_main` INT UNSIGNED AUTO_INCREMENT, " % sheet_name.lower()
    columns_name = ""
    if sheet is not None:
        for sheet_column in sheet.row_values(0):
            pattern = r'[ \-=\[\]\\;\',./!@#\$%\^&\*\(\)_\+{}\|:"<>\?]'
            table_column = re.compile(pattern).sub('_', sheet_column).lower()
            create_table_str += "`%s` VARCHAR(255), " % table_column
            columns_name += "`%s`, " % table_column
        columns_name = columns_name.rstrip().rstrip(',')
        create_table_str += "PRIMARY KEY ( `%s_pk_main` ));" % sheet_name.lower()
        mysql_query(create_table_str)
    else:
        return False, ret_msg
    # 写入数据
    print("<Info> : 从本地文件 <%s> 的 <%s> 工作簿中读取数据成功! 正在写入数据库..." % (CONFIG['excel_file'], sheet_name))
    sheet = get_sheet_data(sheet_name)
    cursor = DB.cursor()
    format_str = ""
    for col in range(sheet.ncols):
        format_str += "%s, "
    execute_sql = "INSERT INTO %s (%s) VALUES (%s);" % (table_name, columns_name, format_str.rstrip().rstrip(','))
    for row in range(1, sheet.nrows):  # 第一行是标题名 对应表中的字段名所以应该从第二行开始
        values_sql = ""
        values = ()
        for col in range(sheet.ncols):
            if isinstance(sheet.cell(row, col).value, str):
                value = sheet.cell(row, col).value.strip()
                values_sql += "'%s', " % value
            else:
                value = sheet.cell(row, col).value
                values_sql += "'%s', " % str(value)
            values += (value,)
        values_sql = values_sql.rstrip().rstrip(',')
        query_sql = "INSERT INTO %s (%s) VALUES (%s);" % (table_name, columns_name, values_sql)
        # mysql_query(query_sql)  # 直接执行完整的mysql查询操作
        cursor.execute(execute_sql, values)  # 利用execute()的第二个参数完成插入
        # 以上两种插入方式二选一即可
        DB.commit()
    cursor.close()
    ret_msg = "成功将数据导入到 <%s> 数据库的 <%s> 表" % (CONFIG['mysql']['database'], table_name)
    return True, ret_msg


def main():
    global DB
    init()
    DB = get_mysql()
    if DB is not None:
        res, msg = copy_sheet_to_table()
        if res:
            print("<Info> : %s!" % msg)
        else:
            print("<Error>: %s!" % msg)
        DB.close()


if __name__ == "__main__":
    main()

"""
以下函数已废弃 可直接删除无任何影响 留下仅供参考命名
"""


def insert_cpu():
    sheet = get_sheet_data()
    col_data = sheet.row_values(0)
    print(col_data)
    cursor = db.cursor()
    for i in range(1, sheet.nrows):
        manufacturer = sheet.cell(i, 2).value
        name = sheet.cell(i, 3).value
        price = int(sheet.cell(i, 4).value)
        sell_price = int(sheet.cell(i, 5).value)
        rank = int(sheet.cell(i, 8).value)
        buy_value = sheet.cell(i, 9).value  # 性价比
        frequency = int(sheet.cell(i, 10).value)  # 频率
        cores = int(sheet.cell(i, 11).value)  # 核心数
        if sheet.cell(i, 12).value == 'Yes':
            overclock = True
        else:
            overclock = False
        wattage = int(sheet.cell(i, 13).value)  # 功率
        voltage = sheet.cell(i, 14).value  # 电压
        memory_speed = int(sheet.cell(i, 15).value)  # 默认内存速度
        socket = sheet.cell(i, 17).value  # 接口类型
        value = (manufacturer, name, price, sell_price, rank, buy_value, frequency, cores, overclock, wattage, voltage,
                 memory_speed, socket)
        sql = "INSERT INTO PCBS_CPUs(manufacturer,name,price, sell_price, rank, buy_value, frequency, cores, overclock, wattage, voltage,memory_speed, socket)VALUES(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)"
        cursor.execute(sql, value)
        db.commit()
    cursor.close()


def insert_gpu():
    sheet = open_excel("GPUs")
    col_data = sheet.row_values(0)
    print(col_data)
    cursor = db.cursor()
    for i in range(1, sheet.nrows):
        # TODO 所有字符串前后去除空格 cpu同理
        chipset = sheet.cell(i, 1).value  # 芯片组
        manufacturer = sheet.cell(i, 3).value  # 取第i行第0列
        name = sheet.cell(i, 4).value  # 取第i行第1列，下面依次类推
        price = int(sheet.cell(i, 5).value)
        sell_price = int(sheet.cell(i, 6).value)
        rank = int(sheet.cell(i, 9).value)
        buy_value = sheet.cell(i, 10).value  # 性价比
        vram = int(sheet.cell(i, 11).value)  # 显存
        slot_size = int(sheet.cell(i, 12).value)  # 插槽尺寸
        wattage = int(sheet.cell(i, 13).value)  # 功率
        size = int(sheet.cell(i, 14).value)  # 尺寸
        core_freq = int(sheet.cell(i, 15).value)  # 核心频率
        memory_freq = int(sheet.cell(i, 16).value)  # 内存频率
        multi_gpu = sheet.cell(i, 17).value  # 交火模式
        light = sheet.cell(i, 20).value  # 灯光
        value = (chipset, manufacturer, name, price, sell_price, rank, buy_value, vram, slot_size, wattage, size,
                 core_freq, memory_freq, multi_gpu, light)
        print(value)
        sql = "INSERT INTO PCBS_GPUs(chipset, manufacturer, name, price, sell_price, rank, buy_value, vram, slot_size, wattage, size,core_freq, memory_freq, multi_gpu, light)VALUES(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)"
        cursor.execute(sql, value)
        db.commit()
    cursor.close()
