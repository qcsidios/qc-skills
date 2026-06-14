#!/usr/bin/env bash
# 归档路径.sh — 根据当前时间确定对话存档的目标文件
# 用法: bash AI协作工具/scripts/归档路径.sh
# 输出: 归档日期、目标文件路径、操作类型（追加/新建）
#
# 规则: 6点为界。6点前属于前一天归档日，6点后属于当天归档日。

set -uo pipefail

PROJECT="/Users/chenyilin/Documents/青城的知识树"
ARCHIVE_DIR="$PROJECT/00-运转日志/对话记录"

HOUR=$(date +%H)
MINUTE=$(date +%M)

if [ "$HOUR" -lt 6 ]; then
    # 6点前：归档日 = 昨天
    ARCHIVE_DATE=$(date -v-1d +%Y-%m-%d)
    TIME_NOTE="凌晨 $(printf '%02d:%02d' "$HOUR" "$MINUTE")，属于前一天归档日"
else
    # 6点后：归档日 = 今天
    ARCHIVE_DATE=$(date +%Y-%m-%d)
    TIME_NOTE="$(printf '%02d:%02d' "$HOUR" "$MINUTE")，属于当天归档日"
fi

# 查找归档日的已有文件
EXISTING_FILES=("$ARCHIVE_DIR/$ARCHIVE_DATE"*.md)

if [ -e "${EXISTING_FILES[0]}" ]; then
    FILE_COUNT=${#EXISTING_FILES[@]}
    if [ "$FILE_COUNT" -eq 1 ]; then
        TARGET_FILE="${EXISTING_FILES[0]}"
        ACTION="追加"
    else
        # 多个文件：选最新的
        TARGET_FILE=$(ls -t "${EXISTING_FILES[@]}" | head -1)
        ACTION="追加（注意：归档日有 ${FILE_COUNT} 个文件，应考虑合并）"
    fi
else
    TARGET_FILE="$ARCHIVE_DIR/${ARCHIVE_DATE}-主题关键词.md"
    ACTION="新建"
fi

echo "归档日期: $ARCHIVE_DATE"
echo "当前时间: $TIME_NOTE"
echo "目标文件: $TARGET_FILE"
echo "操作类型: $ACTION"
