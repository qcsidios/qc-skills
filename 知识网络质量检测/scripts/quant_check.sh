#!/bin/bash
# 知识网络质量检测 — 定量检测（步骤 1-5）
# 用法: bash quant_check.sh [知识树根目录]
# 默认根目录为脚本所在位置的 ../../../.. (即青城知识树根目录)

set -euo pipefail

ROOT="${1:-$(cd "$(dirname "$0")/../../../.." && pwd)}"
CARD_DIR="$ROOT/02-知识库/知识卡片"
MOC_DIR="$ROOT/02-知识库/MOC"
INDEX_FILE="$ROOT/02-知识库/index.md"
PERSONAL_DIR="$ROOT/01-关于我"

echo "=== 知识网络质量检测（定量） ==="
echo "根目录: $ROOT"
echo ""

# ── 第一步：结构完整度 ──────────────────────────────────────────

echo "── 第一步：结构完整度 ──"

# MOC 覆盖率
all_moc_cards=$(mktemp)
for moc in "$MOC_DIR"/*.md; do
    [ -f "$moc" ] || continue
    grep -oE '\[\[[^]]+\]\]' "$moc" | sed 's/\[\[//;s/\]\]//'
done | sort -u > "$all_moc_cards"

card_names=$(mktemp)
ls "$CARD_DIR"/*.md 2>/dev/null | sed 's|.*/||;s/\.md$//' | sort > "$card_names"

uncovered=$(comm -23 "$card_names" "$all_moc_cards")
uncovered_count=$(echo "$uncovered" | sed '/^$/d' | wc -l | tr -d ' ')
card_count=$(wc -l < "$card_names" | tr -d ' ')
moc_count=$(ls "$MOC_DIR"/*.md 2>/dev/null | wc -l | tr -d ' ')

if [ "$uncovered_count" -gt 0 ] 2>/dev/null; then
    echo "❌ MOC 未覆盖 ($uncovered_count 张):"
    echo "$uncovered" | sed 's/^/   /'
else
    echo "✅ MOC 覆盖率: $card_count/$card_count (100%)"
fi

# 死链
dead=0
for moc in "$MOC_DIR"/*.md; do
    [ -f "$moc" ] || continue
    while read -r link; do
        if echo "$link" | grep -q "^MOC-"; then
            test -f "$MOC_DIR/$link.md" || { echo "   死链 MOC: $(basename "$moc") → $link"; dead=$((dead+1)); }
        else
            test -f "$CARD_DIR/$link.md" || { echo "   死链 卡片: $(basename "$moc") → $link"; dead=$((dead+1)); }
        fi
    done < <(grep -oE '\[\[[^]]+\]\]' "$moc" | sed 's/\[\[//;s/\]\]//')
done
if [ "$dead" -eq 0 ]; then
    echo "✅ 死链: 0"
else
    echo "❌ 死链: $dead 条"
fi

# Index 覆盖 MOC
missing_idx=0
for moc_file in "$MOC_DIR"/*.md; do
    [ -f "$moc_file" ] || continue
    mname=$(basename "$moc_file" .md)
    if ! grep -q "$mname" "$INDEX_FILE" 2>/dev/null; then
        echo "   Index 缺失: $mname"
        missing_idx=$((missing_idx+1))
    fi
done
if [ "$missing_idx" -eq 0 ]; then
    echo "✅ Index 覆盖: $moc_count/$moc_count"
else
    echo "❌ Index 缺失: $missing_idx 个 MOC"
fi

rm -f "$all_moc_cards" "$card_names"

# ── 第二步：链接密度 ──────────────────────────────────────────

echo ""
echo "── 第二步：链接密度 ──"

total=0; count=0; low=0; low_cards=""
for card in "$CARD_DIR"/*.md; do
    [ -f "$card" ] || continue
    links=$(grep -oE '\[\[[^]]+\]\]' "$card" | wc -l | tr -d ' ')
    total=$((total+links)); count=$((count+1))
    if [ "$links" -le 2 ]; then
        low=$((low+1))
        low_cards="$low_cards  LOW($links): $(basename "$card")\n"
    fi
done
avg=$(echo "scale=2; $total/$count" | bc 2>/dev/null || echo "0")
echo "   平均链接: $avg"
echo "   ≤2链: $low 张"
if [ "$low" -gt 0 ]; then
    echo -ne "$low_cards"
fi

# ── 第三步：网络连通性 ────────────────────────────────────────

echo "── 第三步：网络连通性 ──"

iz=0; iz_cards=""
for card in "$CARD_DIR"/*.md; do
    [ -f "$card" ] || continue
    name=$(basename "$card" .md)
    refs=$(grep -l "\[\[$name\]\]" "$CARD_DIR"/*.md 2>/dev/null | wc -l | tr -d ' ')
    if [ "$refs" -eq 0 ]; then
        iz=$((iz+1))
        iz_cards="$iz_cards  IN=0: $name\n"
    fi
done
echo "   入度=0: $iz 张"
if [ "$iz" -gt 0 ]; then
    echo -ne "$iz_cards"
fi

echo "   跨MOC桥梁:"
for moc in "$MOC_DIR"/*.md; do
    [ -f "$moc" ] || continue
    mname=$(basename "$moc" .md)
    bridges=$(grep -oE '\[\[[^]]+\]\]' "$moc" | sed 's/\[\[//;s/\]\]//' | while read -r card; do
        echo "$card" | grep -q "^MOC-" && echo "$card"
    done | wc -l | tr -d ' ')
    echo "   $mname → $bridges 跨MOC"
done

# ── 第四步：语义质量 ──────────────────────────────────────────

echo ""
echo "── 第四步：语义质量 ──"

# typed link 越界
bad_typed=0
for card in "$CARD_DIR"/*.md; do
    [ -f "$card" ] || continue
    while read -r line; do
        echo "   BAD TYPED: $(basename "$card"): $line"
        bad_typed=$((bad_typed+1))
    done < <(awk '/\*\*相关链接\*\*/{in_links=1; next} /\*\*来源\*\*/{in_links=0} in_links && /^- / && !/^- 支撑/ && !/^- 应用于/ && !/^- 张力/ && !/^- 互见/ && !/^- 取代/' "$card")
done
if [ "$bad_typed" -eq 0 ]; then
    echo "✅ typed link 越界: 0"
else
    echo "❌ typed link 越界: $bad_typed 处"
fi

# source_type 分布
echo "   source_type 分布:"
grep -h "^source_type:" "$CARD_DIR"/*.md 2>/dev/null | sed 's/.*: //' | sort | uniq -c | sort -rn | sed 's/^/   /'

# status 分布
echo "   status 分布:"
grep -h "^status:" "$CARD_DIR"/*.md 2>/dev/null | sed 's/.*: //' | sort | uniq -c | sort -rn | sed 's/^/   /'

# 无来源标注
no_source=0
for card in "$CARD_DIR"/*.md; do
    [ -f "$card" ] || continue
    if ! grep -q "\*\*来源\*\*" "$card"; then
        echo "   NO SOURCE: $(basename "$card")"
        no_source=$((no_source+1))
    fi
done
if [ "$no_source" -eq 0 ]; then
    echo "✅ 全部有来源标注"
else
    echo "❌ 无来源: $no_source 张"
fi

# ── 第五步：01↔02 桥梁 ────────────────────────────────────────

echo ""
echo "── 第五步：01↔02 桥梁 ──"

bridges_01=$(for pf in "$PERSONAL_DIR"/*.md; do
    [ -f "$pf" ] || continue
    grep -oh '\[\[[^]]*\]\]' "$pf" 2>/dev/null || true
done | sed 's/\[\[//;s/\]\]//' | sort -u | while read -r name; do
    [ -n "$name" ] && [ -f "$CARD_DIR/$name.md" ] && echo "$name"
done | wc -l | tr -d ' ')
echo "   01→02: ${bridges_01:-0} 条"

bridges_02=$(grep -rl "01-关于我" "$CARD_DIR"/*.md 2>/dev/null | wc -l | tr -d ' ')
echo "   02→01: ${bridges_02:-0} 条"

echo ""
echo "=== 定量检测完成 ==="
