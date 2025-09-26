<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8" />
    <title>Experiment 7 — Login</title>
    <style>
      body { font-family: -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Arial, sans-serif; margin: 2rem; }
      a { color: #0b5fff; text-decoration: none; }
      a:hover { text-decoration: underline; }
      ul { line-height: 1.8; }
    </style>
  </head>
  <body>
    <h1>Experiment 7 — Login</h1>
    <ul>
      <li><a href="login-success.jsp">Login Success (sample)</a></li>
      <li><a href="login-error.jsp">Login Error (sample)</a></li>
    </ul>
  </body>
  </html>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="ISO-8859-1">
<title>Insert title here</title>
</head>
<body>
<form action="./ControllerServlet" method="post">

Name:<input type="text" name="name"><br>

Password:<input type="password" name="password"><br>

<input type="submit" value="login">

</form>
</body>
</html>