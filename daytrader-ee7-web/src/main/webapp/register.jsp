<!DOCTYPE html>
<%@ page session="false"%>
<%
    String blank = "";
    String fakeCC = "123-fake-ccnum-456";
    String fullname = request.getParameter("Full Name");
    String snailmail = request.getParameter("snail mail");
    String email = request.getParameter("email");
    String userID = request.getParameter("user id");
    String money = request.getParameter("money");
    String creditcard = request.getParameter("Credit Card Number");
    String results = (String) request.getAttribute("results");
%>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DayTrader Registration</title>
    <link rel="stylesheet" href="style.css" type="text/css">
    <link rel="shortcut icon" href="./favicon.ico">
</head>
<body>
    <nav class="dt-nav">
        <a href="index.html" class="dt-brand">
            <span class="dt-brand-icon">DT</span>
            DayTrader
        </a>
    </nav>

    <main class="dt-main-narrow">
        <div class="dt-card">
            <div class="dt-card-header">
                <h2>Create Account</h2>
            </div>
            <% if (results != null) { %>
            <div class="dt-alert dt-alert-danger"><%= results %></div>
            <% } %>
            <form action="app">
                <div class="dt-form-row">
                    <label><span style="color:var(--accent-red);">*</span> Full Name:</label>
                    <input type="text" name="Full Name" size="40" value="<%= fullname == null ? blank : fullname %>">
                </div>
                <div class="dt-form-row">
                    <label><span style="color:var(--accent-red);">*</span> Address:</label>
                    <input type="text" name="snail mail" size="40" value="<%= snailmail == null ? blank : snailmail %>">
                </div>
                <div class="dt-form-row">
                    <label><span style="color:var(--accent-red);">*</span> Email:</label>
                    <input type="text" name="email" size="40" value="<%= email == null ? blank : email %>">
                </div>
                <hr>
                <div class="dt-form-row">
                    <label><span style="color:var(--accent-red);">*</span> User ID:</label>
                    <input type="text" name="user id" size="40" value="<%= userID == null ? blank : userID %>">
                </div>
                <div class="dt-form-row">
                    <label><span style="color:var(--accent-red);">*</span> Password:</label>
                    <input type="password" name="passwd" size="40">
                </div>
                <div class="dt-form-row">
                    <label><span style="color:var(--accent-red);">*</span> Confirm Password:</label>
                    <input type="password" name="confirm passwd" size="40">
                </div>
                <hr>
                <div class="dt-form-row">
                    <label><span style="color:var(--accent-red);">*</span> Opening Balance:</label>
                    <span style="color:var(--text-primary);">$</span> <input type="text" name="money" size="20" value='<%= money==null ? "10000" : money %>'>
                </div>
                <div class="dt-form-row">
                    <label><span style="color:var(--accent-red);">*</span> Credit Card:</label>
                    <input type="text" name="Credit Card Number" size="40" value="<%= creditcard==null ? fakeCC : creditcard %>" readonly>
                </div>
                <div style="text-align:center;margin-top:1.5rem;">
                    <input type="submit" value="Submit Registration">
                </div>
                <input type="hidden" name="action" value="register">
            </form>
        </div>
    </main>

    <footer class="dt-footer">
        Apache DayTrader Performance Benchmark Sample
    </footer>
</body>
</html>
