<%-- Redirect already-authenticated OIDC users straight to home --%>
<%
javax.servlet.http.HttpSession _s = request.getSession(false);
if (_s != null && _s.getAttribute("uidBean") != null) {
    response.sendRedirect(request.getContextPath() + "/app?action=home");
    return;
}
%>
<!DOCTYPE html>
<%@ page session="false"%>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DayTrader Login</title>
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

    <div class="dt-login-container">
        <div class="dt-login-card">
            <h2>Sign In</h2>
            <%
                String results;
                results = (String) request.getAttribute("results");
                if (results != null) {
            %>
            <div class="dt-alert dt-alert-danger"><%= results %></div>
            <%
                }
            %>
            <form action="app" method="POST">
                <div class="dt-form-group">
                    <label for="uid">Username</label>
                    <input type="text" id="uid" name="uid" value="uid:0" style="width:100%;">
                </div>
                <div class="dt-form-group">
                    <label for="passwd">Password</label>
                    <input type="password" id="passwd" name="passwd" value="xxx" style="width:100%;">
                </div>
                <input type="submit" value="Sign In" style="width:100%;padding:0.625rem;font-size:1rem;">
                <input type="hidden" name="action" value="login">
            </form>
            <hr>
            <p style="text-align:center;color:var(--text-secondary);">First time user? <a href="register.jsp">Register with DayTrader</a></p>
        </div>
    </div>

    <footer class="dt-footer">
        Apache DayTrader Performance Benchmark Sample
    </footer>
</body>
</html>
