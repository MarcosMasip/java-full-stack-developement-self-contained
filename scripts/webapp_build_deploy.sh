#!/usr/bin/env bash
set -euo pipefail

# Usage: webapp_build_deploy.sh "<module_dir>" "<context_name>"
# Example: webapp_build_deploy.sh "EXPERIMENT 6" exp6

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <module_dir> <context_name>" >&2
  exit 2
fi

MODULE_DIR="$1"
CONTEXT_NAME="$2"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ABS_MODULE="$(cd "$ROOT_DIR/$MODULE_DIR" && pwd)"
WEBAPP_DIR="$ABS_MODULE/src/main/webapp"
JAVA_SRC_DIR="$ABS_MODULE/src/main/java"
CLASSES_DIR="$WEBAPP_DIR/WEB-INF/classes"

echo "[webapp] Module: $ABS_MODULE"

if [[ ! -d "$WEBAPP_DIR" ]]; then
  echo "[webapp] ERROR: $WEBAPP_DIR not found" >&2
  exit 1
fi

# Resolve Tomcat home (same logic as other script)
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
  echo "[webapp] ERROR: Could not locate Tomcat. Set TOMCAT_HOME or CATALINA_HOME (or TOMCAT_LIBEXEC on macOS)." >&2
  exit 1
fi

echo "[webapp] Tomcat: $TOMCAT_HOME"

# Find servlet API jar
SERVLET_JAR=""
if [[ -f "$TOMCAT_HOME/lib/servlet-api.jar" ]]; then
  SERVLET_JAR="$TOMCAT_HOME/lib/servlet-api.jar"
elif [[ -f "$TOMCAT_HOME/lib/jakarta.servlet-api.jar" ]]; then
  SERVLET_JAR="$TOMCAT_HOME/lib/jakarta.servlet-api.jar"
fi

# Optionally compile servlets if Java sources exist
if [[ -d "$JAVA_SRC_DIR" ]] && compgen -G "$JAVA_SRC_DIR/**/*.java" >/dev/null 2>&1 || find "$JAVA_SRC_DIR" -name '*.java' | grep -q . 2>/dev/null; then
  if [[ -z "$SERVLET_JAR" ]]; then
    echo "[webapp] ERROR: No servlet API jar found; cannot compile servlets." >&2
    exit 1
  fi
  mkdir -p "$CLASSES_DIR"

  # Build classpath: servlet-api + all jars under WEB-INF/lib
  CP="$SERVLET_JAR"
  if [[ -d "$WEBAPP_DIR/WEB-INF/lib" ]]; then
    for j in "$WEBAPP_DIR"/WEB-INF/lib/*.jar; do
      [[ -f "$j" ]] && CP="$CP:$j"
    done
  fi

  echo "[webapp] Compiling Java sources..."
  find "$JAVA_SRC_DIR" -name "*.java" -print0 | xargs -0 javac -cp "$CP" -d "$CLASSES_DIR"
  echo "[webapp] Compile OK"
else
  echo "[webapp] No Java sources detected. Skipping compile."
fi

# Deploy webapp to Tomcat
TARGET_APP="$TOMCAT_HOME/webapps/$CONTEXT_NAME"
echo "[webapp] Deploying to $TARGET_APP ..."
rm -rf "$TARGET_APP"
mkdir -p "$TARGET_APP"
if command -v rsync >/dev/null 2>&1; then
  rsync -a "$WEBAPP_DIR/" "$TARGET_APP/"
else
  (cd "$WEBAPP_DIR" && tar cf - .) | (cd "$TARGET_APP" && tar xpf -)
fi

echo "[webapp] Deployed. Visit: http://localhost:8080/$CONTEXT_NAME/"
