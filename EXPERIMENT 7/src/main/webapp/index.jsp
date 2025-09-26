<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
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
      form { margin-top: 1.5rem; }
      label { display: inline-block; width: 90px; }
      input[type="text"], input[type="password"] { padding: 0.25rem 0.5rem; }
    </style>
  </head>
  <body>
    <h1>Experiment 7 — Login</h1>
    <form action="./ControllerServlet" method="post">
      <p>
        <label for="name">Name:</label>
        <input id="name" type="text" name="name" />
      </p>
      <p>
        <label for="password">Password:</label>
        <input id="password" type="password" name="password" />
      </p>
      <p>
        <input type="submit" value="Login" />
      </p>
    </form>

    <ul>
      <li><a href="login-success.jsp">Login Success (sample)</a></li>
      <li><a href="login-error.jsp">Login Error (sample)</a></li>
    </ul>
  </body>
  </html>