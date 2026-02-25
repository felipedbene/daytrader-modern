<!DOCTYPE html>
<%@ page
    import="java.util.Collection,
            java.util.Iterator,
            java.math.BigDecimal,com.ibm.websphere.samples.daytrader.entities.AccountDataBean,com.ibm.websphere.samples.daytrader.entities.OrderDataBean,com.ibm.websphere.samples.daytrader.util.FinancialUtils"
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
            <li><a href="app?action=portfolio">Portfolio</a></li>
            <li><a href="app?action=quotes&amp;symbols=s:0,s:1,s:2,s:3,s:4">Quotes</a></li>
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

        <div style="display:grid;grid-template-columns:1fr 1fr;gap:1.5rem;">
            <div>
                <div class="dt-card">
                    <div class="dt-card-header">
                        <h3>Welcome, <%=accountData.getProfileID()%></h3>
                    </div>
                    <h3 class="dt-section-title" style="margin-top:0;">User Statistics</h3>
                    <div class="dt-stats-grid" style="grid-template-columns:1fr 1fr;">
                        <div class="dt-stat">
                            <div class="dt-stat-label">Account ID</div>
                            <div class="dt-stat-value" style="font-size:1rem;"><%=accountData.getAccountID()%></div>
                        </div>
                        <div class="dt-stat">
                            <div class="dt-stat-label">Created</div>
                            <div class="dt-stat-value" style="font-size:0.875rem;"><%=accountData.getCreationDate()%></div>
                        </div>
                        <div class="dt-stat">
                            <div class="dt-stat-label">Total Logins</div>
                            <div class="dt-stat-value" style="font-size:1rem;"><%=accountData.getLoginCount()%></div>
                        </div>
                        <div class="dt-stat">
                            <div class="dt-stat-label">Session Created</div>
                            <div class="dt-stat-value" style="font-size:0.875rem;"><%=(java.util.Date) session.getAttribute("sessionCreationDate")%></div>
                        </div>
                    </div>

                    <h3 class="dt-section-title">Account Summary</h3>
                    <%
                        BigDecimal openBalance = accountData.getOpenBalance();
                        BigDecimal balance = accountData.getBalance();
                        BigDecimal holdingsTotal = FinancialUtils.computeHoldingsTotal(holdingDataBeans);
                        BigDecimal sumOfCashHoldings = balance.add(holdingsTotal);
                        BigDecimal gain = FinancialUtils.computeGain(sumOfCashHoldings, openBalance);
                        BigDecimal gainPercent = FinancialUtils.computeGainPercent(sumOfCashHoldings, openBalance);
                    %>
                    <div class="dt-stats-grid" style="grid-template-columns:1fr 1fr;">
                        <div class="dt-stat">
                            <div class="dt-stat-label">Cash Balance</div>
                            <div class="dt-stat-value" style="font-size:1rem;">$<%=balance%></div>
                        </div>
                        <div class="dt-stat">
                            <div class="dt-stat-label">Holdings</div>
                            <div class="dt-stat-value" style="font-size:1rem;"><%=holdingDataBeans.size()%></div>
                        </div>
                        <div class="dt-stat">
                            <div class="dt-stat-label">Holdings Total</div>
                            <div class="dt-stat-value" style="font-size:1rem;">$<%=holdingsTotal%></div>
                        </div>
                        <div class="dt-stat">
                            <div class="dt-stat-label">Cash + Holdings</div>
                            <div class="dt-stat-value" style="font-size:1rem;">$<%=sumOfCashHoldings%></div>
                        </div>
                        <div class="dt-stat">
                            <div class="dt-stat-label">Opening Balance</div>
                            <div class="dt-stat-value" style="font-size:1rem;">$<%=openBalance%></div>
                        </div>
                        <div class="dt-stat">
                            <div class="dt-stat-label">Current Gain/Loss</div>
                            <div class="dt-stat-value" style="font-size:1rem;">$<%=FinancialUtils.printGainHTML(gain)%> <%=FinancialUtils.printGainPercentHTML(gainPercent)%></div>
                        </div>
                    </div>
                </div>
            </div>
            <div>
                <jsp:include page="marketSummary.jsp" flush="" />
            </div>
        </div>

        <div class="dt-card" style="margin-top:1.5rem;">
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
