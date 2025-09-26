# java-full-stack-developement (self-contained)

This repo is now fully runnable locally (macOS, Linux, Windows) with no external API calls.

What you get
- A working full-stack Java web app (Experiment 5: JSP/Servlets + MySQL) you can run locally
- Static demo (Calculator)
- Several Java console experiments

We use Tomcat 10+ (Jakarta Servlet) and MySQL in Docker for portability. Everything runs on your machine; no cloud accounts needed.

-------------------------------------------------------------------------------
Quick start (copy/paste)
-------------------------------------------------------------------------------

macOS or Linux
1) Install Java + Tomcat 10 + Docker
	- Java: ensure `java -version` prints a version (OpenJDK 17+ recommended)
	- macOS: `brew install --cask temurin && brew install tomcat@10`
	- Linux: use your package manager for Java; download Tomcat 10 from tomcat.apache.org and unzip; set CATALINA_HOME
	- Docker Desktop (macOS/Windows) or Docker Engine (Linux)

2) Start Tomcat
	macOS (Homebrew):
	- Start: `brew services start tomcat@10`
	- Tomcat home (used below): `export TOMCAT_LIBEXEC="$(brew --prefix tomcat@10)/libexec"`

	Linux/Windows: define Tomcat home
	- Linux: `export CATALINA_HOME=/path/to/apache-tomcat-10.x.x`
	- Windows PowerShell: `$env:CATALINA_HOME='C:\\path\\to\\apache-tomcat-10.x.x'`

	Verify: open http://localhost:8080 (Tomcat welcome page)

3) Start local MySQL (Docker) and create tables
	macOS/Linux:
	- `bash scripts/mysql_up.sh`

	Windows PowerShell:
	- Run Docker Desktop, then:
	  ```powershell
	  docker run --name mysql-3308 -e MYSQL_ROOT_PASSWORD='Akash@123' -p 3308:3306 -d mysql:8.0
	  docker exec -i mysql-3308 mysql -uroot -pAkash@123 @"-" <<'SQL'
	  CREATE DATABASE IF NOT EXISTS module2;
	  USE module2;
	  CREATE TABLE IF NOT EXISTS studentMarks (
		 rollno INT PRIMARY KEY,
		 name VARCHAR(255),
		 section VARCHAR(10),
		 sub1 INT, sub2 INT, sub3 INT, sub4 INT, sub5 INT, sub6 INT,
		 lab1 INT, lab2 INT
	  );
	  SQL
	  ```

4) Build and deploy the Experiment 5 web app
	macOS/Linux:
	- `bash scripts/exp5_build_deploy.sh`

	Windows PowerShell:
	- `powershell -ExecutionPolicy Bypass -File .\scripts\exp5_build_deploy.ps1 -TomcatHome "$env:CATALINA_HOME"`

5) Use the app (in your browser)
	- Insert marks: http://localhost:8080/exp5/Insert.jsp (submit a row; expect "Successfully Inserted")
	- Search marks: http://localhost:8080/exp5/Search.jsp (enter rollno; see a table with Pass/Fail)

That’s it. The app is running entirely locally.

-------------------------------------------------------------------------------
Details and extras
-------------------------------------------------------------------------------

Prerequisites
- Java JDK 11+ (17+ recommended)
- Tomcat 10+ (Jakarta Servlet)
- Docker (to run MySQL locally, no external service required)

Helper scripts (macOS/Linux)
- `scripts/mysql_up.sh` — starts MySQL 8 on port 3308 in Docker and creates the required databases/tables
- `scripts/exp5_build_deploy.sh` — compiles servlets and deploys Experiment 5 to Tomcat

Helper script (Windows)
- `scripts/exp5_build_deploy.ps1` — compiles and deploys Experiment 5 (pass `-TomcatHome` or set `CATALINA_HOME`/`TOMCAT_HOME`)

Manual build (if you prefer explicit commands)
1) On macOS with Homebrew Tomcat:
	```zsh
	export TOMCAT_LIBEXEC="$(brew --prefix tomcat@10)/libexec"
	mkdir -p "EXPERIMENT 5/src/main/webapp/WEB-INF/classes"
	cd "EXPERIMENT 5"
	find src/main/java -name "*.java" -print0 | xargs -0 javac \
	  -cp "$TOMCAT_LIBEXEC/lib/servlet-api.jar:src/main/webapp/WEB-INF/lib/mysql-connector-j-8.3.0.jar" \
	  -d src/main/webapp/WEB-INF/classes
	rsync -a src/main/webapp/ "$TOMCAT_LIBEXEC/webapps/exp5/"
	cd -
	```

2) On Linux with a downloaded Tomcat:
	```bash
	export CATALINA_HOME=/path/to/apache-tomcat-10.x.x
	mkdir -p "EXPERIMENT 5/src/main/webapp/WEB-INF/classes"
	cd "EXPERIMENT 5"
	find src/main/java -name "*.java" -print0 | xargs -0 javac \
	  -cp "$CATALINA_HOME/lib/servlet-api.jar:src/main/webapp/WEB-INF/lib/mysql-connector-j-8.3.0.jar" \
	  -d src/main/webapp/WEB-INF/classes
	rsync -a src/main/webapp/ "$CATALINA_HOME/webapps/exp5/"
	cd -
	```

3) On Windows PowerShell:
	```powershell
	$env:CATALINA_HOME='C:\\path\\to\\apache-tomcat-10.x.x'
	New-Item -ItemType Directory -Force -Path 'EXPERIMENT 5\src\main\webapp\WEB-INF\classes' | Out-Null
	$sources = Get-ChildItem -Path 'EXPERIMENT 5\src\main\java' -Recurse -Filter *.java | ForEach-Object { $_.FullName }
	javac -cp "$env:CATALINA_HOME\lib\servlet-api.jar;EXPERIMENT 5\src\main\webapp\WEB-INF\lib\mysql-connector-j-8.3.0.jar" -d 'EXPERIMENT 5\src\main\webapp\WEB-INF\classes' @sources
	robocopy 'EXPERIMENT 5\src\main\webapp' "$env:CATALINA_HOME\webapps\exp5" /E
	```

Using the Calculator demo
- Deploy: copy `Calculator/src/main/webapp` to your Tomcat webapps directory (e.g., `webapps/calc`)
- Visit: http://localhost:8080/calc/

Stopping services
- Tomcat (macOS/Homebrew): `brew services stop tomcat@10`
- Tomcat (Linux/Windows): stop the process (or use `bin/shutdown.sh`)
- MySQL (Docker): `docker stop mysql-3308` (and `docker rm mysql-3308` to remove)

Troubleshooting
- Servlet compile errors: ensure your classpath points to Tomcat 10’s `lib/servlet-api.jar` (Jakarta packages)
- Port in use: change Tomcat or Docker port mappings if 8080/3308 are busy
- DB connection issues: ensure Docker is running and `scripts/mysql_up.sh` completed successfully

-------------------------------------------------------------------------------
What’s included in this repo
-------------------------------------------------------------------------------
- Experiment 5 (JSP/Servlets + MySQL) — full-stack example you just ran
- Calculator (static webapp)
- Additional Java experiments (collections, lambdas, JDBC, serialization)

Enjoy exploring and extending!
