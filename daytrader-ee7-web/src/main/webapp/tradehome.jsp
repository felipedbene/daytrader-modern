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
<jsp:useBean id="holdingDataBeans" type="java.util.Collection<?>"
    scope="request" />
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Welcome to DayTrader</title>
    <link rel="stylesheet" href="style.css" type="text/css">
    <link rel="shortcut icon" href="./favicon.ico">
</head>
<body>
    <nav class="dt-nav">
        <a href="app?action=home" class="dt-brand">
            <span class="dt-brand-icon">DT</span>
            DayTrader
        </a>
        <ul class="dt-nav-links">
            <li><a href="app?action=home" class="active">Home</a></li>
            <li><a href="app?action=account">Account</a></li>
            <li><a href="app?action=mksummary">Market Summary</a></li>
            <li><a href="app?action=portfolio">Portfolio</a></li>
            <li><a href="app?action=quotes&amp;symbols=s:0,s:1,s:2,s:3,s:4">Quotes/Trade</a></li>
            <li><a href="app?action=logout">Logout</a></li>
        </ul>
    </nav>

    <main class="dt-main">
        <%
            BigDecimal openBalance = accountData.getOpenBalance();
            BigDecimal balance = accountData.getBalance();
            BigDecimal holdingsTotal = FinancialUtils.computeHoldingsTotal(holdingDataBeans);
            BigDecimal sumOfCashHoldings = balance.add(holdingsTotal);
            BigDecimal gain = FinancialUtils.computeGain(sumOfCashHoldings, openBalance);
            BigDecimal gainPercent = FinancialUtils.computeGainPercent(sumOfCashHoldings, openBalance);
            boolean isGain = gain.doubleValue() >= 0;
        %>

        <!-- Hero Banner -->
        <div class="dt-hero">
            <div class="dt-hero-title">
                Welcome back, <strong style="color:var(--text-primary);"><%=accountData.getProfileID()%></strong>
                <span class="dt-badge dt-badge-blue" style="margin-left:0.5rem;">Account #<%=accountData.getAccountID()%></span>
            </div>
            <div class="dt-hero-grid">
                <div class="dt-hero-item">
                    <div class="dt-hero-label">Portfolio Value</div>
                    <div class="dt-hero-value">$<%=sumOfCashHoldings%></div>
                    <div class="dt-hero-sub">Cash + Holdings</div>
                </div>
                <div class="dt-hero-item">
                    <div class="dt-hero-label">Total Gain / Loss</div>
                    <div class="dt-hero-value <%= isGain ? "gain" : "loss" %>"><%=FinancialUtils.printGainHTML(gain)%></div>
                    <div class="dt-hero-sub"><%=FinancialUtils.printGainPercentHTML(gainPercent)%> vs. opening</div>
                </div>
                <div class="dt-hero-item">
                    <div class="dt-hero-label">Cash Balance</div>
                    <div class="dt-hero-value" style="font-size:1.5rem;">$<%=balance%></div>
                    <div class="dt-hero-sub">Available to invest</div>
                </div>
                <div class="dt-hero-item">
                    <div class="dt-hero-label">Holdings</div>
                    <div class="dt-hero-value" style="font-size:1.5rem;"><%=holdingDataBeans.size()%></div>
                    <div class="dt-hero-sub">$<%=holdingsTotal%> invested</div>
                </div>
            </div>
        </div>

        <%
            Collection<?> closedOrders = (Collection<?>) request.getAttribute("closedOrders");
            if ((closedOrders != null) && (closedOrders.size() > 0)) {
        %>
        <div class="dt-alert dt-alert-warning">
            <strong>Order Alert:</strong> The following order(s) have completed.
            <table class="table" style="margin-top:0.75rem;">
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

        <!-- Account Stats -->
        <div class="dt-card">
            <div class="dt-card-header">
                <h3>Account Details</h3>
                <span style="font-size:0.75rem;color:var(--text-muted);"><%=new java.util.Date()%></span>
            </div>
            <div class="dt-stats-grid">
                <div class="dt-stat">
                    <div class="dt-stat-label">Opening Balance</div>
                    <div class="dt-stat-value">$<%=openBalance%></div>
                </div>
                <div class="dt-stat">
                    <div class="dt-stat-label">Total Logins</div>
                    <div class="dt-stat-value"><%=accountData.getLoginCount()%></div>
                </div>
                <div class="dt-stat">
                    <div class="dt-stat-label">Account Created</div>
                    <div class="dt-stat-value" style="font-size:0.8125rem;"><%=accountData.getCreationDate()%></div>
                </div>
                <div class="dt-stat">
                    <div class="dt-stat-label">Session Started</div>
                    <div class="dt-stat-value" style="font-size:0.8125rem;"><%=(java.util.Date) session.getAttribute("sessionCreationDate")%></div>
                </div>
            </div>
        </div>

        <!-- Quick Trade -->
        <div class="dt-card">
            <div class="dt-card-header">
                <h3>Quick Quote</h3>
                <span class="text-muted" style="font-size:0.75rem;">Enter symbols separated by commas</span>
            </div>
            <form action="" style="display:flex;gap:0.75rem;align-items:center;flex-wrap:wrap;">
                <input style="flex:1;min-width:200px;" type="text" name="symbols" value="s:0, s:1, s:2, s:3, s:4">
                <input type="submit" name="action" value="quotes" style="white-space:nowrap;">
            </form>
            <p style="margin:0.75rem 0 0;font-size:0.75rem;">Click any <a href="docs/glossary.html">symbol</a> in your portfolio for a quote or to place a trade.</p>
        </div>
    </main>

    <footer class="dt-footer">
        Apache DayTrader Performance Benchmark Sample
    </footer>
</body>
</html>
