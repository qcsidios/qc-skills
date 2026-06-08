#!/bin/bash
# 知识网络质量检测 — TypeLink 质量结构分析（步骤 7）
# 用法: bash qual_check.sh [知识树根目录]

set -euo pipefail

ROOT="${1:-$(cd "$(dirname "$0")/../../../.." && pwd)}"
CARD_DIR="$ROOT/02-知识库/知识卡片"

echo "=== TypeLink 质量结构分析 ==="
echo "根目录: $ROOT"
echo ""

support=$(grep -ch "^- 支撑：" "$CARD_DIR"/*.md 2>/dev/null | paste -sd+ - 2>/dev/null | bc 2>/dev/null || echo 0)
apply=$(grep -ch "^- 应用于：" "$CARD_DIR"/*.md 2>/dev/null | paste -sd+ - 2>/dev/null | bc 2>/dev/null || echo 0)
tension=$(grep -ch "^- 张力：" "$CARD_DIR"/*.md 2>/dev/null | paste -sd+ - 2>/dev/null | bc 2>/dev/null || echo 0)
hujian=$(grep -ch "^- 互见：" "$CARD_DIR"/*.md 2>/dev/null | paste -sd+ - 2>/dev/null | bc 2>/dev/null || echo 0)
personal=$(grep -ch "^- 个人关联：" "$CARD_DIR"/*.md 2>/dev/null | paste -sd+ - 2>/dev/null | bc 2>/dev/null || echo 0)

total=$((support + apply + tension + hujian + personal))

if [ "$total" -eq 0 ]; then
    echo "❌ 未检测到任何 typed link"
    exit 1
fi

support_pct=$(echo "scale=0; $support*100/$total" | bc)
apply_pct=$(echo "scale=0; $apply*100/$total" | bc)
tension_pct=$(echo "scale=0; $tension*100/$total" | bc)
hujian_pct=$(echo "scale=0; $hujian*100/$total" | bc)
personal_pct=$(echo "scale=0; $personal*100/$total" | bc)
strong_pct=$(echo "scale=0; ($support+$apply)*100/$total" | bc)
hujian_ratio=$(echo "scale=1; $hujian/($support+$apply)" | bc 2>/dev/null || echo "N/A")

echo "| 类型 | 数量 | 占比 | 语义强度 |"
echo "|------|------|-----|---------|"
echo "| 支撑 | $support | ${support_pct}% | 强 |"
echo "| 应用于 | $apply | ${apply_pct}% | 强 |"
echo "| 张力 | $tension | ${tension_pct}% | 强 |"
echo "| 互见 | $hujian | ${hujian_pct}% | 弱 |"
echo "| 个人关联 | $personal | ${personal_pct}% | — |"
echo ""
echo "支撑+应用于: ${strong_pct}%"
echo "互见/(支撑+应用于): $hujian_ratio"
echo ""

# 判定
if [ "$hujian_pct" -le 35 ]; then
    echo "判定: 🟢 层级结构扎实，支撑+应用为主导"
elif [ "$hujian_pct" -le 50 ]; then
    echo "判定: 🟡 层级关系尚可，互见偏多但可控"
else
    echo "判定: 🔴 网络偏扁平，卡片知道彼此相关但层级关系不够丰富"
fi

if [ "$tension" -lt 30 ]; then
    echo "⚠️  张力链接 < 30 条，网络缺乏边界标注"
fi
