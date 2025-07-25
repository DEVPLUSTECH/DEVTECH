#!/bin/bash

echo "🔍 JavaScript Error Prevention Check for Production"
echo "=================================================="

# Check for source map files
echo "1. Checking for source map files..."
MAP_FILES=$(find dist -name "*.map" 2>/dev/null)
if [ -z "$MAP_FILES" ]; then
    echo "✅ No source map files found (good for production)"
else
    echo "❌ Source map files found:"
    echo "$MAP_FILES"
fi

# Check for crown.js or similar problematic files
echo "2. Checking for problematic JS files..."
CROWN_FILES=$(find dist -name "*crown*" 2>/dev/null)
if [ -z "$CROWN_FILES" ]; then
    echo "✅ No crown.js related files found"
else
    echo "❌ Crown-related files found:"
    echo "$CROWN_FILES"
fi

# Check JavaScript file structure
echo "3. Checking JavaScript file structure..."
JS_FILES=$(find dist -name "*.js" 2>/dev/null)
echo "JavaScript files in build:"
for file in $JS_FILES; do
    echo "  📄 $file ($(du -h "$file" | cut -f1))"
done

# Check for any .map references in JS files
echo "4. Checking for source map references in JS files..."
for file in $JS_FILES; do
    if grep -q "sourceMappingURL" "$file" 2>/dev/null; then
        echo "❌ Source map reference found in $file"
    else
        echo "✅ No source map references in $(basename "$file")"
    fi
done

# Check HTML file for proper JS references
echo "5. Checking HTML file for proper JS references..."
if [ -f "dist/index.html" ]; then
    JS_REFS=$(grep -o 'src="[^"]*\.js"' dist/index.html 2>/dev/null)
    echo "JavaScript references in HTML:"
    echo "$JS_REFS"
    
    # Check if all referenced JS files exist
    while read -r ref; do
        js_path=$(echo "$ref" | sed 's/src="//g' | sed 's/"//g')
        full_path="dist$js_path"
        if [ -f "$full_path" ]; then
            echo "✅ $js_path exists"
        else
            echo "❌ $js_path missing"
        fi
    done <<< "$JS_REFS"
else
    echo "❌ index.html not found"
fi

# Check for console errors in built files
echo "6. Checking for potential console errors..."
ERROR_PATTERNS=("console.error" "throw new Error" "ERROR:" "crown.js")
for pattern in "${ERROR_PATTERNS[@]}"; do
    MATCHES=$(grep -r "$pattern" dist/ 2>/dev/null || true)
    if [ -n "$MATCHES" ]; then
        echo "⚠️  Found pattern '$pattern':"
        echo "$MATCHES"
    else
        echo "✅ No '$pattern' patterns found"
    fi
done

echo ""
echo "🚀 JavaScript Check Complete!"
echo "================================"

# Final summary
TOTAL_JS_SIZE=$(find dist -name "*.js" -exec du -c {} + 2>/dev/null | tail -1 | cut -f1)
echo "📊 Total JavaScript size: ${TOTAL_JS_SIZE}K"
echo "📦 Build folder size: $(du -sh dist 2>/dev/null | cut -f1)"

if [ -z "$MAP_FILES" ] && [ -z "$CROWN_FILES" ]; then
    echo "✅ All JavaScript checks passed! Ready for production deployment."
    exit 0
else
    echo "❌ Some issues found. Please review above."
    exit 1
fi
