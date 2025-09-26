<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
<%@page import="LoginBean.LoginBean"%>

<p>You are successfully logged in!</p>

<%

LoginBean bean=(LoginBean)request.getAttribute("bean");

out.print("Welcome, "+bean.getName());

%>
</body>
</html>