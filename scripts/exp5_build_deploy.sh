#!/usr/bin/env bash
set -euo pipefail

# Experiment 5: build and deploy to Tomcat
# - Compiles servlets to WEB-INF/classes
# - Detects Tomcat installation
# - Copies the webapp to Tomcat's webapps/exp5

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXP5_DIR="$ROOT_DIR/EXPERIMENT 5"
WEBAPP_DIR="$EXP5_DIR/src/main/webapp"
CLASSES_DIR="$WEBAPP_DIR/WEB-INF/classes"

echo "[exp5] Root: $ROOT_DIR"
echo "[exp5] Module: $EXP5_DIR"

# Resolve Tomcat home (libexec for Homebrew macOS; else CATALINA_HOME; else TOMCAT_HOME)
if [[ -n "${TOMCAT_LIBEXEC:-}" && -d "$TOMCAT_LIBEXEC" ]]; then
  TOMCAT_HOME="$TOMCAT_LIBEXEC"
elif [[ -n "${CATALINA_HOME:-}" && -d "$CATALINA_HOME" ]]; then
  TOMCAT_HOME="$CATALINA_HOME"
elif [[ -n "${TOMCAT_HOME:-}" && -d "$TOMCAT_HOME" ]]; then
  TOMCAT_HOME="$TOMCAT_HOME"
else
  if command -v brew >/dev/null 2>&1; then
    maybe_libexec="$(brew --prefix tomcat@10 2>/dev/null)/libexec"
    if [[ -d "$maybe_libexec" ]]; then
      TOMCAT_HOME="$maybe_libexec"
    fi
  fi
fi

if [[ -z "${TOMCAT_HOME:-}" || ! -d "$TOMCAT_HOME" ]]; then
  echo "[exp5] ERROR: Could not locate Tomcat. Set TOMCAT_HOME or CATALINA_HOME (or TOMCAT_LIBEXEC on macOS Homebrew)." >&2
  exit 1
fi

echo "[exp5] Tomcat: $TOMCAT_HOME"

# Locate servlet api jar (Tomcat 10 ships servlet-api.jar with jakarta packages)
SERVLET_JAR=""
if [[ -f "$TOMCAT_HOME/lib/servlet-api.jar" ]]; then
  SERVLET_JAR="$TOMCAT_HOME/lib/servlet-api.jar"
elif [[ -f "$TOMCAT_HOME/lib/jakarta.servlet-api.jar" ]]; then
  SERVLET_JAR="$TOMCAT_HOME/lib/jakarta.servlet-api.jar"
else
  echo "[exp5] ERROR: Could not find servlet-api jar in $TOMCAT_HOME/lib" >&2
  exit 1
fi

echo "[exp5] Using servlet API: $SERVLET_JAR"

# Ensure classes directory exists
mkdir -p "$CLASSES_DIR"

# Compile all Java sources (handle spaces safely)
MYSQL_JAR="$WEBAPP_DIR/WEB-INF/lib/mysql-connector-j-8.3.0.jar"
if [[ ! -f "$MYSQL_JAR" ]]; then
  echo "[exp5] ERROR: Missing MySQL driver at $MYSQL_JAR" >&2
  exit 1
fi

echo "[exp5] Compiling sources..."
find "$EXP5_DIR/src/main/java" -name "*.java" -print0 | \
  xargs -0 javac -cp "$SERVLET_JAR:$MYSQL_JAR" -d "$CLASSES_DIR"

echo "[exp5] Compile OK"

# Deploy to Tomcat webapps/exp5
TARGET_APP="$TOMCAT_HOME/webapps/exp5"
echo "[exp5] Deploying to $TARGET_APP ..."
rm -rf "$TARGET_APP"
mkdir -p "$TARGET_APP"

if command -v rsync >/dev/null 2>&1; then
  rsync -a "$WEBAPP_DIR/" "$TARGET_APP/"
else
  # Fallback copy
  (cd "$WEBAPP_DIR" && tar cf - .) | (cd "$TARGET_APP" && tar xpf -)
fi

echo "[exp5] Deployed. Visit: http://localhost:8080/exp5/Insert.jsp and /Search.jsp"
