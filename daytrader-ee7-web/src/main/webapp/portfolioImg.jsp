<!DOCTYPE html>
<%@ page
    import="java.util.Collection,
            java.util.Iterator,
            java.util.HashMap,
            java.math.BigDecimal,com.ibm.websphere.samples.daytrader.entities.HoldingDataBean,com.ibm.websphere.samples.daytrader.entities.OrderDataBean,com.ibm.websphere.samples.daytrader.entities.QuoteDataBean,com.ibm.websphere.samples.daytrader.util.Log,com.ibm.websphere.samples.daytrader.util.FinancialUtils"
    session="true" isThreadSafe="true" isErrorPage="false"%>
<jsp:useBean id="results" scope="request" type="java.lang.String" />
<jsp:useBean id="holdingDataBeans" type="java.util.Collection<?>"
    scope="request" />
<jsp:useBean id="quoteDataBeans" type="java.util.Collection<?>"
    scope="request" />
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DayTrader Portfolio</title>
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
            <li><a href="app?action=portfolio" class="active">Portfolio</a></li>
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

        <div class="dt-card">
            <div class="dt-card-header">
                <h3>Portfolio</h3>
                <span class="dt-badge dt-badge-blue"><%=holdingDataBeans.size()%> Holdings</span>
            </div>
            <div style="overflow-x:auto;">
                <table class="table">
                    <thead>
                        <tr class="tableHeader">
                            <td>Holding ID</td>
                            <td>Purchase Date</td>
                            <td>Symbol</td>
                            <td>Quantity</td>
                            <td>Purchase Price</td>
                            <td>Current Price</td>
                            <td>Basis</td>
                            <td>Market Value</td>
                            <td>Gain/Loss</td>
                            <td>Trade</td>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            // Create Hashmap for quick lookup of quote values
                            Iterator<?> it2 = quoteDataBeans.iterator();
                            HashMap<Object,Object> quoteMap = new HashMap<Object,Object>();
                            while (it2.hasNext()) {
                                QuoteDataBean quoteData = (QuoteDataBean) it2.next();
                                quoteMap.put(quoteData.getSymbol(), quoteData);
                            }
                            //Step through and printout Holdings

                            it2 = holdingDataBeans.iterator();
                            BigDecimal totalGain = new BigDecimal(0.0);
                            BigDecimal totalBasis = new BigDecimal(0.0);
                            BigDecimal totalValue = new BigDecimal(0.0);
                            int rowCount = 0;
                            try {
                                while (it2.hasNext()) {
                                    HoldingDataBean holdingData = (HoldingDataBean) it2.next();
                                    QuoteDataBean quoteData = (QuoteDataBean) quoteMap.get(holdingData.getQuoteID());
                                    BigDecimal basis = holdingData.getPurchasePrice().multiply(new BigDecimal(holdingData.getQuantity()));
                                    BigDecimal marketValue = quoteData.getPrice().multiply(new BigDecimal(holdingData.getQuantity()));
                                    totalBasis = totalBasis.add(basis);
                                    totalValue = totalValue.add(marketValue);
                                    BigDecimal gain = marketValue.subtract(basis);
                                    totalGain = totalGain.add(gain);
                                    BigDecimal gainPercent = null;
                                    if (basis.doubleValue() == 0.0) {
                                        gainPercent = new BigDecimal(0.0);
                                        Log.error("portfolio.jsp: Holding with zero basis. holdingID=" + holdingData.getHoldingID() + " symbol=" + holdingData.getQuoteID()
                                                + " purchasePrice=" + holdingData.getPurchasePrice());
                                    } else
                                        gainPercent = marketValue.divide(basis, BigDecimal.ROUND_HALF_UP).subtract(new BigDecimal(1.0)).multiply(new BigDecimal(100.0));
                        %>
                        <tr class="<%= (rowCount++ % 2 == 0) ? "tableOddRow" : "tableEvenRow" %>">
                            <td><%=holdingData.getHoldingID()%></td>
                            <td><%=holdingData.getPurchaseDate()%></td>
                            <td><%=FinancialUtils.printQuoteLink(holdingData.getQuoteID())%></td>
                            <td><%=holdingData.getQuantity()%></td>
                            <td><%=holdingData.getPurchasePrice()%></td>
                            <td><%=quoteData.getPrice()%></td>
                            <td><%=basis%></td>
                            <td><%=marketValue%></td>
                            <td><%=FinancialUtils.printGainHTML(gain)%></td>
                            <td><a href="app?action=sell&amp;holdingID=<%=holdingData.getHoldingID()%>" class="dt-btn dt-btn-danger dt-btn-sm">Sell</a></td>
                        </tr>
                        <%
                                }
                            } catch (Exception e) {
                                Log.error("portfolio.jsp: error displaying user holdings", e);
                            }
                        %>
                        <tr style="background:var(--bg-secondary);font-weight:600;">
                            <td colspan="6" style="text-align:right;">Total</td>
                            <td style="text-align:center;">$<%=totalBasis%></td>
                            <td style="text-align:center;">$<%=totalValue%></td>
                            <td style="text-align:center;" colspan="2">$<%=FinancialUtils.printGainHTML(totalGain)%> <%=FinancialUtils.printGainPercentHTML(FinancialUtils.computeGainPercent(totalValue, totalBasis))%></td>
                        </tr>
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
