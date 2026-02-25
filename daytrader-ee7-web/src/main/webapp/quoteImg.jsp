<!DOCTYPE html>
<%@ page
    import="java.util.Collection,
            java.util.Iterator,com.ibm.websphere.samples.daytrader.entities.OrderDataBean,com.ibm.websphere.samples.daytrader.util.FinancialUtils"
    session="true" isThreadSafe="true" isErrorPage="false"%>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DayTrader: Quotes and Trading</title>
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
            <li><a href="app?action=home">Home</a></li>
            <li><a href="app?action=account">Account</a></li>
            <li><a href="app?action=portfolio">Portfolio</a></li>
            <li><a href="app?action=quotes&amp;symbols=s:0,s:1,s:2,s:3,s:4" class="active">Quotes</a></li>
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

        <div class="dt-card">
            <div class="dt-card-header">
                <h3>Quotes</h3>
            </div>
            <div style="overflow-x:auto;">
                <table class="table">
                    <thead>
                        <tr class="tableHeader">
                            <td>Symbol</td><td>Company</td><td>Volume</td><td>Price Range</td><td>Open Price</td><td>Current Price</td><td>Gain/Loss</td><td>Trade</td>
                        </tr>
                    </thead>
                    <tbody>
<%
String symbols = request.getParameter("symbols");
if (symbols == null)
	symbols = "no_stock_symbol_provided";
java.util.StringTokenizer st = new java.util.StringTokenizer(symbols, " ,");
while (st.hasMoreElements())
{
 		String symbol = st.nextToken();
%>
                        <jsp:include page="displayQuote.jsp" flush="">
                            <jsp:param name="symbol" value="<%= symbol%>" />
                        </jsp:include>
<%
 }
%>
                    </tbody>
                </table>
            </div>
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
