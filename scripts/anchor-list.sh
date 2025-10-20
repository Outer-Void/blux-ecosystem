#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# BLUX Anchor Listing Script
# Finds and displays all development anchors in the codebase

SEARCH_PATTERN="${1:-}"
VERBOSE=false
GROUP_BY_FILE=false
SHOW_CONTEXT=false

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }

show_usage() {
    echo "Usage: $0 [OPTIONS] [pattern]"
    echo ""
    echo "Find and display development anchors in the codebase"
    echo ""
    echo "Options:"
    echo "  --group-by-file    Group anchors by file"
    echo "  --show-context     Show context around anchors"
    echo "  --verbose          Verbose output"
    echo "  --help             Show this help"
    echo ""
    echo "Pattern:"
    echo "  Optional grep pattern to filter anchors"
    echo ""
    echo "Examples:"
    echo "  $0                          # List all anchors"
    echo "  $0 auth                     # List anchors containing 'auth'"
    echo "  $0 --group-by-file          # List anchors grouped by file"
    echo "  $0 --show-context security  # Show security anchors with context"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --group-by-file)
            GROUP_BY_FILE=true
            shift
            ;;
        --show-context)
            SHOW_CONTEXT=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --help)
            show_usage
            exit 0
            ;;
        -*)
            echo "Unknown option: $1"
            show_usage
            exit 1
            ;;
        *)
            SEARCH_PATTERN="$1"
            shift
            ;;
    esac
done

# Find anchors in the codebase
find_anchors() {
    local pattern="ANCHOR:"
    local files=()
    
    # Use git if available, otherwise find
    if command -v git &> /dev/null && git rev-parse --is-inside-work-tree &> /dev/null; then
        if [ -n "$SEARCH_PATTERN" ]; then
            files=($(git grep -l "$pattern" -- "*.py" "*.js" "*.ts" "*.go" "*.rs" "*.java" "*.md" "*.yaml" "*.yml" "*.sh" | grep "$SEARCH_PATTERN" || true))
        else
            files=($(git grep -l "$pattern" -- "*.py" "*.js" "*.ts" "*.go" "*.rs" "*.java" "*.md" "*.yaml" "*.yml" "*.sh" || true))
        fi
    else
        if [ -n "$SEARCH_PATTERN" ]; then
            files=($(find . -type f \( -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.go" -o -name "*.rs" -o -name "*.java" -o -name "*.md" -o -name "*.yaml" -o -name "*.yml" -o -name "*.sh" \) -exec grep -l "$pattern" {} \; | grep "$SEARCH_PATTERN" || true))
        else
            files=($(find . -type f \( -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.go" -o -name "*.rs" -o -name "*.java" -o -name "*.md" -o -name "*.yaml" -o -name "*.yml" -o -name "*.sh" \) -exec grep -l "$pattern" {} \; || true))
        fi
    fi
    
    echo "${files[@]}"
}

# Extract anchors from a file
extract_anchors_from_file() {
    local file="$1"
    local anchors=()
    
    if [ "$SHOW_CONTEXT" = true ]; then
        echo
        echo -e "${PURPLE}=== $file ===${NC}"
        grep -n -A 2 -B 2 "ANCHOR:" "$file" | while IFS= read -r line; do
            if [[ "$line" == *"ANCHOR:"* ]]; then
                echo -e "${GREEN}$line${NC}"
            else
                echo "$line"
            fi
        done
    else
        while IFS= read -r line; do
            if [[ "$line" == *"ANCHOR:"* ]]; then
                local anchor_name
                anchor_name=$(echo "$line" | sed -n 's/.*ANCHOR: *\([^ ]*\).*/\1/p')
                local line_num
                line_num=$(echo "$line" | cut -d: -f1)
                anchors+=("$line_num:$anchor_name")
            fi
        done < <(grep -n "ANCHOR:" "$file")
        
        printf "%s\n" "${anchors[@]}"
    fi
}

# Display anchors grouped by file
show_anchors_grouped() {
    local files=($(find_anchors))
    local total_anchors=0
    
    echo "Development Anchors (Grouped by File)"
    echo "====================================="
    
    for file in "${files[@]}"; do
        local anchors
        anchors=($(extract_anchors_from_file "$file"))
        
        if [ ${#anchors[@]} -gt 0 ]; then
            echo
            echo -e "${PURPLE}$file${NC}"
            for anchor in "${anchors[@]}"; do
                local line_num
                line_num=$(echo "$anchor" | cut -d: -f1)
                local anchor_name
                anchor_name=$(echo "$anchor" | cut -d: -f2-)
                echo -e "  ${GREEN}L${line_num}:${NC} ${YELLOW}${anchor_name}${NC}"
                ((total_anchors++))
            done
        fi
    done
    
    echo
    echo "Total anchors found: $total_anchors"
}

# Display flat list of anchors
show_anchors_flat() {
    local files=($(find_anchors))
    local total_anchors=0
    
    echo "Development Anchors"
    echo "=================="
    
    for file in "${files[@]}"; do
        local anchors
        anchors=($(extract_anchors_from_file "$file"))
        
        for anchor in "${anchors[@]}"; do
            local line_num
            line_num=$(echo "$anchor" | cut -d: -f1)
            local anchor_name
            anchor_name=$(echo "$anchor" | cut -d: -f2-)
            echo -e "${GREEN}${file}:${line_num}${NC} - ${YELLOW}${anchor_name}${NC}"
            ((total_anchors++))
        done
    done
    
    echo
    echo "Total anchors found: $total_anchors"
}

main() {
    echo "🔍 BLUX Anchor Discovery"
    echo "========================"
    
    if [ -n "$SEARCH_PATTERN" ]; then
        log_info "Searching for anchors matching: $SEARCH_PATTERN"
    fi
    
    if [ "$GROUP_BY_FILE" = true ]; then
        show_anchors_grouped
    else
        show_anchors_flat
    fi
    
    if [ "$VERBOSE" = true ]; then
        echo
        log_info "Anchor usage:"
        echo "  Edit code within ANCHOR:name and ANCHOR_END:name blocks"
        echo "  Use for patch-based development workflow"
        echo "  See DEVELOPER_GUIDE.md for details"
    fi
}

main "$@"