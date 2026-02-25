<!DOCTYPE html>
<%@ page
    import="java.util.Collection,
            java.util.Iterator,
            java.math.BigDecimal,com.ibm.websphere.samples.daytrader.entities.OrderDataBean,com.ibm.websphere.samples.daytrader.util.FinancialUtils"
    session="true" isThreadSafe="true" isErrorPage="false"%>
<jsp:useBean id="results" scope="request" type="java.lang.String" />
<jsp:useBean id="accountData"
    type="com.ibm.websphere.samples.daytrader.entities.AccountDataBean"
    scope="request" />
<jsp:useBean id="accountProfileData"
    type="com.ibm.websphere.samples.daytrader.entities.AccountProfileDataBean"
    scope="request" />
<jsp:useBean id="orderDataBeans" type="java.util.Collection<?>"
    scope="request" />
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DayTrader Account Information</title>
    <link rel="stylesheet" href="style.css" type="text/css">
    <link rel="shortcut icon" href="./favicon.ico">
</head>
<body>
    <%
        boolean showAllOrders = request.getParameter("showAllOrders") == null ? false : true;
    %>
    <nav class="dt-nav">
        <a href="app?action=home" class="dt-brand">
            <span class="dt-brand-icon">DT</span>
            DayTrader
        </a>
        <ul class="dt-nav-links">
            <li><a href="app?action=home">Home</a></li>
            <li><a href="app?action=account" class="active">Account</a></li>
            <li><a href="app?action=mksummary">Market Summary</a></li>
            <li><a href="app?action=portfolio">Portfolio</a></li>
            <li><a href="app?action=quotes&amp;symbols=s:0,s:1,s:2,s:3,s:4">Quotes/Trade</a></li>
            <li><a href="app?action=logout">Logout</a></li>
        </ul>
    </nav>

    <main class="dt-main">
        <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:0.5rem;">
            <span class="text-muted" style="font-size:0.8125rem;"><%=new java.util.Date()%></span>
        </div>

        <%
            Collection<?> closedOrders = (Collection<?>) request.getAttribute("closedOrders");
            if ((closedOrders != null) && (closedOrders.size() > 0)) {
        %>
        <div class="dt-alert dt-alert-warning">
            <strong>Alert:</strong> The following order(s) have completed.
            <table class="table" style="margin-top:0.5rem;">
                <thead>
                    <tr class="tableHeader">
                        <td>Order ID</td><td>Status</td><td>Opened</td><td>Completed</td><td>Fee</td><td>Type</td><td>Symbol</td><td>Quantity</td>
                    </tr>
                </thead>
                <tbody>
                <%
                    Iterator<?> it = closedOrders.iterator();
                    while (it.hasNext()) {
                        OrderDataBean closedOrderData = (OrderDataBean) it.next();
                %>
                    <tr class="tableOddRow">
                        <td><%=closedOrderData.getOrderID()%></td>
                        <td><%=closedOrderData.getOrderStatus()%></td>
                        <td><%=closedOrderData.getOpenDate()%></td>
                        <td><%=closedOrderData.getCompletionDate()%></td>
                        <td><%=closedOrderData.getOrderFee()%></td>
                        <td><%=closedOrderData.getOrderType()%></td>
                        <td><%=FinancialUtils.printQuoteLink(closedOrderData.getSymbol())%></td>
                        <td><%=closedOrderData.getQuantity()%></td>
                    </tr>
                <%
                    }
                %>
                </tbody>
            </table>
        </div>
        <%
            }
        %>

        <% if (results != null && !results.isEmpty()) { %>
        <div class="dt-alert dt-alert-info"><%=results%></div>
        <% } %>

        <div class="dt-card">
            <div class="dt-card-header">
                <h3>Account Information</h3>
            </div>
            <div class="dt-stats-grid">
                <div class="dt-stat">
                    <div class="dt-stat-label">Account Created</div>
                    <div class="dt-stat-value" style="font-size:0.875rem;"><%=accountData.getCreationDate()%></div>
                </div>
                <div class="dt-stat">
                    <div class="dt-stat-label">Last Login</div>
                    <div class="dt-stat-value" style="font-size:0.875rem;"><%=accountData.getLastLogin()%></div>
                </div>
                <div class="dt-stat">
                    <div class="dt-stat-label">Account ID</div>
                    <div class="dt-stat-value" style="font-size:1rem;"><%=accountData.getAccountID()%></div>
                </div>
                <div class="dt-stat">
                    <div class="dt-stat-label">Total Logins</div>
                    <div class="dt-stat-value" style="font-size:1rem;"><%=accountData.getLoginCount()%></div>
                </div>
                <div class="dt-stat">
                    <div class="dt-stat-label">User ID</div>
                    <div class="dt-stat-value" style="font-size:1rem;"><%=accountData.getProfileID()%></div>
                </div>
                <div class="dt-stat">
                    <div class="dt-stat-label">Total Logouts</div>
                    <div class="dt-stat-value" style="font-size:1rem;"><%=accountData.getLogoutCount()%></div>
                </div>
                <div class="dt-stat">
                    <div class="dt-stat-label">Cash Balance</div>
                    <div class="dt-stat-value" style="font-size:1rem;">$<%=accountData.getBalance()%></div>
                </div>
                <div class="dt-stat">
                    <div class="dt-stat-label">Opening Balance</div>
                    <div class="dt-stat-value" style="font-size:1rem;">$<%=accountData.getOpenBalance()%></div>
                </div>
            </div>
        </div>

        <div class="dt-card">
            <div class="dt-card-header">
                <h3>Orders <span class="dt-badge dt-badge-blue"><%=orderDataBeans.size()%> total</span></h3>
                <a href="app?action=account&amp;showAllOrders=true">Show all orders</a>
            </div>
            <div style="overflow-x:auto;">
                <table class="table">
                    <thead>
                        <tr class="tableHeader">
                            <td>Order ID</td><td>Status</td><td>Opened</td><td>Completed</td><td>Fee</td><td>Type</td><td>Symbol</td><td>Quantity</td><td>Price</td><td>Total</td>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            Iterator<?> oit = orderDataBeans.iterator();
                            int count = 0;
                            while (oit.hasNext()) {
                                if ((showAllOrders == false) && (count++ >= 5))
                                    break;
                                OrderDataBean orderData = (OrderDataBean) oit.next();
                        %>
                        <tr class="<%= (count % 2 == 0) ? "tableOddRow" : "tableEvenRow" %>">
                            <td><%=orderData.getOrderID()%></td>
                            <td><%=orderData.getOrderStatus()%></td>
                            <td><%=orderData.getOpenDate()%></td>
                            <td><%=orderData.getCompletionDate()%></td>
                            <td><%=orderData.getOrderFee()%></td>
                            <td><%=orderData.getOrderType()%></td>
                            <td><%=FinancialUtils.printQuoteLink(orderData.getSymbol())%></td>
                            <td><%=orderData.getQuantity()%></td>
                            <td><%=orderData.getPrice()%></td>
                            <td><%=orderData.getPrice().multiply(new BigDecimal(orderData.getQuantity()))%></td>
                        </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>

        <div class="dt-card">
            <div class="dt-card-header">
                <h3>Account Profile</h3>
            </div>
            <form>
                <div class="dt-form-row">
                    <label>User ID:</label>
                    <input size="30" type="text" maxlength="30" readonly name="userID" value="<%=accountProfileData.getUserID()%>">
                </div>
                <div class="dt-form-row">
                    <label>Full Name:</label>
                    <input size="30" type="text" maxlength="30" name="fullname" value="<%=accountProfileData.getFullName()%>">
                </div>
                <div class="dt-form-row">
                    <label>Password:</label>
                    <input size="30" type="password" maxlength="30" name="password" value="<%=accountProfileData.getPassword()%>">
                </div>
                <div class="dt-form-row">
                    <label>Confirm Password:</label>
                    <input size="30" type="password" maxlength="30" name="cpassword" value="<%=accountProfileData.getPassword()%>">
                </div>
                <div class="dt-form-row">
                    <label>Address:</label>
                    <input size="30" type="text" maxlength="30" name="address" value="<%=accountProfileData.getAddress()%>">
                </div>
                <div class="dt-form-row">
                    <label>Email:</label>
                    <input size="30" type="text" maxlength="30" name="email" value="<%=accountProfileData.getEmail()%>">
                </div>
                <div class="dt-form-row">
                    <label>Credit Card:</label>
                    <input size="30" type="text" maxlength="30" name="creditcard" value="<%=accountProfileData.getCreditCard()%>" readonly>
                </div>
                <div style="text-align:right;margin-top:1rem;">
                    <input type="submit" name="action" value="update_profile">
                </div>
            </form>
        </div>

        <div class="dt-card">
            <div style="display:flex;justify-content:space-between;align-items:center;">
                <span class="text-muted">Click any <a href="docs/glossary.html">symbol</a> for a quote or to trade.</span>
                <form action="" style="display:flex;gap:0.5rem;align-items:center;">
                    <input size="20" type="text" name="symbols" value="s:0, s:1, s:2, s:3, s:4">
                    <input type="submit" name="action" value="quotes">
                </form>
            </div>
        </div>
    </main>

    <footer class="dt-footer">
        Apache DayTrader Performance Benchmark Sample
    </footer>
</body>
</html>
