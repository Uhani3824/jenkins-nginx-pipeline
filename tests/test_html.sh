#!/bin/bash
# ─────────────────────────────────────────────────────────
#  test_html.sh — Basic HTML validation tests
#  Called by Jenkins in the Test stage
# ─────────────────────────────────────────────────────────

PASS=0
FAIL=0
HTML_FILE="src/index.html"

echo "=============================="
echo " Running HTML validation tests"
echo "=============================="

# Helper functions
pass() { echo "  ✅ PASS: $1"; PASS=$((PASS+1)); }
fail() { echo "  ❌ FAIL: $1"; FAIL=$((FAIL+1)); }

# ── Test 1: index.html exists ──────────────────────────
if [ -f "$HTML_FILE" ]; then
  pass "index.html exists"
else
  fail "index.html not found"
fi

# ── Test 2: Has DOCTYPE declaration ───────────────────
if grep -q "<!DOCTYPE html>" "$HTML_FILE"; then
  pass "DOCTYPE declaration present"
else
  fail "DOCTYPE declaration missing"
fi

# ── Test 3: Has <title> tag ────────────────────────────
if grep -q "<title>" "$HTML_FILE"; then
  pass "<title> tag present"
else
  fail "<title> tag missing"
fi

# ── Test 4: Has <meta charset> ────────────────────────
if grep -q "charset" "$HTML_FILE"; then
  pass "charset meta tag present"
else
  fail "charset meta tag missing"
fi

# ── Test 5: Dockerfile exists ─────────────────────────
if [ -f "Dockerfile" ]; then
  pass "Dockerfile exists"
else
  fail "Dockerfile not found"
fi

# ── Test 6: nginx.conf exists ─────────────────────────
if [ -f "nginx.conf" ]; then
  pass "nginx.conf exists"
else
  fail "nginx.conf not found"
fi

# ── Test 7: HTML file is not empty ────────────────────
if [ -s "$HTML_FILE" ]; then
  pass "index.html is not empty"
else
  fail "index.html is empty"
fi

# ── Test 8: Has closing </html> tag ───────────────────
if grep -q "</html>" "$HTML_FILE"; then
  pass "Closing </html> tag present"
else
  fail "Closing </html> tag missing"
fi

# ── Summary ───────────────────────────────────────────
echo ""
echo "=============================="
echo " Results: $PASS passed, $FAIL failed"
echo "=============================="

if [ "$FAIL" -gt 0 ]; then
  echo " ❌ Tests failed — fix issues above"
  exit 1
else
  echo " ✅ All tests passed!"
  exit 0
fi
