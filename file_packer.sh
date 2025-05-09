#!/bin/bash

# 设置要打包的文件目录
DIR="/home/xu/Documents/log"
BAK_DIR="/home/xu/Documents/log_bak"
TMP_FILE="/tmp/file_packer.tmp"

cd $DIR
# 获取一个月前的日期
MONTH_AGO=$(date -d "30 days ago" +%Y-%m-%d)

# 遍历一个月前的每一天
for day in $(seq 0 290); do
    # 计算当前循环的日期
    CURRENT_DATE=$(date -d "$MONTH_AGO -$day days" +%Y-%m-%d)

    # 查找该日期的文件并打包
    find . -type f -newermt "$CURRENT_DATE 00:00:00" ! -newermt "$CURRENT_DATE 23:59:59" -print0 > $TMP_FILE

    if [ -s $TMP_FILE ]; then
        # 打包文件
        tar -cf "$BAK_DIR/$CURRENT_DATE.tar" --null -T $TMP_FILE
        echo "打包 $CURRENT_DATE 的文件到 $CURRENT_DATE.tar"
	while IFS= read -r -d '' line; do
		rm "$line"
	done < <(tr '\n' '\0' < "$TMP_FILE")
    else
        echo "$CURRENT_DATE 没有文件"
    fi
done
